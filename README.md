```
 _______  _______  ______    _______  _______  _______  _______  _______ 
|       ||       ||    _ |  |       ||       ||   _   ||       ||       |
|    ___||   _   ||   | ||  |    ___||       ||  |_|  ||  _____||_     _|
|   |___ |  | |  ||   |_||_ |   |___ |       ||       || |_____   |   |  
|    ___||  |_|  ||    __  ||    ___||      _||       ||_____  |  |   |  
|   |    |       ||   |  | ||   |___ |     |_ |   _   | _____| |  |   |  
|___|    |_______||___|  |_||_______||_______||__| |__||_______|  |___|  
```

# Requirements
* Accept an address as input
* Retrieve forecast data for the given address. This should include, at minimum, the
current temperature (Bonus points - Retrieve high/low and/or extended forecast)
* Display the requested forecast details to the user
* Cache the forecast details for 30 minutes for all subsequent requests by zip codes.
* Display indicator if result is pulled from cache.

## Notes
I've used RSpec, even though the version targeting Rails 8 has not been released yet. I don't expect breaking changes, and tests do pass for now.

I opted to go with open-meteo for weather data. This allowed international support for forecasts, though the return values are a little more awkward to deal with than some other options (OpenWeatherMap, weather.gov).

## Enhancements
* Add support for querying just by latitude / longitude
* Use getCurrentPosition() API to get latitude / longitude from browser as a default
* Design pass to better support mobile and other breakpoints
* Add dropdown to support scoping address search to a specific country
* Add dropdown of potential matches for ambiguous addresses instead of just defaulting to the first match
* Retool the ForecastService to better format weather data, and excise unneeded values (I ended up running out of time on this one)
* Handle errors and provide messaging to users
* i18n / l10n work
