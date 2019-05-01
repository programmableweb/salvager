# Salvager

This project's aim is to allow you to regain ownership of your data from social media apps. It's an MVP, so it doesn't
do everything you might want. Right now, it pulls your feed, posts, profile, and albums/photos data and stores
everything locally in a machine readable format (JSON).

The next steps:

* Prefix all IDs with a source-specific identifier so that you can combine this data with other datasets (which
may have conflicting IDs)
* Include instructions for plugging your salvaged data into decentralized social web apps.
* Add web service API and replace Facebook URLS with API URLS
* Update tests to use Fake File System gem
* Stub Facebook requests in salvager specs

## Installing

### Installing with Docker
Make sure you have [Docker](https://www.docker.com) installed and running on your machine.

Clone this repo.

### Installing locally
Make sure Ruby 2.4.0 and the bundler gem are installed.

Clone this repo.

Run `bundle install` in terminal in the root of this directory.

## Using
You can either use our Facebook app (pending approval by FB), or make your own. The benefit of using our app is that if your friends also use and approve our app, the data that you can salvage will include posts from your friends. If you make your own, or your friends do not approve our app, then the data salvaged and transformed will inlude only content you've created.

### Using our Facebook app
We have created a Facebook app, also called "Salvager", which you can use to generate an access token for Facebook. 

1. Go to our app website: [https://salvager.glitch.me](https://salvager.glitch.me/)
2. Click the link to login, and then click the blue button to log in with Facebook.
3. Once you've returned to the salvager website, click to view your profile. You should see a field called "FB Access Token" with a long string value.
4. Copy this value and use it for the USER_TOKEN below.

### Making your own FB app
First, you need to set up the env variables. This involves getting a app id, app secret, and 
user OAuth token from the Facebook developer portal.

You can get these easily by signing up as a developer and creating an app. Once you've done this, you can retrieve your
 app ID and app secret from the new application's Settings page in the developer portal. 
 
Then, to get an OAuth token for your Facebook account, go to the [Graph Explorer](https://developers.facebook.com/tools/explorer/). Once you're in the Graph Explorer, make sure you select the application you just created. Then click "Get Token", then "Get User Access Token". Select the permissions for all the User Data Permissions as well as "user_events" under "Events, Groups & Pages", and then submit the form. The access token will then populate the Access Token text box in the main explorer view. Copy this and use it for the USER_TOKEN below.


### Once you have your user token

Create a `.env` file in the root of this project directory. See `.env.example.local` for an example.
Add the following variables to that file, inserting your own values:

    FACEBOOK_APP_ID=
    FACEBOOK_APP_SECRET=
    USER_TOKEN=
    ROOT_PATH=[path to current working directory]
    FACEBOOK_OUTPUT_DIR=
    ACTIVITYSTREAMS_OUTPUT_DIR=

#### With Docker

Be sure to set the env variables from above in your `.env` file. Check out the `.env.example.docker` file to get the path variables you'll need for the docker container. Copy the values for ROOT_PATH, FACEBOOK_OUTPUT_DIR, and ACTIVITYSTREAMS_OUTPUT_DIR 
from this file to the corresponding variables in your `.env` file.

Now, build the image. In command line in the root of this directory:

    # Build the image with the tag "salvager"
    docker build --tag=salvager .

Next, run the container, which by default uses the shell script in `script/salvage.sh` and both pulls the Facebook data 
and transforms it to ActivityStreams using `rake`:

    docker run -it --name salvager-script salvager  
    
    
This may take awhile depending on how much data you have, especially photos. Once this has stopped, your data 
now lives inside the docker container. If you want to save it and store it to your local machine, copy it over
to a directory of your choice (`/local/target`):
    
    docker cp salvager-script:/usr/src/app/tmp /local/target

#### Locally
You can run the entire script through a rake task. Open terminal and in the root of this project run: 

    rake salvage_tranform

This rake task is the same that's used in the docker container, but locally you also have access to other rake tasks: 

    # Just salvage the data from Facebook
    rake salvage
    
    # Transform already salvaged data into ActivityStreams
    rake transform


Alternatively, you can mess around with the Salvager Ruby object. In an interactive Ruby console (IRB):

    require './lib/salvager'
    require './lib/transformer'
    s = Salvager.new
    
    # You can access the graph directly through the `graph` object:
    s.graph.get_connections("me", "posts?fields=event,link,message,name,privacy,created_time,description,coordinates,source,likes&limit=200")
    
    # Dump all data to JSON files in tmp folder
    s.dump
     
    # Collect individual types of data
    s.collect_profile
    s.collect_albums
    
    # Transform the data to ActivityStreams
    Transform.run
    
You must get the profile data first before you can collect album data.

## Running the tests

Set up the tmp and necessary directories. These are all ignored by git. From the root of this project directory:

    mkdir tmp
    
    # FACEBOOK_OUTPUT_DIR
    mkdir tmp/facebook
    
    # ACTIVITYSTREAMS_OUTPUT_DIR
    mkdir tmp/activitystreams
    
Make sure that your .env is updated to use the above directories for the corresponding output dir variables. 
In the future we should stub these env variables or use a `.env.test` file.

Run `rspec spec` in terminal in the root of this directory.

Note: Currently the salvager specs fail due to incorrect assertions and because the requests to Facebook aren't stubbed.
 This is in the to-do list above.