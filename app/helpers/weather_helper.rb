module WeatherHelper
  def emoji_from_wmo(weather_code)
    case weather_code
    when 0
        "☀️"
    when 1, 2, 3
        "🌤"
    when 45, 48
        "🌫"
    when 51, 53, 55
        "🌦"
    when 56, 57, 61, 63, 65, 66, 67, 80, 81, 82
        "🌧"
    when 71, 73, 75, 77, 85, 86
        "🌨"
    when 95, 96, 99
        "🌩"
    end
  end
end
