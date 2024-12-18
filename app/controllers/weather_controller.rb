class WeatherController < ApplicationController
  def index
    session[:address] = params[:address]
    if params[:address].present?
      begin
        @address = params[:address]
        @geocode = GeolookupService.call(@address)
        # @weather_cache_key = "#{@geocode.country_code}-#{@geocode.postal_code}"
        # @weather_cache_exist = Rails.cache.exist?(@weather_cache_key)

        # @weather = Rails.cache.fetch(@weather_cache_key, expires_in: 30.minutes) do
        #   ForecastService.call(
          # lat: @geocode[:lat],
          # lon: @geocode[:lon],
          # timezone: @geocode[:timezone]
        #   )
        # end

        @forecast = ForecastService.call(
              lat: @geocode[:lat],
              lon: @geocode[:lon],
              country_code: @geocode[:country_code],
              timezone: @geocode[:timezone]
            )
      rescue => e
        flash.alert = e.message
      end
    end
  end
end
