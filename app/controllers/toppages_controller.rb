class ToppagesController < ApplicationController
  include ToppagesHelper
  
  def index
    
    @keyword=params[:keyword]
    @googleapi_key = ENV['GOOGLEMAP_API_KEY']
    
    if @keyword.present?
      
      Geocoder.configure(language: :ja, units: :km)
      facility_search(@keyword, @googleapi_key)
      
    else
    end
  end
end
