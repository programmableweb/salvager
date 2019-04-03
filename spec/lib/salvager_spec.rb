require "spec_helper"
require_relative "#{ENV["ROOT_PATH"]}/lib/salvager"

describe Salvager do
  describe "#collect_profile" do
    it "dumps facebook profile data to a json file" do
      salvager = Salvager.new
      salvager.collect_profile


      output = File.read "#{ENV["FACEBOOK_OUTPUT_DIR"]}/profile.json"
      expect(output.length).to eq(24)
    end
  end

  describe "#collect_posts" do
    it "dumps facebook posts data to a json file" do
      salvager = Salvager.new
      salvager.collect_posts


      output = File.read "#{ENV["FACEBOOK_OUTPUT_DIR"]}/posts.json"
      expect(output.length).to eq(24)
    end
  end
end