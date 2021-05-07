require "http/server/handler"
require "openssl/hmac"
require "json"

module TwitchEventSub
  class HttpServer
    # The TwitchHandler encapsulates the logic necessary to handle callbacks
    # from Twitch. This class should be subclassed with `handle_TYPE` methods
    # defined for each type of Twitch notification that will be handled.
    # For example, to monitor channel follow events, the subscription type
    # from Twitch is `channel.follow`. The corresponding method to handle this
    # event type would be `handle_channel_follow`.
    class TwitchHandler
      include HTTP::Handler

      def initialize(
        @secrets : SecretSuperclass,
        @notifications : Channel(Nil) = Channel(Nil).new
        )
        super()
      end

      def call(context)
        if verification?(context)
          do_verification(context)
        else
          do_request(context)
        end

        call_next(context) unless self.next.nil?
      end

      def verification?(context)
        context.request.headers["Twitch-Eventsub-Message-Type"]? == "webhook_callback_verification"
      end

      def parse_context(context)
        request = context.request
        request_body = request.body
        if request_body.nil?
          body = nil
          params = JSON.parse("{}")
        else
          body = request_body.gets_to_end
          params = JSON.parse(body)
        end

        return {request, body, params}
      end

      def do_verification(context)
        request, body, params = parse_context(context)
        return if body.nil?

        challenge = params["challenge"]?
        if challenge
          if signature_matches?(request, body, params)
            context.response.status_code = 200
            context.response.write challenge.as_s.to_slice
            context.response.flush
            context.response.close
          else
            context.response.respond_with_status(403)
          end
        end
      end

      def secret(id)
        pp @secrets
        @secrets[id]
      end

      # Compare the signature passed as a param to the HMAC-SHA256 signature
      # that is calculated from the message contents to ensure that they
      # match.
      def signature_matches?(request, body, params)
        message_id = request.headers["Twitch-Eventsub-Message-Id"]
        signature = request.headers["Twitch-Eventsub-Message-Signature"]
        algorithm = algorithm_from_signature(signature)
        calculated_signature = OpenSSL::HMAC.hexdigest(
          algorithm,
          secret(params["subscription"]["id"]),
          message_id +
          request.headers["Twitch-Eventsub-Message-Timestamp"] +
          body
        )

        signature == "#{algorithm}=#{calculated_signature}"
      end

      # Determine the correct algorithm to use from the signature that
      # Twitch sends. This way, if or when they switch from SHA256, the
      # library should continue working without any required changes.
      def algorithm_from_signature(signature)
        alg, sig = signature.split("=",2)
        # If it has to use the default, it will probably fail, but
        # we will put a default here anyway.
        OpenSSL::Algorithm.parse(alg) || OpenSSL::Algorithm::SHA256
      end

      # This macro generates an array of all of the handler method
      # names in the class.
      macro list_handlers
        %w(
        {% for method in @type.methods %}
          {% if method.name =~ /^handle_/ %}
          {{ method.name }}
          {% end %}
        {% end %}
        )
      end

      # This returns an array of all of the handler method names
      # in the class.
      def self.twitch_subscription_handlers
        list_handlers
      end

      # This macros generates an array of all of the Twitch events
      # that this class can handle.
      macro list_handler_commands
        %w(
        {% for method in @type.methods %}
          {% if method.name =~ /^handle_/ %}
          {{ method.name.gsub(/^handle_/, "").tr("_", ".") }}
          {% end %}
        {% end %}
        )
      end

      # This method returns an array of all of the Twitch events
      # that this class can handle.
      def self.twitch_subscription_handler_commands
        list_handler_commands
      end

      # This macro generates a case statement so that the correct
      # method can be called to handle the given twitch subscription
      # type.
      macro dispatch(type, request, params)
        case {{ type.id }}
        {% for method in @type.methods %}
          {% if method.name =~ /^handle_/ %}
        when "{{ method.name.gsub(/^handle_/, "") }}" then {{ method.name.id }}({{ request.id }}, {{ params.id }})
          {% end %}
        {% end %}
        else
          raise NotImplementedError.new("handle_#{ {{ type.id }} }")
        end
      end

      def do_request(context)
        request, body, params = parse_context(context)
        return if body.nil?

        handled = true
        handled = dispatch(params["subscription"]["type"].as_s.tr(".", "_"), request, params)
      rescue NotImplementedError
        # Do nothing if the notification type does not have a handler.
      ensure
        # TODO: Make this error handling a bit more configurable.
        if handled == :error
          # If handled is :error, something bad happened.
          context.response.respond_with_status(500)
        else
          context.response.respond_with_status(200)
        end
      end
    end
  end
end
