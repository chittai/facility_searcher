class ToppagesController < ApplicationController
  include ToppagesHelper
  
  def index
    
    #検索ワードを@keywordに格納
    @keyword=params[:keyword]
    
    @googleapi_key = ENV['GOOGLEMAP_API_KEY']
    
    if @keyword.present?
      Geocoder.configure(language: :ja, units: :km)
      
      #toppages_helperに記載されているfacility_searchを呼び出し
      facility_search(@keyword, @googleapi_key)
      
    else
    end
  end
end
