class WeatherModel {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String description;
  final String iconCode;
  final double lat;
  final double lon;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.iconCode,
    required this.lat,
    required this.lon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      lat: (json['coord']['lat'] as num).toDouble(),
      lon: (json['coord']['lon'] as num).toDouble(),
    );
  }
}

class WeatherCodeHelper {
  static Map<String, String> getWeatherInfo(int code) {
    switch (code) {
      case 0:
        return {'description': 'Clear sky', 'icon': '01d'};
      case 1:
      case 2:
        return {'description': 'Partly cloudy', 'icon': '02d'};
      case 3:
        return {'description': 'Overcast', 'icon': '04d'};
      case 45:
      case 48:
        return {'description': 'Foggy', 'icon': '50d'};
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return {'description': 'Drizzle', 'icon': '09d'};
      case 61:
      case 63:
      case 80:
        return {'description': 'Rain', 'icon': '10d'};
      case 65:
      case 82:
        return {'description': 'Heavy rain', 'icon': '09d'};
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return {'description': 'Snow', 'icon': '13d'};
      case 95:
      case 96:
      case 99:
        return {'description': 'Thunderstorm', 'icon': '11d'};
      default:
        return {'description': 'Fair', 'icon': '01d'};
    }
  }
}

class DailyForecastModel {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String description;
  final String iconCode;
  final int precipitationProbability;
  final double windSpeed;

  DailyForecastModel({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.iconCode,
    required this.precipitationProbability,
    required this.windSpeed,
  });

  factory DailyForecastModel.fromOpenMeteoJson(Map<String, dynamic> dailyJson, int index) {
    final times = dailyJson['time'] as List;
    final dateStr = times[index] as String;
    final date = DateTime.parse(dateStr);

    final weatherCodes = dailyJson['weather_code'] as List;
    final code = (weatherCodes[index] as num).toInt();
    final weatherInfo = WeatherCodeHelper.getWeatherInfo(code);

    final maxTemps = dailyJson['temperature_2m_max'] as List;
    final tempMax = (maxTemps[index] as num).toDouble();

    final minTemps = dailyJson['temperature_2m_min'] as List;
    final tempMin = (minTemps[index] as num).toDouble();

    final precipProbs = dailyJson['precipitation_probability_max'] as List?;
    final precipProb = precipProbs != null && precipProbs.length > index
        ? (precipProbs[index] as num).toInt()
        : 0;

    final windSpeeds = dailyJson['wind_speed_10m_max'] as List?;
    final windSpeed = windSpeeds != null && windSpeeds.length > index
        ? (windSpeeds[index] as num).toDouble()
        : 0.0;

    return DailyForecastModel(
      date: date,
      tempMin: tempMin,
      tempMax: tempMax,
      description: weatherInfo['description']!,
      iconCode: weatherInfo['icon']!,
      precipitationProbability: precipProb,
      windSpeed: windSpeed,
    );
  }
}
