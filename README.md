# Salvager

This project's aim is to allow you to regain ownership of your data from social media apps. It's an MVP, so it doesn't
do everything you might want. Right now, it pulls your feed, posts, profile, and albums/photos data and stores
everything locally in a machine readable format (JSON).

The next steps:

* Convert the JSON to standardized format for interoperability
* Prefix all IDs with a source-specific identifier so that you can combine this data with other datasets (which
may have conflicting IDs)
* Include instructions for plugging your salvaged data into decentralized social web apps.
* Dockerize

## Installing

### Installing with Docker

### Installing locally
Make sure Ruby 2.2.1 and the bundler gem are installed.

Clone this repo.

Run `bundle install` in terminal in the root of this directory.

Set up the env variables:

Create a `.env` file in the root of this project directory.
Add the following variables to that file, inserting your own values:

    FACEBOOK_APP_ID=
    FACEBOOK_APP_SECRET=
    FACEBOOK_CLIENT_TOKEN=
    USER_TOKEN=
    TEST_USER_ACCESS_TOKEN=
    ROOT_PATH=[path to current working directory]


## Using

### With Docker

### Locally
You can run the entire script through a rake task. Open terminal and in the root of this project run: `rake salvage`.

Alternatively, you can mess around with the Salvager Ruby object. In an interactive Ruby console (IRB):

    require './lib/salvager'
    s = Salvager.new
    
    # You can access the graph directly through the `graph` object:
    s.graph.get_connections("me", "posts?fields=event,link,message,name,privacy,created_time,description,coordinates,source,likes&limit=200")
    
    # Dump all data to JSON files in tmp folder
    s.dump
     
    # Collect individual types of data
    s.collect_profile
    s.collect_albums
    
You must get the profile data first before you can collect album data.

## Running the tests

Run `rspec spec` in terminal in the root of this directory.