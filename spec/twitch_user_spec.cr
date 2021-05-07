require "./spec_helper"

describe TwitchEventSub::TwitchUser do
  user = TwitchEventSub::TwitchUser.from_json(Mocks::TwitchUser.json)
  it "broadcaster_type parses correctly" do
    user.broadcaster_type.should eq Mocks::TwitchUser.broadcaster_type
  end

  it "description parses correctly" do
    user.description.should eq Mocks::TwitchUser.description
  end

  it "display_name parses correctly" do
    user.display_name.should eq Mocks::TwitchUser.display_name
  end

  it "id parses correctly" do
    user.id.should eq Mocks::TwitchUser.id
  end

  it "login parses correctly" do
    user.login.should eq Mocks::TwitchUser.login
  end

  it "offline_image_url parses correctly" do
    user.offline_image_url.should eq Mocks::TwitchUser.offline_image_url
  end

  it "profile_image_url parses correctly" do
    user.profile_image_url.should eq Mocks::TwitchUser.profile_image_url
  end

  it "type parses correctly" do
    user.type.should eq Mocks::TwitchUser.type
  end

  it "view_count parses correctly" do
    user.view_count.should eq Mocks::TwitchUser.view_count
  end

  it "email parses correctly" do
    user.email.should eq Mocks::TwitchUser.email
  end

  it "created_at parses correctly" do
    user.created_at.should eq Mocks::TwitchUser.created_at
  end
  
end
