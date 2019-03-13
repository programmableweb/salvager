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

 #  curl -i -X GET \
 # "https://graph.facebook.com/v3.2/me?fields=about%2Cemail%2Cid%2Cgender%2Chometown%2Cfirst_name%2Clast_name%2Ceducation%2Clocation%2Clink%2Clanguages%2Cmiddle_name%2Cpublic_key%2Creligion%2Cwebsite%2Calbums%7Bid%2Cname%2Clink%2Ccreated_time%2Cphoto_count%2Cphotos%7Bname%2Clink%2Cid%2Cpicture%2Cinsights%7Bdescription%2Cid%2Ctitle%7D%7D%2Ccover_photo%2Cdescription%2Cupdated_time%2Cprivacy%2Clocation%7D&access_token=EAAFcnbTD4tcBAHFDZBcLI5keZBuNNnZCaUkHNE2zeF89L04bzgVZBA6iL8ZB6K08EIJ9jjJigZBGfcpm9xjcj9fJy0DZCWLXdOScBU4RG1xdJJmcrhUF6ZCZCRjjwtUZBvblzNxaQQiw1UuJmmxHChtZAZCvXNHqfAb0ZADDSI2D9viKcAKvLZBm8aWpZAyTHEjPEmzwkMZD"

  # Dump data to JSON files
  # TODO prefix all IDs with "fb-" (or do this elsewhere)
  def dump
    # Profile / Actor
    collect_profile

    # Timeline posts
    collect_posts

    # Photos
    collect_albums

    # Friends
    # can these names be plugged into an API or Webfinger?

    # Events
    # me?fields=events{id,name,owner,rsvp_status,description,category,cover,picture,start_time,posts,end_time,place,noreply_count,maybe_count,interested_count,declined_count,attending_count,timezone,type,photos}

    # Feed
    # Can we convert feed into ActivityPub easily?
    # me?fields=feed{id,from,description,name,message,backdated_time,caption,call_to_action,coordinates,created_time,event,place,privacy,picture,parent_id,object_id,permalink_url,properties,story,status_type,source,shares,to{id,name},target,type,updated_time,comments{id,message,created_time,message_tags},likes{id,name}}
  end

  def collect_posts
    path = File.join(output_dir, "activity.json")
    File.open(path, 'wb') do |file|
      feed = graph.get_connections("me", "posts?fields=event,link,message,name,privacy,created_time,description&limit=500")
      until feed.next_page.empty? do
        file.write feed.to_json
        feed = feed.next_page
      end
    end
  end

  def collect_profile
    path = File.join(output_dir, "actor.json")
    File.open(path, 'wb') do |file|
      profile = graph.get_object("me?fields=about,email,id,gender,hometown,first_name,last_name,languages,link,location,address,birthday,age_range,education,name,name_format,middle_name,political,website")
      file.write profile.to_json
    end
  end

  def collect_albums
    albums_dir = "#{output_dir}/albums"
    ensure_dir_exists(albums_dir)

    # Set limit at 500 because does anyone really have more than 500 albums?
    albums = graph.get_connections("me", "albums?limit=500")
    # me?fields=about,email,id,gender,hometown,first_name,last_name,education,location,languages,middle_name,public_key,religion,website,albums{id,name,created_time,photo_count,photos{name,link,id,images,backdated_time,event,from,created_time,place,name_tags,target,updated_time,comments{id,from,message}},cover_photo,description,updated_time,privacy,location,event,from,backdated_time,place,type,video_count,is_user_facing,likes{id,name},comments{id,from,created_time,message}}

    # curl -i -X GET \
    # "https://graph.facebook.com/v3.2/me?fields=about%2Cemail%2Cid%2Cgender%2Chometown%2Cfirst_name%2Clast_name%2Ceducation%2Clocation%2Clanguages%2Cmiddle_name%2Cpublic_key%2Creligion%2Cwebsite%2Calbums%7Bid%2Cname%2Ccreated_time%2Cphoto_count%2Cphotos%7Bname%2Clink%2Cid%2Cimages%2Cbackdated_time%2Cevent%2Cfrom%2Ccreated_time%2Cplace%2Cname_tags%2Ctarget%2Cupdated_time%2Ccomments%7Bid%2Cfrom%2Cmessage%7D%7D%2Ccover_photo%2Cdescription%2Cupdated_time%2Cprivacy%2Clocation%2Cevent%2Cfrom%2Cbackdated_time%2Cplace%2Ctype%2Cvideo_count%2Cis_user_facing%2Clikes%7Bid%2Cname%7D%2Ccomments%7Bid%2Cfrom%2Ccreated_time%2Cmessage%7D%7D&access_token=EAAFcnbTD4tcBAHFDZBcLI5keZBuNNnZCaUkHNE2zeF89L04bzgVZBA6iL8ZB6K08EIJ9jjJigZBGfcpm9xjcj9fJy0DZCWLXdOScBU4RG1xdJJmcrhUF6ZCZCRjjwtUZBvblzNxaQQiw1UuJmmxHChtZAZCvXNHqfAb0ZADDSI2D9viKcAKvLZBm8aWpZAyTHEjPEmzwkMZD"

    albums.each do |album|
      # Create dir for individual album
      dir_name = albums_dir + "/" + album["id"]
      ensure_dir_exists(dir_name)

      # Store album info as album.json
      # include data about the photos
      path = File.join(output_dir, "activity.json")
      File.open(path, 'wb') do |file|
        album_data = {}
        file.write album_data
      end

      # Save images
      images_dir = dir_name + "/images"
      ensure_dir_exists(images_dir)
      album["photos"].each do |photo|
        # Just save first image because it's the biggest
        save_image(photo["id"], photo["images"][0]["source"], images_dir)
      end
    end
  end

  private

  def ensure_dir_exists(dir)
    Dir.mkdir(dir) unless File.directory?(dir)
  end

  def save_image(id, source, dir)
    uri  = URI.parse(source)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = params[:src].include?('https')

    # TODO May need to add access token or use Koala
    response = http.request(
      Net::HTTP::Get.new(uri.request_uri, {
        "User-Agent" => "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0"
      })
    )

    image_filename = dir + "/#{id}.jpg"
    File.open(image_filename, 'wb') { |f| f.write(response.body) }
  end
end