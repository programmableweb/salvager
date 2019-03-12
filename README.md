# Salvager

## Installing


## Using

In a terminal:

    require './lib/salvager'
    s = Salvager.new
    
    # Get the first page of posts
    s.graph.get_connections("me", "posts?fields=event,link,message,name,privacy,created_time,description,coordinates,source,likes&limit=200")
    
    # Dump posts data to JSON file in tmp folder
     s.dump

