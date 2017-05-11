module ToppagesHelper
  def facility_search(keyword, googleapi_key)

    search_key = keyword

    @types_array = [params[:facility_first],params[:facility_second],params[:facility_third]]
    #@types_array = ['convenience_store','train_station','hospital']
    
    @types = 'convenience_store'
    @types_second = 'train_station'
    @types_subway_station = 'subway_station'
    @types_third = 'hospital'
    
    #検索したい場所の住所
    @search_address = Geocoder.address(search_key)
  
    #検索した場所の緯度経度
    @lat = Geocoder.search(search_key)[0].geometry['location'].values[0]
    @lng = Geocoder.search(search_key)[0].geometry['location'].values[1]
    #検索した場所の緯度と経度をt1に格納する
    @t1 = Geocoder.search(search_key)[0].geometry['location'].values.join(',')

    @uri_array = [] 
    @types_array.each do |type|
      uri = URI.parse "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@lat},#{@lng}&types=#{type}&sensor=false&rankby=distance&language=ja&key=#{@googleapi_key}"
      @uri_array << uri
    end
    
    #GoogleMAPj上にMarkerを配置するための@hashを初期化している。
    #初期化時に検索した住所の情報を格納
    @hash = [{lat: @lat, lng: @lng, infowindow: "", title: ""}]
    
    #各施設の情報を格納View側で情報を表示するため
    @facility_information = []
    
    #GoogleMAP APIを使用するためのURI情報使用して、JSONをとってくる
    #URIは@uri_arrayに配列として格納
    @uri_array.each do |uri|
      request = Net::HTTP::Get.new(uri.request_uri)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end  
      
      #取得した結果からJSONの情報を抜き出す
      body = JSON.parse(response.body)
      results = body['results']
      
      #JSONの情報から必要な情報を抜き出す
      #最も近い施設
      place =  results.first
      location = place['geometry']['location']
      #緯度・経度
      @lat_search, @lng_search = location['lat'], location['lng']
      #住所
      @search_address_to = Geocoder.address("#{@lat_search},#{@lng_search}")
      #施設名
      @place_name = place['name']
      #検索した住所から施設までの距離(m)
      @distance = Geocoder::Calculations.distance_between(@t1,"#{@lat_search},#{@lng_search}").round(3)*1000
      
      @facility_information << {address: @search_address_to, name: @place_name, distance: @distance}
      
      @hash << { lat: @lat_search, lng: @lng_search, infowindow: "", title: ""}
    end  
    
    def type_searcher(type)
      @types_list = {'convenience_store' => 'コンビニエンスストア', 'train_station' => '駅', 'hospital' => '病院'}
      return @types_list[type]
    end
      
    def calScore(distance)
      @facility_score = 0
      
      if 0 <= distance && distance < 100
        @facility_score = 100
      elsif 100 <= distance && distance < 200 
        @facility_score = 90
      elsif 200 <= distance && distance < 300
        @facility_score = 80
      elsif 300 <= distance && distance < 400
        @facility_score = 70
      elsif 400 <= distance && distance < 500
        @facility_score = 60
      elsif 500 <= distance && distance < 600
        @facility_score = 50
      elsif 600 <= distance && distance < 700
        @facility_score = 40
      elsif 700 <= distance && distance < 800
        @facility_score = 30
      elsif 800 <= distance && distance < 900
        @facility_score = 20
      elsif 900 <= distance && distance < 1000
        @facility_score = 10
      else
        @facility_score = 0
      end
    end
    
    
    def calCoefficien(index)
      
      @coefficient = 0
      
      case index
      when 0 then
        @coefficient = 5
      when 1 then
        @coefficient = 2
      when 2 then
        @coefficient = 1
      else
      end
    end
      
  end
end