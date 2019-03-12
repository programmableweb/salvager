require "spec_helper"
require_relative "#{ENV["ROOT_PATH"]}/lib/salvager"

describe Salvager do
  describe "#dump" do
    it "dumps facebook posts data to a json file" do
      salvager = Salvager.new
      salvager.dump


      output = File.read "#{ENV["ROOT_PATH"]}/tmp/activity.json"
      expect(output.length).to eq(24)
    end
  end
end