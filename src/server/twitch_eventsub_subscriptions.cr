require "json"
require "./twitch_eventsub_subscription"

module TwitchEventSub
  # This class wraps up a list of subscriptions, allowing them to be
  # serialized and deserialized.
  class TwitchEventSubSubscriptions
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[JSON::Field(key: "data")]
    property data : Array(TwitchEventSubSubscription)

    @[JSON::Field(key: "id")]
    property id : String = ""

    @[JSON::Field(key: "status")]
    property status : String = ""

    @[JSON::Field(key: "type")]
    property type : String = ""

    @[JSON::Field(key: "version")]
    property version : String = ""

    @[JSON::Field(key: "condition")]
    property condition : Hash(String, String) = {} of String => String

    @[JSON::Field(key: "created_at")]
    property created_at : String = ""

    @[JSON::Field(key: "transport")]
    property transport : Hash(String, String) = {} of String => String

    @[JSON::Field(key: "limit")]
    property limit : Int32 = 0

    @[JSON::Field(key: "total")]
    property total : Int32 = 0

    @[JSON::Field(key: "total_cost")]
    property total_cost : Int32 = 0

    @[JSON::Field(key: "max_total_cost")]
    property max_total_cost : Int32 = 0

    @[JSON::Field(key: "pagination")]
    property pagination : Hash(String, String)
  end
end
