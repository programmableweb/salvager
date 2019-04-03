require "spec_helper"
require_relative "#{ENV["ROOT_PATH"]}/lib/transformer"

describe Transformer do
  describe ".run" do
   it "transforms profile and feed into ActivityStreams" do
     input_dir = "#{ENV["ROOT_PATH"]}/spec/fixtures/facebook"
     output_dir = "#{ENV["ACTIVITYSTREAMS_OUTPUT_DIR"]}"

     Transformer.run(input_dir: input_dir, output_dir: output_dir)

     output_actor = JSON.parse File.read("#{ENV["ACTIVITYSTREAMS_OUTPUT_DIR"]}/actor.json")
     output_activity = JSON.parse File.read("#{ENV["ACTIVITYSTREAMS_OUTPUT_DIR"]}//activity.json")
     actor_fixture = JSON.parse File.read("#{ENV["ROOT_PATH"]}/spec/fixtures/activitystreams/actor.json")
     activity_fixture = JSON.parse File.read("#{ENV["ROOT_PATH"]}/spec/fixtures/activitystreams/activity.json")

     expect(output_actor).to eq(actor_fixture)
     expect(output_activity).to eq(activity_fixture)
   end
  end

  describe "#profile_to_actor" do
    it "transforms FB profile into ActivityPub Actor JSON" do
      input_dir = "#{ENV["ROOT_PATH"]}/spec/fixtures/facebook"
      transformer = Transformer.new(input_dir: input_dir)

      transformer.profile_to_actor

      output_file = JSON.parse File.read(transformer.actor_path)
      fixture = JSON.parse File.read("#{ENV["ROOT_PATH"]}/spec/fixtures/activitystreams/actor.json")
      expect(output_file).to eq(fixture)
    end

    it "rejects nil fields" do
      input_dir = "#{ENV["ROOT_PATH"]}/spec/fixtures/facebook/profile_no_email.json"
      transformer = Transformer.new(input_dir: input_dir)

      transformer.profile_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/facebook/profile_no_email.json"
      transformer.actor_path = "#{ENV["ACTIVITYSTREAMS_OUTPUT_DIR"]}/actor_no_email.json"

      transformer.profile_to_actor

      output_file = JSON.parse File.read(transformer.actor_path)
      fixture = JSON.parse File.read("#{ENV["ROOT_PATH"]}/spec/fixtures/activitystreams/actor_no_email.json")
      expect(output_file).to eq(fixture)
    end
  end

  describe "#feed_to_activity" do
    it "converts feed into ActivityPub Activity JSON" do
      input_dir = "#{ENV["ROOT_PATH"]}/spec/fixtures/facebook"
      transformer = Transformer.new(input_dir: input_dir)

      transformer.feed_to_activity

      output_file = JSON.parse File.read(transformer.activity_path)
      fixture = JSON.parse File.read("#{ENV["ROOT_PATH"]}/spec/fixtures/activitystreams/activity.json")
      expect(output_file).to eq(fixture)
    end
  end
end