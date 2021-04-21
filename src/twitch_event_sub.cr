require "./*"

module TwitchEventSub
  VERSION = "0.1.0"

  API_ENDPOINT = "https://api.twitch.tv/helix/"
  EVENTSUB_ENDPOINT = API_ENDPOINT + "eventsub/"

  class Subscriptions
    def initialize(@client_id : String, @authorization : String)
    end

    def list
      client = HTTP::Client.get(
        url: "#{EVENTSUB_ENDPOINT}subscriptions",
        headers: HTTP::Headers{
          "Client-ID" => @client_id,
          "Authorization" => "Bearer #{@authorization}"
        }
      )

      puts client.inspect
    end

    def subscribe(event : String, channel : String)
      id = broadcast_channel_id(channel)
    end

    def broadcast_channel_id(channel)
      url = "#{API_ENDPOINT}users?login=#{channel}"
      puts url
      user = HTTP::Client.get(
        url: url,
        headers: HTTP::Headers{
          "Client-ID" => @client_id,
          "Authorization" => "Bearer #{@authorization}"
        }
      )

      puts user.inspect
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

subs = TwitchEventSub::Subscriptions.new("020dnmxyu7eqpinwpkp9fnnlwa9igy",ENV["TWITCH_APP_ACCESS_TOKEN"])
subs.list

subs.broadcast_channel_id("wyhaines")