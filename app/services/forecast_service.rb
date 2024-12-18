# Connects to the OpenMeteo API and returns a Hash with indifferent access
# Raises exceptions for invalid latitude, longitude, timezone (or with upstream errors)
#
# Example response:
# {"latitude"=>55.0,
#   "longitude"=>0.119999886,
#   "generationtime_ms"=>0.1239776611328125,
#   "utc_offset_seconds"=>-21600,
#   "timezone"=>"America/Chicago",
#   "timezone_abbreviation"=>"CST",
#   "elevation"=>0.0,
#   "current_units"=>
#    {"time"=>"iso8601",
#     "interval"=>"seconds",
#     "temperature_2m"=>"°F",
#     "weather_code"=>"wmo code"},
#   "current"=>
#    {"time"=>"2024-12-18T12:00",
#     "interval"=>900,
#     "temperature_2m"=>49.9,
#     "weather_code"=>3},
#   "daily_units"=>
#    {"time"=>"iso8601",
#     "temperature_2m_max"=>"°F",
#     "temperature_2m_min"=>"°F",
#     "weather_code"=>"wmo code"},
#   "daily"=>
#    {"time"=>
#      ["2024-12-18",
#       "2024-12-19",
#       "2024-12-20",
#       "2024-12-21",
#       "2024-12-22",
#       "2024-12-23",
#       "2024-12-24"],
#     "temperature_2m_max"=>[52.9, 45.8, 49.1, 50.5, 47.7, 52.1, 53.7],
#     "temperature_2m_min"=>[45.0, 43.5, 44.4, 43.6, 43.7, 45.6, 51.3],
#     "weather_code"=>[61, 80, 61, 80, 80, 61, 3]}}



class ForecastService
  CURRENT_PARAMS = "temperature_2m,weather_code"
  DAILY_PARAMS = "temperature_2m_max,temperature_2m_min,weather_code"
  COUNTRIES_USING_FAHRENHEIT = [ "FM", "KY", "LR", "MH", "MS", "PW", "US", "VI" ]

  def self.call(lat:, lon:, country_code: "US", timezone: "GMT")
    new(lat, lon, country_code, timezone,).call
  end

  def initialize(lat, lon, country_code, timezone)
    @lat = lat
    @lon = lon
    @country_code = country_code.upcase
    @timezone = timezone
  end

  def call
    validate_arguments
    forecast_data
  end

  class ForecastError < StandardError
  end

  private

  def validate_arguments
    @lat = Float(@lat, exception: true)
    @lon = Float(@lon, exception: true)

    raise ArgumentError if @lon > 180.0 or @lon < -180.0 or @lat > 90.0 or @lat < -90.0
  end


  def forecast_data
    params = {
      "current": CURRENT_PARAMS,
      "daily": DAILY_PARAMS,
      "latitude": @lat,
      "longitude": @lon,
      "timezone": @timezone
    }

    params.merge!({ "temperature_unit": "fahrenheit" }) if COUNTRIES_USING_FAHRENHEIT.include? @country_code

    conn = Faraday.new(url: "https://api.open-meteo.com/")

    response = conn.get("v1/forecast", params)
    parsed_response = JSON.parse(response.body)
    if response.status != 200
      raise ArgumentError, "Invalid timezone" if parsed_response["reason"] == "Invalid timezone"
      raise ForecastService::ForecastError, "Invalid upstream response"
    end

    parsed_response.with_indifferent_access
  end
end
