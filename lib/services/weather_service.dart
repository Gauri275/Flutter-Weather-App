import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyForecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });
}

class Weather {
  final String cityName;
  final double temperature;
  final double windSpeed;
  final int humidity;
  final String sunrise;
  final String sunset;
  final int weatherCode;
  final int aqi; // NEW: Air Quality Index
  final List<DailyForecast> forecast;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.sunrise,
    required this.sunset,
    required this.weatherCode,
    required this.aqi, // NEW
    required this.forecast,
  });

  // NEW: We now pass the AQI directly into the model when we create it
  factory Weather.fromJson(
    Map<String, dynamic> json,
    String cityName,
    int currentAqi,
  ) {
    final current = json['current'];
    final daily = json['daily'];

    List<DailyForecast> parsedForecast = [];
    if (daily != null) {
      List<dynamic> times = daily['time'];
      List<dynamic> maxTemps = daily['temperature_2m_max'];
      List<dynamic> minTemps = daily['temperature_2m_min'];
      List<dynamic> weatherCodes = daily['weather_code'];

      for (int i = 0; i < times.length; i++) {
        parsedForecast.add(
          DailyForecast(
            date: times[i],
            maxTemp: maxTemps[i].toDouble(),
            minTemp: minTemps[i].toDouble(),
            weatherCode: weatherCodes[i].toInt(),
          ),
        );
      }
    }

    return Weather(
      cityName: cityName,
      temperature: current['temperature_2m'].toDouble(),
      windSpeed: current['wind_speed_10m'].toDouble(),
      humidity: current['relative_humidity_2m'].toInt(),
      sunrise: daily['sunrise'][0],
      sunset: daily['sunset'][0],
      weatherCode: current['weather_code'].toInt(),
      aqi: currentAqi, // NEW
      forecast: parsedForecast,
    );
  }
}

class WeatherService {
  Future<Weather> getCurrentWeather(
    double lat,
    double lon, {
    String cityName = 'Current Location',
  }) async {
    // 1. Fetch Weather Data
    final weatherUrl = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,weather_code&timezone=auto',
    );

    // 2. Fetch Air Quality Data (from a totally different URL!)
    final aqiUrl = Uri.parse(
      'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=us_aqi',
    );

    // We wait for BOTH requests to finish
    final weatherResponse = await http.get(weatherUrl);
    final aqiResponse = await http.get(aqiUrl);

    if (weatherResponse.statusCode == 200 && aqiResponse.statusCode == 200) {
      final weatherData = jsonDecode(weatherResponse.body);
      final aqiData = jsonDecode(aqiResponse.body);

      // Extract the AQI number (default to 0 if it fails)
      int currentAqi = aqiData['current']['us_aqi']?.toInt() ?? 0;

      // Pass everything into our model
      return Weather.fromJson(weatherData, cityName, currentAqi);
    } else {
      throw Exception('Failed to load weather or air quality data.');
    }
  }

  Future<Weather> getWeatherByCity(String city) async {
    final geoUrl = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1&language=en&format=json',
    );

    final geoResponse = await http.get(geoUrl);

    if (geoResponse.statusCode == 200) {
      final geoData = jsonDecode(geoResponse.body);

      if (geoData['results'] == null || geoData['results'].isEmpty) {
        throw Exception('City not found. Try another spelling.');
      }

      final lat = geoData['results'][0]['latitude'];
      final lon = geoData['results'][0]['longitude'];
      final foundCityName = geoData['results'][0]['name'];

      return await getCurrentWeather(lat, lon, cityName: foundCityName);
    } else {
      throw Exception('Failed to contact search server.');
    }
  }
}
