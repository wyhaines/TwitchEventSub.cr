require "./*"
require "uuid"

module TwitchEventSub
  VERSION = "0.1.0"

  API_ENDPOINT      = "https://api.twitch.tv/helix/"
  EVENTSUB_ENDPOINT = API_ENDPOINT + "eventsub/"

  class Subscriptions
    @@secrets = {} of String => String

    def self.secrets
      @@secrets
    end

    def initialize(@client_id : String, @authorization : String)
    end

    def list
      url = "#{EVENTSUB_ENDPOINT}subscriptions"
      TwitchEventSubSubscriptions.from_json(get(url).body)
    end

    def generate_secret
      UUID.random.to_s
    end

    def subscribe(type : String, channel : String)
      id = broadcast_channel_id(channel)
      return if id.nil?

      secret = generate_secret
      response = send_subscription_request(id, type: type, channel: channel, secret: secret)
      return unless verification_pending?(response)

      # Save the secret that was used.
      response_params = TwitchEventSubSubscriptions.from_json(response.body)
      response_params["data"].as_a.each do |subscription|
        Subscriptions.secrets[subscription.as_h["id"]] = secret
      end
    end

    def unsubscribe(subscription)
      url = "#{EVENTSUB_ENDPOINT}subscriptions"
      delete(
        url: url,
        body: subscription.to_json
      )
    end

    private def send_subscription_request(id : String, type : String, channel : String, secret : String)
      subscription_request = TwitchSubscriptionRequest.blank_obj
      subscription_request.type = type
      subscription_request.condition = {"broadcaster_user_id" => id}
      subscription_request.transport = {
        "method"   => "webhook",
        "callback" => "https://wyhaines.pagekite.me/eventsub/subscription",
        "secret"   => secret,
      }

      url = "#{EVENTSUB_ENDPOINT}subscriptions"
      post(
        url: url,
        body: subscription_request.to_json
      )
    end

    def verification_pending?(response)
      status = JSON.parse(response.body)["data"][0]["status"].as_s
      puts status
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

      while shiftable_hdrs.any?
        merged_headers.merge! shiftable_hdrs.shift
      end

      merged_headers
    end

    def get(url)
      HTTP::Client.get(
        url: url,
        headers: auth_headers
      )
    end

    def post(url, body)
      HTTP::Client.post(
        url: url,
        headers: headers(auth_headers, json_content_type_header),
        body: body
      )
    end

    def delete(url, body)
      HTTP::Client.delete(
        url: url,
        headers: headers(auth_headers, json_content_type_header),
        body: body
      )
    end
  end
end

server = TwitchEventSub::HttpServer.new(
  host: "127.0.0.1",
  port: 8080
)

finished_running = Channel(Nil).new(1)

spawn(name: "Twitch HTTP Server") do
  server.listen
  finished_running.send(nil)
end

subs = TwitchEventSub::Subscriptions.new("020dnmxyu7eqpinwpkp9fnnlwa9igy", ENV["TWITCH_APP_ACCESS_TOKEN"])
slist = subs.list
pp slist
slist.data.each do |sub|
  next unless sub.status == "webhook_callback_verification_failed"
  puts "UNSUBSCRIBE:"
  pp sub
  subs.unsubscribe(sub)
end

pp subs.list
# puts "authenticate"
# subs.broadcast_channel_id("wyhaines")
# puts "subscribe"
# subs.subscribe("channel.follow", "wyhaines")
# finished_running.receive
