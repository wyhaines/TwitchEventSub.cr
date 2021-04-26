require "http/server/handler"
require "json"

module TwitchEventSub
  class HttpServer
    class TwitchHandler
      include HTTP::Handler

      def call(context)
        puts "in call"
        if verification?(context)
          handle_verification(context)
        else
          handle_request(context)
        end

        call_next(context) unless self.next.nil?
      end

      def verification?(context)
        puts "in verification?"
        context.request.headers["Twitch-Eventsub-Message-Type"]? == "webhook_callback_verification"
      end

      def handle_verification(context)
        puts "in handle_verification"
        request = context.request
        request_body = request.body
        return if request_body.nil?

        body = request_body.gets_to_end
        params = JSON.parse(body)

        challenge = params["challenge"]?
        if challenge
          puts challenge.as_s

          context.response.status_code = 200
          context.response.write challenge.as_s.to_slice
          context.response.flush
          context.response.close
        end
      end

      def handle_request(context)
        puts "handle_request: #{context.inspect}"
      end
    end
  end
end
