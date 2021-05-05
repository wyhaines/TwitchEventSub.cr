require "./*"
require "uuid"

module TwitchEventSub
  VERSION = "0.1.0"

  API_ENDPOINT      = "https://api.twitch.tv/helix/"
  EVENTSUB_ENDPOINT = API_ENDPOINT + "eventsub/"

  class Subscriptions
    property server_finished_running : Channel(Nil) = Channel(Nil).new(1)
    property http_server : TwitchEventSub::HttpServer

    def initialize(
      @client_id : String,
      @authorization : String,
      @secret_store = SecretStore.new,
      host : String = "127.0.0.1",
      port : Int32 = 8080,
      context : OpenSSL::SSL::Context::Server? = nil,
      handler = TwitchEventSub::HttpServer::TwitchHandler
    )
      @http_server = TwitchEventSub::HttpServer.new(
        host: host,
        port: port,
        context: context,
        secrets: @secret_store,
        handler: handler
      )
      spawn_server_listener
    end

    private def spawn_server_listener
      spawn(name: "Twitch HTTP Server") do
        @http_server.listen
        @server_finished_running.send(nil)
      end
    end

    def secrets
      @secret_store
    end

    def list
      url = "#{EVENTSUB_ENDPOINT}subscriptions"
      TwitchEventSubSubscriptions.from_json(get(url).body)
    end

    def generate_secret
      UUID.random.to_s
    end

    def condition(type, id, other_parameters) : Hash(String, String)
      case type
      when "channel.raid"
        {"to_broadcaster_user_id" => id.to_s}
      when "user.update"
        {"user_id" => id.to_s}
      else
        {"broadcaster_user_id" => id.to_s}.merge(other_parameters)
      end
    end

    def subscribe(
      type : String,
      channel_or_id : String | Int,
      other_parameters : Hash(String, String) = {} of String => String
    )
      unless channel_or_id.is_a?(Int32)
        if channel_or_id.is_a?(String)
          unless id = channel_or_id.to_i32?
            id = broadcast_channel_id(channel_or_id)
          else
            id = channel_or_id.to_i32
          end
        end
      else
        id = channel_or_id
      end
      return if id.nil?

      secret = generate_secret
      response = send_subscription_request(
        type: type,
        secret: secret,
        condition: condition(
          type: type,
          id: id,
          other_parameters: other_parameters)
      )
      return unless verification_pending?(response)

      # Save the secret that was used.
      response_params = TwitchEventSubSubscriptions.from_json(response.body)
      response_params.data.each do |subscription|
        secrets[subscription.id] = secret
      end
    end

    def unsubscribe(subscription)
      url = "#{EVENTSUB_ENDPOINT}subscriptions"
      delete(
        url: url,
        body: subscription.to_json
      )
    end

    # The Twitch documentation specifically states:
    #   *No authorization required.*
    # For the six subscription types in the first when clause.
    # Experimentally, though, this seems to not be the case.
    # Both `channel.follow` and `user.update` have been shown
    # to require oauth authentication or they error.
    # This code is being retained for the moment in case it turns
    # out that I am just badly misunderstanding something, and'
    # this code can still be used. However, this method is likely
    # going to be removed in the near future.
    private def headers_for(type : String) : HTTP::Headers
      case type
      when "channel.update",
           "channel.follow",
           "channel.raid",
           "stream.online",
           "stream.offline",
           "user.update"
        headers(auth_headers, json_content_type_header)
      else
        headers(auth_headers, json_content_type_header)
      end
    end

    private def send_subscription_request(
      type : String,
      secret : String,
      condition : Hash(String, String) = {} of String => String
    )
      subscription_request = TwitchSubscriptionRequest.blank_obj
      subscription_request.type = type
      subscription_request.condition = condition
      subscription_request.transport = {
        "method"   => "webhook",
        "callback" => "https://wyhaines.pagekite.me/eventsub/subscription",
        "secret"   => secret,
      }
      pp subscription_request
      url = "#{EVENTSUB_ENDPOINT}subscriptions"
      post(
        url: url,
        body: subscription_request.to_json,
        headers: headers_for(type)
      )
    end

    def verification_pending?(response)
      status = JSON.parse(response.body)["data"][0]["status"].as_s
      status == "webhook_callback_verification_pending"
    end

    def user_by_channel_name(channel)
      url = "#{API_ENDPOINT}users?login=#{channel}"
      TwitchUsers.from_json(get(url).body)
    end

    def broadcast_channel_id(channel) : String?
      user = user_by_channel_name(channel).data.first?
      user.nil? ? nil : user.id
    end

    def auth_headers
      HTTP::Headers{
        "Client-ID"     => @client_id,
        "Authorization" => "Bearer #{@authorization}",
      }
    end

    def json_content_type_header
      HTTP::Headers{
        "Content-Type" => "application/json",
      }
    end

    def headers(*hdrs)
      return HTTP::Headers{} of String => String if hdrs.empty?

      shiftable_hdrs = hdrs.to_a
      merged_headers = shiftable_hdrs.shift

      while !shiftable_hdrs.empty?
        merged_headers.merge! shiftable_hdrs.shift
      end

      merged_headers
    end

    def get(url, headers = auth_headers)
      HTTP::Client.get(
        url: url,
        headers: headers
      )
    end

    def post(url, body, headers = headers(auth_headers, json_content_type_header))
      HTTP::Client.post(
        url: url,
        headers: headers,
        body: body
      )
    end

    def delete(url, body, headers = headers(auth_headers, json_content_type_header))
      HTTP::Client.delete(
        url: url,
        headers: headers,
        body: body
      )
    end
  end
end
