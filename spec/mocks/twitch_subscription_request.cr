struct Mocks
  struct TwitchSubscriptionRequest
    def self.type
      "users.update"
    end

    def self.version
      "1"
    end

    def self.user_id
      "1234"
    end

    def self.condition
      <<-EJSON
      {
        "user_id": "#{user_id}"
      }
      EJSON
    end

    def self.method
      "webhook"
    end

    def self.callback
      "https://this-is-a-callback.com"
    end

    def self.secret
      "s3cre7"
    end

    def self.transport
      <<-EJSON
      {
        "method": "#{method}",
        "callback": "#{callback}",
        "secret": "#{secret}"
      }
      EJSON
    end

    def self.json
      <<-EJSON
      {
        "type": "#{type}",
        "version": "#{version}",
        "condition": #{condition},
        "transport": #{transport}
      }
      EJSON
    end
  end
end