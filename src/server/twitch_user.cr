require "json"

module TwitchEventSub
  class TwitchUser
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[JSON::Field(key: "broadcaster_type")]
    property broadcaster_type : String = ""

    @[JSON::Field(key: "description")]
    property description : String = ""

    @[JSON::Field(key: "display_name")]
    property display_name : String = ""

    @[JSON::Field(key: "id")]
    property id : String = ""

    @[JSON::Field(key: "login")]
    property login : String = ""

    @[JSON::Field(key: "offline_image_url")]
    property offline_image_url : String = ""

    @[JSON::Field(key: "profile_image_url")]
    property profile_image_url : String = ""

    @[JSON::Field(key: "type")]
    property type : String = ""

    @[JSON::Field(key: "view_count")]
    property view_count : Int32 = 0

    @[JSON::Field(key: "email")]
    property email : String = ""

    @[JSON::Field(key: "created_at")]
    property created_at : String = ""
  end
end
