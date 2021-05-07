struct Mocks
  struct TwitchUsers
    def self.json
      <<-EJSON
      {
        "data": [
          #{TwitchUser.json}
        ]
      }
      EJSON
    end
  end
end