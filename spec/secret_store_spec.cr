require "./spec_helper"
require "uuid"

describe TwitchEventSub::SecretStore do
  store = TwitchEventSub::SecretStore.new

  it "store can accept new secrets" do
    uuid = UUID.random.to_s
    store[uuid] = "iamareallysecretsecret"

    store.keys.size.should eq 1
    store[uuid].should eq "iamareallysecretsecret"
  end
end