# Salvager

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
In a terminal:

    require './lib/salvager'
    s = Salvager.new
    
    # Get the first page of posts
    s.graph.get_connections("me", "posts?fields=event,link,message,name,privacy,created_time,description,coordinates,source,likes&limit=200")
    
    # Dump posts data to JSON file in tmp folder
     s.dump

## Running the tests

Run `rspec spec` in terminal in the root of this directory.