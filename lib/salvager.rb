require "dotenv/load"
require "koala"
require "pry"

Koala.configure do |config|
  config.access_token = ENV["USER_TOKEN"]
  config.app_id = ENV["FACEBOOK_APP_ID"]
  config.app_secret = ENV["FACEBOOK_APP_SECRET"]
end

class Salvager
  DEFAULT_DIR = "#{ENV["ROOT_PATH"]}/tmp"

  attr_reader :graph, :output_dir, :me_id

  def self.run(args={})
    new(args).dump
  end

  # Make sure your tokens have the right permissions set
  def initialize(output_dir: nil)
    @graph = Koala::Facebook::API.new
    @output_dir = output_dir || ENV["FACEBOOK_OUTPUT_DIR"] || DEFAULT_DIR
    @me_id = nil # this gets set during #collect_profile
  end

  # Dump data to JSON files
  def dump
    # Profile / Actor
    collect_profile

    # Feed of activity
    collect_feed

    # Timeline posts (may be redundant with feed, but I feel like being explicit)
    collect_posts

    # ALbums and their photos
    collect_albums

    # Friends
    # can these names be plugged into an API or Webfinger?

    # Events
    # me?fields=events{id,name,owner,rsvp_status,description,category,cover,picture,start_time,posts,end_time,place,noreply_count,maybe_count,interested_count,declined_count,attending_count,timezone,type,photos}
  end

  def collect_profile
    profile = graph.get_object("me?fields=about,email,id,gender,hometown,first_name,last_name,languages,link,location,address,birthday,age_range,education,name,name_format,middle_name,political,website")
    @me_id = profile["id"]

    path = File.join(output_dir, "profile.json")
    File.open(path, 'wb') do |file|
      file.write profile.to_json
    end
  end

  def collect_posts
    feed = graph.get_connections("me", "posts?fields=id,from{id,link,name},to{id,name},event,link,message,name,privacy,created_time,description&limit=500")
    path = File.join(output_dir, "posts.json")

    File.open(path, 'wb') do |file|
      loop_through_feed(file, feed)
    end
  end

  def collect_feed
    feed = graph.get_connections("me", "feed?fields=id,from{id,link,name},link,description,name,message,backdated_time,caption,call_to_action,coordinates,created_time,event,place,privacy,picture,parent_id,object_id,permalink_url,properties,story,status_type,source,shares,to{id,name},target,type,updated_time&limit=500")

    path = File.join(output_dir, "feed.json")
    File.open(path, 'wb') do |file|
      loop_through_feed(file, feed)
    end
  end

  def collect_albums
    return unless @me_id

    albums = graph.graph_call("/#{@me_id}/albums?fields=id,name,created_time,photo_count,photos{name,link,id,images,backdated_time,event,from,created_time,place,name_tags,target,updated_time,comments{id,from,message}},cover_photo,description,updated_time,privacy,location,event,from,backdated_time,place,type,video_count,is_user_facing,likes{id,name},comments{id,from,created_time,message}&limit=150")

    path = File.join(output_dir, "albums.json")
    File.open(path, 'wb') do |file|
      loop_through_feed(file, albums, :download_pics)
    end
  end

  private

  def ensure_dir_exists(dir)
    Dir.mkdir(dir) unless File.directory?(dir)
  end

  def save_image(id, source, dir)
    uri  = URI.parse(source)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = source[0..4] == "https"

    response = http.request(
      Net::HTTP::Get.new(uri.request_uri, {
        "User-Agent" => "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0"
      })
    )

    image_filename = dir + "/#{id}.jpg"
    File.open(image_filename, 'wb') { |f| f.write(response.body) }
  end

  def loop_through_feed(file, feed, additional_action=nil)
    file.write "["
    until feed.nil? or feed.empty?
      str = feed.to_json

      # Don't include brackets of array
      file.write str[1...-1]

      if additional_action
        send(additional_action, feed: feed)
      end

      feed = feed.next_page
      unless feed.nil? or feed.empty?
        file.write ","
      end
    end
    file.write "]"
  end


  # Download album images locally
  def download_pics(feed: [])
    albums_dir = "#{output_dir}/albums"
    ensure_dir_exists(albums_dir)

    feed.each do |album|

      # Create dir for individual album in "albums" dir
      single_album_dir = albums_dir + "/" + album["id"]
      ensure_dir_exists(single_album_dir)

      # Make sure this album has photos
      # Save an empty dir regardless to be explicit that there are no photos
      next unless album["photos"] && album["photos"]["data"]

      # Save images
      album["photos"]["data"].each do |photo|
        # Just save first image because it's the biggest
        save_image(photo["id"], photo["images"][0]["source"], single_album_dir)
      end
    end
  end
end