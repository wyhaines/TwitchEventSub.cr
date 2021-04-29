require "./secret_superclass"

module TwitchEventSub
  class SecretStore < ::Hash(String, String)
    include SecretSuperclass
  end
end
