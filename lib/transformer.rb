require "dotenv/load"
require "json"

class Transformer
  DEFAULT_DIR = "#{ENV["ROOT_PATH"]}/tmp"
  attr_reader :profile_path, :actor_path

  # TODO accept output and input dirs as args
  # TODO convert IDs to # urn:x-facebook:{id}
  def initialize(profile_path:, actor_path: nil)
    @profile_path = profile_path || DEFAULT_DIR + "/profile.json"
    @actor_path = actor_path || DEFAULT_DIR + "/actor.json"
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

  # TODO
  def feed_to_activity

  end

  # TODO
  def albums_to_activity

  end
end