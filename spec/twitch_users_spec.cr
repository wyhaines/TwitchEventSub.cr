require "./spec_helper"

describe TwitchEventSub::TwitchUsers do
  users = TwitchEventSub::TwitchUsers.from_json(Mocks::TwitchUsers.json)

  it "parses a list of users" do
    users.data.size.should eq 1
    users.data[0].id.should eq Mocks::TwitchUser.id
  end
end