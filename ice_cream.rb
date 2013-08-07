require 'rest-client'
require 'json'
require 'addressable/uri'
require 'nokogiri'

request = Addressable::URI.new(
   :scheme => "http",
   :host => "maps.googleapis.com",
   :path => "maps/api/geocode/json",
   :query_values => {
     :address => '1061 Market Street San Francisco CA',
     :sensor => false
   }
 ).to_s
response = RestClient.get(request)

current_location = JSON.parse(response)
lat = current_location["results"].first["geometry"]["location"]["lat"]
lng = current_location["results"].first["geometry"]["location"]["lng"]

api_key = "AIzaSyA66ICFWBJETRarUkcFC69hbGyLVdzgDLY"

request = Addressable::URI.new(
   :scheme => "https",
   :host => "maps.googleapis.com",
   :path => "maps/api/place/nearbysearch/json",
   :query_values => {
     :key => api_key,
     :location => "#{lat},#{lng}",
     :sensor => false,
     :radius => 1000,
     :query => "icecream"
   }
 ).to_s

response = RestClient.get(request)
parsed_response = JSON.parse(response)
icecream_shops = parsed_response["results"]

icecream_locations = icecream_shops.collect do |shop|
  icecream_shop = {}
  icecream_shop[:name] = shop["name"]
  icecream_shop[:lat] = shop["geometry"]["location"]["lat"]
  icecream_shop[:lng] = shop["geometry"]["location"]["lng"]
  icecream_shop
end

icecream_locations.each_with_index do |shop, index|
  print index,' ',shop[:name]
  puts
end

puts "Choose a place:"
shop_number = gets.chomp.to_i


# DIRECTIONS

request = Addressable::URI.new(
   :scheme => "https",
   :host => "maps.googleapis.com",
   :path => "maps/api/directions/json",
   :query_values => {
     :origin => "#{lat},#{lng}",
     :destination =>"#{icecream_locations[shop_number][:lat]},#{icecream_locations[shop_number][:lng]}",
     :sensor => false
   }
 ).to_s

response = RestClient.get(request)
parsed_response = JSON.parse(response)

directions = []
parsed_response["routes"].first["legs"].first["steps"].each do |step|
  directions << Nokogiri::HTML(step["html_instructions"])
end

puts
directions.each do |step|
  puts step.text
end






