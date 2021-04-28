require "http/server/handler"
require "openssl/hmac"
require "json"

module TwitchEventSub
  class HttpServer
    # The TwitchHandler encapsulates the logic necessary to handle callbacks
    # from Twitch.
    class TwitchHandler
      include HTTP::Handler

      def call(context)
        if verification?(context)
          handle_verification(context)
        else
          handle_request(context)
        end

        call_next(context) unless self.next.nil?
      end

      def verification?(context)
        context.request.headers["Twitch-Eventsub-Message-Type"]? == "webhook_callback_verification"
      end

      def handle_verification(context)
        request = context.request
        request_body = request.body
        return if request_body.nil?

        body = request_body.gets_to_end
        params = JSON.parse(body)

        challenge = params["challenge"]?
        if challenge
          if signature_matches?(request, body)
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
        Subscriptions.secrets[id]
      end

      # Compare the signature passed as a param to the HMAC-SHA256 signature
      # that is calculated from the message contents to ensure that they
      # match.
      def signature_matches?(request, body)
        message_id = request.headers["Twitch-Eventsub-Message-Id"]
        calculated_signature = OpenSSL::HMAC.hexdigest(
          OpenSSL::Algorithm::SHA256,
          secret(message_id),
          message_id +
          request.headers["Twitch-Eventsub-Message-Timestamp"] +
          body
        )

        signature = request.headers["Twitch-Eventsub-Message-Signature"]

        signature == calculated_signature
      end

      def handle_request(context)
        puts "handle_request: #{context.inspect}"
      end
    end
  end
end
