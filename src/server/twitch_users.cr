require "json"

module TwitchEventSub
  class TwitchUsers
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    @[JSON::Field(key: "data")]
    property data : Array(TwitchUser) = [] of TwitchUser
  end
end
