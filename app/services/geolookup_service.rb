# Connects to OpenStreetMap, returns hash with indifferent access
# Also does timezone lookup required by ForecastService
#
# Example response:
# {"display_name"=>
#   "TEKsystems, 7437, Race Road, The Enclave at Arundel Preserve, Lennox Park, Hanover, Anne Arundel County, Maryland, 21076, United States",
#  "lat"=>"39.1685066",
#  "lon"=>"-76.73843041917469",
#  "postcode"=>"21076",
#  "country_code"=>"us",
#  "timezone"=>"America/New_York"}

class GeolookupService
  def self.call(address)
    new(address).call
  end

  def initialize(address)
    @address = address
  end

  def call
    data
  end

  class GeolookupError < StandardError
  end

  private

  def data
    geo = geolookup_data

    timezone = timezone_data(geo[:lat], geo[:lon])

    geo.merge(timezone: timezone).with_indifferent_access
  end

  def geolookup_data
    params = {
      "q": @address,
      "format": "json",
      "addressdetails": 1
    }

    conn = Faraday.new(url: "https://nominatim.openstreetmap.org")

    response = conn.get("search", params)
    parsed_response = JSON.parse(response.body).first

    if response.status != 200
      raise GeolookupService::GeolookupError, "Invalid upstream response"
    end

    raise ArgumentError, "No address matches found" if parsed_response.blank?

    {
      display_name: parsed_response["display_name"],
      lat: parsed_response["lat"],
      lon: parsed_response["lon"],
      postcode: parsed_response["address"]["postcode"],
      country_code: parsed_response["address"]["country_code"]
    }
  end

  def timezone_data(lat, lon)
    lat = Float(lat, exception: true)
    lon = Float(lon, exception: true)

    tf = TimezoneFinder.create
    tf.timezone_at(lat: lat, lng: lon)
  end
end
