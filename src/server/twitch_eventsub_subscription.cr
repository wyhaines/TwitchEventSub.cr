require "json"

module TwitchEventSub
  class TwitchEventSubSubscription
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[JSON::Field(key: "id")]
    property id : String = ""

    @[JSON::Field(key: "status")]
    property status : String = ""

    @[JSON::Field(key: "type")]
    property type : String = ""

    @[JSON::Field(key: "version")]
    property version : String = ""

    @[JSON::Field(key: "cost")]
    property cost : Int32 = 0

    @[JSON::Field(key: "condition")]
    property condition : Hash(String, String)

    @[JSON::Field(key: "created_at")]
    property created_at : String = ""

    @[JSON::Field(key: "transport")]
    property transport : Hash(String, String)
  end
end
