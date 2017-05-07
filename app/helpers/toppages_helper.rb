module ToppagesHelper
  def facility_search(keyword, googleapi_key)
    search_key = keyword
    
    #検索したい施設のタイプ情報
    @types = 'convenience_store'
    @types_second = 'train_station'
    @types_third = 'hospital'
    
    Geocoder.configure(language: :ja, units: :km)
    
    #検索したい場所の住所
    @search_address = Geocoder.address(search_key)
    
    #検索した場所の緯度経度
    @lat = Geocoder.search(search_key)[0].geometry['location'].values[0]
    @lng = Geocoder.search(search_key)[0].geometry['location'].values[1]
    
    #検索した場所の緯度と経度をt1に格納する
    t1 = Geocoder.search(search_key)[0].geometry['location'].values.join(',')
      
    #GoogleMAP APIを使用するためのURI情報
    uri = URI.parse "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@lat},#{@lng}&types=#{@types}&sensor=false&rankby=distance&language=ja&key=#{googleapi_key}"
    uri_second = URI.parse "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@lat},#{@lng}&types=#{@types_second}&sensor=false&rankby=distance&language=ja&key=#{googleapi_key}"
  
  end
end