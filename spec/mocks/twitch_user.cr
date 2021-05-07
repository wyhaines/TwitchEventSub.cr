struct Mocks
  struct TwitchUser
    def self.id
      "141981764"
    end

    def self.login
      "twitchdev"
    end

    def self.display_name
      "TwitchDev"
    end

    def self.type
      ""
    end

    def self.broadcaster_type
      "partner"
    end

    def self.description
      "Supporting third-party developers building Twitch integrations from chatbots to game integrations."
    end

    def self.profile_image_url
      "https://static-cdn.jtvnw.net/jtv_user_pictures/8a6381c7-d0c0-4576-b179-38bd5ce1d6af-profile_image-300x300.png"
    end

    def self.offline_image_url
      "https://static-cdn.jtvnw.net/jtv_user_pictures/3f13ab61-ec78-4fe6-8481-8682cb3b0ac2-channel_offline_image-1920x1080.png"
    end

    def self.view_count
      5980557
    end

    def self.email
      "not-real@email.com"
    end

    def self.created_at
      "2016-12-14T20:32:28.894263Z"
    end

    def self.json
      <<-EJSON
      {
        "id": "#{id}",
        "login": "#{login}",
        "display_name": "#{display_name}",
        "type": "#{type}",
        "broadcaster_type": "#{broadcaster_type}",
        "description": "#{description}",
        "profile_image_url": "#{profile_image_url}",
        "offline_image_url": "#{offline_image_url}",
        "view_count": #{view_count},
        "email": "#{email}",
        "created_at": "#{created_at}"
      }
      EJSON
    end
  end
end