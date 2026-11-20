import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  // Provided OpenWeatherMap API Key for current weather
  final String apiKey = 'a60038918110ab9d315a7f02583ab3c8';

  Future<WeatherModel> fetchWeather(String cityName) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check the city name and try again.');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your OpenWeatherMap API key.');
      } else {
        throw Exception('Failed to load weather data. Error code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('No internet connection or network error occurred.');
      }
    }
  }

  Future<List<DailyForecastModel>> fetch7DayForecast(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max&timezone=auto',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dailyJson = data['daily'];
        if (dailyJson == null) {
          throw Exception('No daily forecast data available.');
        }

        final times = dailyJson['time'] as List;
        List<DailyForecastModel> forecastList = [];
        for (int i = 0; i < times.length && i < 7; i++) {
          forecastList.add(DailyForecastModel.fromOpenMeteoJson(dailyJson, i));
        }
        return forecastList;
      } else {
        throw Exception('Failed to load 7-day forecast. Error code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error occurred while fetching 7-day forecast.');
      }
    }
  }
}
