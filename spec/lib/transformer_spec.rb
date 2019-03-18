require "spec_helper"
require_relative "#{ENV["ROOT_PATH"]}/lib/transformer"

describe Transformer do
  describe "#profile_to_actor" do
    it "transforms FB profile into ActivityPub Actor JSON" do
      profile_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/facebook/profile.json"
      transformer = Transformer.new(profile_path: profile_path)

      transformer.profile_to_actor

      output_file = JSON.parse File.read(transformer.actor_path)
      fixture = JSON.parse File.read("#{ENV["ROOT_PATH"]}/spec/fixtures/activitystreams/actor.json")
      expect(output_file).to eq(fixture)
    end

    it "rejects nil fields" do
      profile_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/facebook/profile_no_email.json"
      actor_path = "#{ENV["ROOT_PATH"]}/actor_no_email.json"
      transformer = Transformer.new(profile_path: profile_path, actor_path: actor_path)

      transformer.profile_to_actor

      output_file = JSON.parse File.read(transformer.actor_path)
      fixture = JSON.parse File.read("#{ENV["ROOT_PATH"]}/spec/fixtures/activitystreams/actor_no_email.json")
      expect(output_file).to eq(fixture)
    end
  end

  describe "#feed_to_activity" do
    it "converts feed into ActivityPub Activity JSON" do
      feed_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/facebook/feed.json"
      transformer = Transformer.new(feed_path: feed_path)

      transformer.feed_to_activity

      output_file = JSON.parse File.read(transformer.activity_path)
      fixture = JSON.parse File.read("#{ENV["ROOT_PATH"]}/spec/fixtures/activitystreams/activity.json")
      expect(output_file).to eq(fixture)
    end
  end
end