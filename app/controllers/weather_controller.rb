class WeatherController < ApplicationController
  def index
    session[:address] = params[:address]
    if params[:address].present?
      begin

        @geocode = GeolookupService.call(params[:address])
        @address = @geocode[:display_name]

        @weather_cache_key = "#{@geocode[:country_code]}-#{@geocode[:postal_code]}"
        @weather_cache_exists = Rails.cache.exist?(@weather_cache_key)

        @forecast = Rails.cache.fetch(@weather_cache_key, expires_in: 30.minutes) do
          ForecastService.call(
            lat: @geocode[:lat],
            lon: @geocode[:lon],
            country_code: @geocode[:country_code],
            timezone: @geocode[:timezone]
          )
        end
      rescue => e
        flash.alert = e.message
      end
    end
  end
end
