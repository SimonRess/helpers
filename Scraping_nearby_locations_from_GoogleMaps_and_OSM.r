#------------------------------------------------------------------------------#
# Using "googleway" ####

library(dplyr)

install.packages("googleway")

library(googleway)

install.packages("geosphere") # compute distance between geographic (geodetic) coordinates.
library(geosphere)
distm(c(lon1, lat1), c(lon2, lat2), fun = distHaversine)

# Set your API key
api_key <- "AIzaSyAwfpYUfcvchN0eBisBPfrf93tFLptFtAs"

# Define the location you want to search for
my_location <- c(lat = 37.7749, lon = -122.4194)

my_location <- c(lat =51.474785963577936, lon =7.22554295376171) # Unistr.61


# Search for nearby places
nearby_places <- google_places(
  location = my_location,
  radius = 250, # search radius in meters
  key = api_key
)

# Extract relevant information
places_info <- data.frame(
  place_if = nearby_places$results$place_id,
  name = nearby_places$results$name,
  types = sapply(nearby_places$results$types, \(x) paste0(x, collapse = ";")),
  address = nearby_places$results$vicinity,
  lat = nearby_places$results$geometry$location$lat,
  lon = nearby_places$results$geometry$location$lng,
  dist = apply(cbind(places_info$lat, places_info$lon),1 , \(x) distm(my_location, c(x[1], x[2]), fun = distHaversine))
)

#Build "types"-dummies
all.location.types = strsplit(places_info$types, ";") %>% unlist() %>% unique()
for(t in all.location.types){
   g$places_info[t] <- grepl(t, places_info$types)
}


# A single query will return 20 results per page.
#-> You can view the next 20 results using the next_page_token that is returned as part of the initial query.
nearby_places_next <- google_places(
                          page_token = nearby_places$next_page_token,
                          location = my_location,
                          radius = 250, # search radius in meters
                          key = api_key)

# Extract relevant information
places_info2 <- data.frame(
  place_if = nearby_places_next$results$place_id,
  name = nearby_places_next$results$name,
  types = sapply(nearby_places_next$results$types, \(x) paste0(x, collapse = ";")),
  address = nearby_places_next$results$vicinity,
  lat = nearby_places_next$results$geometry$location$lat,
  lon = nearby_places_next$results$geometry$location$lng,
  dist = apply(cbind(nearby_places_next$lat, places_info$lon),1 , \(x) distm(my_location, c(x[1], x[2]), fun = distHaversine))
)



#------------------------------------------------------------------------------#
# Using "osmdata" ####


install.packages("osmdata")
library(osmdata)

date = "2010-10-28T19:20:00Z"

# List the features of OSM data
available_features()

available_tags(feature = "shop")

keys = c("shop")


call <- opq(bbox = c(7.223115,51.473516,7.227436,51.476207), datetime = date)  # c(12.4,55.5,12.8,55.9)) 
call <- add_osm_feature(call, key = keys) #%>% #,value=c("alcohol", "copyshop","general")
  #add_osm_feature(key ="foot")
response1 <- osmdata_sf(call)
response1$osm_points
response2$osm_points

# Extract relevant information
places_nearby <- data.frame(
  place_id = response$osm_points$osm_id,
  name = response$osm_points$name,
  type = response$osm_points$shop,
  lon = apply(as.data.frame(response$osm_points$geometry), 1, \(x) regmatches(x, gregexpr("\\(?(.*?)\\)", x))[[1]][1]) %>% as.numeric(),
  lat = apply(as.data.frame(response$osm_points$geometry), 1, \(x) regmatches(x, gregexpr("\\(?(.*?)\\)", x))[[1]][2]) %>% as.numeric()
)

# Add distance in "meter"
places_nearby$dist = apply(cbind(places_nearby$lat, places_nearby$lon), 1, \(x) distm(my_location, c(x[1], x[2]), fun = distHaversine))


#------------------------------------------------------------------------------#
# Using "overpass" ####

install.packages("devtools")
library("devtools")
devtools::install_github("hrbrmstr/overpass")
library(overpass)

osmcsv <- '[out:csv(::id,::type,"name")];
area[name="Bonn"]->.a;
( node(area.a)[railway=station];
  way(area.a)[railway=station];
  rel(area.a)[railway=station]; );
out;'

osmcsv <- '[out:csv(::id,::type,"name")];
area[name="Bonn"]->.a;
( node(area.a)[shop];);
out;'

osmcsv <- '[out:csv];
(
  node["shop"](7.223115,51.473516,7.227436,51.476207);
  way["shop"](7.223115,51.473516,7.227436,51.476207);
  relation["shop"](7.223115,51.473516,7.227436,51.476207);
);
out;
'

  osmcsv <- '[out:csv(::id,::type,"name")];
( nwr[shop](7.223115,51.473516,7.227436,51.476207););
out;'

  osmcsv <- '[out:json];  
  node[name="shop"]
  (47.065,15.425,47.07,15.43); // a bbox-filter
  out;'
  
  
  osmcsv <- '[out:json];
  node(around: 150, 51.474785963577936, 7.22554295376171)["shop"];
  out;'
  
  
  
  
#------------------------------------------------------------------------------#
# Create function "osm_nearby_locations" ####
  
  library("httr")
  
  #attributes
  date = "2022-10-28T19:20:00Z" # <- Format: YYYY-MM-DDThh:mm:ssZ (incl. "T" & "C") -> https://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_QL#Date
  features = c("amenity","building","emergency","office","shop") # List of features: https://wiki.openstreetmap.org/wiki/Map_features
  lat = "51.474785963577936"  # lat =51.474785963577936 & lon =7.22554295376171 => Unistr.61
  lon = "7.22554295376171"
  radius = "150" # in meter
  
  #newer/changed  # -> https://labs.mapbox.com/mapping/becoming-a-power-mapper/useful-overpass-queries/
  
  
  #http://overpass-turbo.eu/#
  
  
  
    overpass_base_url = "https://lz4.overpass-api.de/api/interpreter" # alternative: "https://overpass-api.de/api/interpreter"
  
  
  #  #build query
  #  osmcsv <- '[out:csv(::id,::lat,::lon,"name","amenity","shop"; true; ";")][date:"2022-10-28T19:20:00Z"];
  #  node(around: 150, 51.474785963577936, 7.22554295376171);
  #  out meta;'
  
  osm_nearby_locations = function(date = "2022-10-28T19:20:00Z", 
                                  features = c("amenity","building","emergency","office","shop"),
                                  lat = "51.474785963577936",
                                  lon = "7.22554295376171",
                                  radius = "150",
                                  overpass_base_url = "https://lz4.overpass-api.de/api/interpreter") {
    
    for(f in features) {
      query = paste0('[out:csv(::id,::lat,::lon,"name","',f,'"; true; "|")][date:"',date,'"];
      node["',f,'"](around: ',radius,', ',lat,', ',lon,');
      out meta;')
      
      
      cat("Downloading nodes: '", f, "'\n", sep="")
      res <- httr::POST(overpass_base_url, body = query)
      res = content(res, as = "text", encoding = "UTF-8")
      res = read.delim(text = res, sep="|", header=TRUE)
      if(length(res>0)){
        res$type = f
        paste(names(res))
        names(res) = c("id", "lat", "lon", "name", "subtype", "type")
        res = res[, c("id", "lat", "lon", "name", "type", "subtype")]
        res$dist = apply(cbind(res$lat, res$lon), 1, \(x) distm(c(as.numeric(lat),as.numeric(lon)), c(x[1], x[2]), fun = distHaversine))
        
        cat("adding data\n", sep="")
        if(!exists("output")) output = res else output = rbind(output, res)
        rm(res)
      } else cat("No data available for nodes: '", f, "'\n", sep="")
    }   
    
    return(output)
  }
  
  test = osm_nearby_locations(date = "2021-10-28T19:20:00Z", 
                           features = c("amenity","building","emergency","office","shop"),
                           lat = "51.474785963577936",
                           lon = "7.22554295376171",
                           radius = "150")
  
  test
  
  #source from github:
  source("https://raw.githubusercontent.com/SimonRess/osmscraper/main/functions.r")
  osm_nearby_locations()
  
  
  
  
#------------------------------------------------------------------------------#
# Other ####
    
osmcsv <- '[out:csv(::id,::type,"name"; true; ";")];
node(around: 150, 51.474785963577936, 7.22554295376171)["shop"];
out;'

osmcsv <- '[out:csv(::id,::lat,::lon,"name","amenity","shop"; true; ";")][date:"2022-10-28T19:20:00Z"];
node(around: 150, 51.474785963577936, 7.22554295376171);
out meta;'

opq <- overpass_query(osmcsv)
read.table(text = opq, sep=";", header=TRUE, 
           check.names=FALSE, stringsAsFactors=FALSE)



# Define the location you want to search for
my_location <- c(lat = 37.7749, lon = -122.4194)
# List the features of OSM data
available_features()my_location <- c(lat =51.474785963577936, lon =7.22554295376171) # Unistr.61

radius = 250
# Get bounding box for location
bb <- getbb(my_location, )

install.packages("sf")
library(sf)


#Define the bounding box
#bbb = getbb("portsmouth", display_name_contains = "United States")
bb <- st_buffer(st_point(my_location), radius) %>% st_bbox() %>% {data.frame(min=c(.[1],.[2]), max=c(.[3],.[4]), row.names = c("x", "y"))} %>% as.matrix()

bb = c(-198.5252, -242.7745,  301.4748,  257.2255) # bbox_to_string(

# Define the time range
date <- "2010-05-01T01:00:00Z"

q <- getbb ("New York City", display_name_contains = "United States") %>%
  opq () %>%
  add_osm_feature ("amenity", "restaurant") %>%
  add_osm_feature ("amenity", "pub")
osmdata_sf (q)

qa1 <- getbb ("Catalan Countries") %>% #, format_out = "osm_type_id"
  opq (nodes_only = TRUE) %>%
  add_osm_feature (key = "capital", value = "4")
a = osmdata_sf(qa1)
a$osm_points



# Download the OHM data
#sf::st_bbox(c(xmin = -198.5252, xmax = -242.7745, ymax = 301.4748, ymin = 257.2255))
c 
ohm_data <- opq(bbox = c, nodes_only = TRUE) %>% #, datetime = date
  add_osm_feature("amenity", "restaurant") %>%
  osmdata_sf()

# Extract only places
places <- ohm_data$osm_points %>% filter(osm_feature %in% c("cafe", "restaurant", "bar"))

# View the resulting places data
places

#using the st_point() function from sf to create a point object from the center coordinates, and then using the st_buffer() function to create a buffer around the point with the specified radius in meters. Finally, we are passing the resulting polygon to the opq() function from osmdata to define the bounding box, and using the get_bbox() function to extract the bounding box coordinates.
bb <- opq(bbox = st_buffer(st_point(my_location), radius))$get_bbox()
osm_query <- opq(bbox = bb) %>% 
  add_osm_feature("amenity", "restaurant")

# Retrieve OSM data as sf object
osm_data <- osmdata_sf(osm_query)


# Extract relevant information
places_info <- data.frame(
  name = osm_data$osm_points$name,
  address = osm_data$osm_points$addr_full,
  lat = osm_data$osm_points$lat,
  lon = osm_data$osm_points$lon
)


# Convert date string to Date object
date <- as.Date("2020-01-01")

# Get file path for OSM archive file
file_path <- osh_file(date)

osm_data <- osmdata_download(
  bbox = bb,
  timestamp = date,
  timeout = 60,
  node_attrs = c("name", "addr:full")
)

# Retrieve OSM data as sf object
osm_data <- osmdata_sf(file = file_path, bbox = bb, node_attrs = c("name", "addr:full"))






#######################################################
install.packages("ggmap")

library(ggmap)

# Set your API key
register_google(key = "AIzaSyA4JYV4lv77Hl8o6g0xzqBdPTY3XSjFaUg")

# Define the location you want to search for
my_location <- c(lat = 37.7749, lon = -122.4194)

# Download Google Map image
map <- get_map(location = my_location, zoom = 15)

# Plot the map image
ggmap(map)

# Search for nearby places
nearby_places <- nearby(location = my_location, radius = 1000, type = "restaurant")

# Extract relevant information
places_info <- data.frame(
  name = sapply(nearby_places$results, "[[", "name"),
  address = sapply(nearby_places$results, "[[", "vicinity"),
  lat = sapply(nearby_places$results, "[[", "geometry", "location", "lat"),
  lon = sapply(nearby_places$results, "[[", "geometry", "location", "lng")
)
