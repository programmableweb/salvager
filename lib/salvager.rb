require "dotenv/load"
require "koala"

Koala.configure do |config|
  config.access_token = ENV["USER_TOKEN"] || ENV["TEST_USER_ACCESS_TOKEN"]
  config.app_access_token = ENV["FACEBOOK_CLIENT_TOKEN"]
  config.app_id = ENV["FACEBOOK_APP_ID"]
  config.app_secret = ENV["FACEBOOK_APP_SECRET"]
end

class Salvager
  DEFAULT_DIR = "#{ENV["ROOT_PATH"]}/tmp"

  attr_reader :graph, :output_dir

  # Make sure your tokens have the right permissions set
  def initialize(output_dir: DEFAULT_DIR)
    @graph = Koala::Facebook::API.new
    @output_dir = output_dir
  end

  # Dump data to JSON files
  def dump
    path = File.join(DEFAULT_DIR, "activity.json")
    File.open(path, 'wb') do |file|
      feed = graph.get_connections("me", "posts?fields=event,link,message,name,privacy,created_time,description&limit=500")
      until feed.next_page.empty? do
        file.write feed.to_json
        feed = feed.next_page
      end
    end
  end
end