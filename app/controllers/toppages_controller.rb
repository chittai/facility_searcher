class ToppagesController < ApplicationController
  include ToppagesHelper
  
  def index
    
    @keyword=params[:keyword]
    @googleapi_key = ENV['GOOGLEMAP_API_KEY']
    
    if @keyword.present?
      
      facility_search(@keyword, @googleapi_key)
      
      search_key = @keyword
      
      Geocoder.configure(language: :ja, units: :km)
      
      #検索したい場所の住所
      @search_address = Geocoder.address(search_key)
      
      #検索した場所の緯度経度
      @lat = Geocoder.search(search_key)[0].geometry['location'].values[0]
      @lng = Geocoder.search(search_key)[0].geometry['location'].values[1]
      
      #検索した場所の緯度と経度をt1に格納する
      t1 = Geocoder.search(search_key)[0].geometry['location'].values.join(',')
      
      #GoogleMAP APIを使用するためのURI情報
      uri = URI.parse "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@lat},#{@lng}&types=#{@types}&sensor=false&rankby=distance&language=ja&key=#{@googleapi_key}"
      uri_second = URI.parse "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@lat},#{@lng}&types=#{@types_second}&sensor=false&rankby=distance&language=ja&key=#{@googleapi_key}"
      uri_third = URI.parse "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@lat},#{@lng}&types=#{@types_third}&sensor=false&rankby=distance&language=ja&key=#{@googleapi_key}"
      
      #コンビニ検索用のrequest/response
      request = Net::HTTP::Get.new(uri.request_uri)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
      
      #電車の駅検索用のrequest/response
      request_second = Net::HTTP::Get.new(uri_second.request_uri)
      response_second = Net::HTTP.start(uri_second.host, uri_second.port, use_ssl: uri_second.scheme == 'https') do |http|
        http.request(request_second)
      end
      
      #病院の駅検索用のrequest/response
      request_third = Net::HTTP::Get.new(uri_third.request_uri)
      response_third = Net::HTTP.start(uri_third.host, uri_third.port, use_ssl: uri_third.scheme == 'https') do |http|
        http.request(request_third)
      end
      
      
      #コンビニのJSON
      body = JSON.parse(response.body)
      results = body['results']
      
      #駅のJSON
      body_second = JSON.parse(response_second.body)
      results_second = body_second['results']
      
      #病院のJSON
      body_third = JSON.parse(response_third.body)
      results_third = body_third['results']
      
      #コンビニで最も近いコンビニの情報を取得して処理する
      place =  results.first
      location = place['geometry']['location']
      @lat_search, @lng_search = location['lat'], location['lng']
      @search_address_to = Geocoder.address("#{@lat_search},#{@lng_search}")
      @place_name = place['name']
      @distance = Geocoder::Calculations.distance_between(t1,"#{@lat_search},#{@lng_search}").round(3)*1000
      
      #駅で最も近い役の情報を取得して処理する
      place_second =  results_second.first
      location_second = place_second['geometry']['location']
      @lat_search_station, @lng_search_station = location_second['lat'], location_second['lng']
      @search_address_to_station = Geocoder.address("#{@lat_search_station},#{@lng_search_station}")
      @place_name_station = place_second['name']
      @distance_station = Geocoder::Calculations.distance_between(t1,"#{@lat_search_station},#{@lng_search_station}").round(3)*1000
      
      #病院で最も近い役の情報を取得して処理する
      place_third =  results_third.first
      location_third = place_third['geometry']['location']
      @lat_search_hospital, @lng_search_hospital = location_third['lat'], location_third['lng']
      @search_address_to_hospital = Geocoder.address("#{@lat_search_hospital},#{@lng_search_hospital}")
      @place_name_hospital = place_third['name']
      @distance_hospital = Geocoder::Calculations.distance_between(t1,"#{@lat_search_hospital},#{@lng_search_hospital}").round(3)*1000
      
      puts '====='
      p "from: #{@search_address_to_hospital}"
      p "to: #{place_third['name']}: #{place_third['address']}"
      p "types - #{@types_third}"
      p "distance - #{@distance_hospital}m"
      
      @hash = [{ lat: @lat_search, lng: @lng_search, infowindow: "", title: ""},{lat: @lat, lng: @lng, infowindow: "", title: ""},{ lat: @lat_search_station, lng: @lng_search_station, infowindow: "", title: ""},{ lat: @lat_search_hospital, lng: @lng_search_hospital, infowindow: "", title: ""}]
      p @hash
      
    else
    end
  end
end
