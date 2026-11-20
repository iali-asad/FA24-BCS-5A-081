import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/search_bar.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _weather;
  List<DailyForecastModel>? _forecastList;
  bool _isLoading = false;
  bool _isForecastLoading = false;
  String? _errorMessage;
  String? _forecastErrorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch default city weather on startup
    _fetchWeather('London');
  }

  Future<void> _fetchWeather(String cityName) async {
    final trimmedCity = cityName.trim();
    if (trimmedCity.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid city name.';
        _weather = null;
        _forecastList = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _forecastErrorMessage = null;
      _forecastList = null;
    });

    try {
      final weather = await _weatherService.fetchWeather(trimmedCity);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });

      // Fetch 7-day forecast using lat and lon from current weather
      _fetchForecast(weather.lat, weather.lon);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _weather = null;
        _forecastList = null;
      });
    }
  }

  Future<void> _fetchForecast(double lat, double lon) async {
    setState(() {
      _isForecastLoading = true;
      _forecastErrorMessage = null;
    });

    try {
      final forecast = await _weatherService.fetch7DayForecast(lat, lon);
      setState(() {
        _forecastList = forecast;
        _isForecastLoading = false;
      });
    } catch (e) {
      setState(() {
        _isForecastLoading = false;
        _forecastErrorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade900,
              Colors.blue.shade700,
              Colors.blue.shade400,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Title
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Weather Forecast',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar
                SearchBarWidget(
                  controller: _searchController,
                  onSearch: () {
                    _fetchWeather(_searchController.text);
                  },
                ),
                const SizedBox(height: 24),

                // Main Content Area
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : _errorMessage != null
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.redAccent.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.redAccent,
                                      size: 52,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _weather != null
                              ? SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      WeatherCard(weather: _weather!),
                                      const SizedBox(height: 28),
                                      if (_isForecastLoading)
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      else if (_forecastErrorMessage != null)
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.orangeAccent.withValues(alpha: 0.5),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              const Icon(
                                                Icons.info_outline_rounded,
                                                color: Colors.orangeAccent,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _forecastErrorMessage!,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else if (_forecastList != null)
                                        ForecastSection(
                                            forecastList: _forecastList!),
                                    ],
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    'Search for a city to get weather details.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
