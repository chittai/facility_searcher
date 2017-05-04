class ToppagesController < ApplicationController
  def index
    
    @keyword=params[:keyword]
    place = []
    @googleapi_key = ENV['GOOGLEMAP_API_KEY']
    
    if @keyword.present?
      search_key = @keyword
      googlemap_api_key = 'AIzaSyBz0hP0fVRtpLY3-oNmAmzYVDvGd6pfG84'
      @types = 'convenience_store'
      
      Geocoder.configure(language: :ja, units: :km)
      @search_address = Geocoder.address(search_key)
        #検索した場所のアドレス
      lat = Geocoder.search(search_key)[0].geometry['location'].values[0]
        #latitude
      lng = Geocoder.search(search_key)[0].geometry['location'].values[1]
        #longitude
      t1 = Geocoder.search(search_key)[0].geometry['location'].values.join(',')
        #検索した場所の緯度と経度を格納する
      
      uri = URI.parse "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat},#{lng}&types=#{@types}&sensor=false&rankby=distance&language=ja&key=#{googlemap_api_key}"
      
      request = Net::HTTP::Get.new(uri.request_uri)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
      
      body = JSON.parse(response.body)
      results = body['results']
      place =  results.first
      location = place['geometry']['location']
      lat_search, lng_search = location['lat'], location['lng']
      @search_address_to = Geocoder.address("#{lat_search},#{lng_search}")
      @place_name = place['name']
      @distance = Geocoder::Calculations.distance_between(t1,"#{lat_search},#{lng_search}").round(3)*1000
      
      p "from: #{@search_address}"
      p "to: #{place['name']}: #{place['address']}"
      p "types - #{@types}"
      p "distance - #{@distance}m"
      
      @hash = [{ lat: lat_search, lng: lng_search, infowindow: "", title: ""}]
      p @hash
      
    else
    end
  end
end
