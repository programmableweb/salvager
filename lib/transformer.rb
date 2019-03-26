require "dotenv/load"
require "json"

class Transformer
  DEFAULT_DIR = "#{ENV["ROOT_PATH"]}/tmp"
  attr_accessor :profile_path, :actor_path, :feed_path, :activity_path

  def self.run(args={})
    transformer = new(args)
    transformer.profile_to_actor
    transformer.feed_to_activity
  end

  def initialize(input_dir: nil, output_dir: nil)
    input_path = input_dir || ENV["SALVAGER_OUTPUT_DIR"] || DEFAULT_DIR
    output_path = output_dir || ENV["TRANSFORMER_OUTPUT_DIR"] || DEFAULT_DIR

    @profile_path = input_path + "/profile.json" # File.join()
    @actor_path = output_path + "/actor.json"
    @feed_path = input_path + "/feed.json"
    @activity_path = output_path + "/activity.json"
  end

  # TODO check on anything else to be pulled
  def profile_to_actor
    profile = JSON.load File.read(profile_path)

    actor_hash = {
      "@context": [
        "https://www.w3.org/ns/activitystreams",
        {"vcard": "http://www.w3.org/2006/vcard/ns#"}
      ],
      "type": ["Person", "vcard:Individual"],
      "id": profile["link"],
      "name": profile["name"],
      "vcard:given-name": profile["first_name"],
      "vcard:family-name": profile["last_name"],
      "hasEmail": profile["email"],
      "birthday": profile["birthday"]
    }

    actor_hash.reject! { |k,v| v.nil? }

    File.open(actor_path, 'wb') do |file|
      file.write actor_hash.to_json
    end
  end

  # This won't be great in the long-term for memory or performance
  def feed_to_activity
    feed = JSON.load File.read(feed_path)
    feed_size = feed.size

    File.open(activity_path, 'wb') do |file|
      # Write Collection elements
      file.write "{" +
        "\"@context\": \"https://www.w3.org/ns/activitystreams\"," +
        "\"summary\": \"Facebook Activity Feed\"," +
        "\"type\": \"Collection\"," +
        "\"totalItems\": #{feed_size}," +
        "\"items\": ["

      last_item_index = feed_size - 1
      feed.each_with_index do |item, index|
        activity_item = {
          "@context": "https://www.w3.org/ns/activitystreams",
          "summary": summary(item),
          "type": "Create",
          "published": item["created_time"],
          "actor": { # Can't set a type for Actor because it could be an organization, group, or non-person entity
            "id": item.dig("from", "link"),
            "facebookID": item.dig("from", "id"),
            "name": item.dig("from", "name"),
          },
          "audience": {
            "name": item.dig("privacy", "value"),
            "description": item.dig("privacy", "description")
          },
        }.merge(item_object(item))
        file.write activity_item.to_json
        file.write "," unless index == last_item_index
      end

      file.write "]}"
    end
  end

  # TODO
  def albums_to_activity; end

  private

  def summary(item)
    name = item.dig("from", "name") || "Someone"

    # status_type can be nil
    # type appears to be any one of the following: ["status", "photo", "link", "video"]
    status = item["status_type"].nil? ? item["type"] : item["status_type"].tr("_", " ")
    article = ["a", "e", "i", "o", "u"].include?(status[0]) ? "an" : "a"
    status_string = article + " " + status
    status_string += " update" unless status_string.include?("update")

    "#{name} shared #{status_string}"
  end

  # TODO use place and location data
  def item_object(item)
    obj = {
      "id": item["permalink_url"],
      "facebookID": item["id"],
      "type": item["type"].capitalize,
      "name": item["name"],
      "content": item["message"],
      "picture": item["picture"],
      "caption": item["caption"],
      "description": item["description"] || item["story"], # I don't have any examples of both existing on same item
      "url": interpret_url(item),
      "updated": item["updated_time"]
    }

    obj.reject! { |k,v| v.nil? }
    { "object": obj }
  end

  def interpret_url(item)
    item["link"] || item["source"] || cta_link(item)
  end

  def cta_link(item)
    item.dig "call_to_action", "value", "link"
  end
end