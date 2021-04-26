require "json"

module TwitchEventSub
  class TwitchSubscriptionRequest
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    def self.blank_obj
      from_json("{}")
    end

    @[JSON::Field(key: "type")]
    property type : String = ""

    @[JSON::Field(key: "version")]
    property version : String = "1"

    @[JSON::Field(key: "condition")]
    property condition : Hash(String, String) = {} of String => String

    @[JSON::Field(key: "transport")]
    property transport : Hash(String, String) = {} of String => String
  end
end
