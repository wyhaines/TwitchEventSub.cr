require "./spec_helper"

describe TwitchEventSub::TwitchSubscriptionRequest do
  request = TwitchEventSub::TwitchSubscriptionRequest.from_json(Mocks::TwitchSubscriptionRequest.json)
  it "type is set" do
    request.type.should eq Mocks::TwitchSubscriptionRequest.type
  end

  it "version is set" do
    request.version.should eq Mocks::TwitchSubscriptionRequest.version
  end

  it "condition user_id is set" do
    request.condition["user_id"].should eq Mocks::TwitchSubscriptionRequest.user_id
  end

  
end