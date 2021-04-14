require "http/server/handler"
require "json"

module TwitchEventSub
  class HttpServer
    class TwitchHandler
      include HTTP::Handler

      def call(context)
        if verification?(context)
          handle_verification(context)
        else
          handle_request(context)
        end

        call_next(context)
      end

      def verification?(context)
        context.request.headers["Twitch-Eventsub-Message-Type"]? == "webhook_callback_verification"
      end

      def handle_verification(context)
        request = context.request
        body = request.body.read
        params = JSON.parse(body)

        challenge = params["challenge"]?
        if challenge
          conext.response.respond_with_status(
            status: 200,
            message: challenge.as(String)
          )
        end
      end

      def handle_request(context)
      end

    end
  end
end