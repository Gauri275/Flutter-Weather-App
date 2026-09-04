import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/location_service.dart';
import 'services/weather_service.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Weather? _weather;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isCelsius = true;

  @override
  void initState() {
    super.initState();
    _loadLastCityAndFetchWeather();
  }

  Future<void> _loadLastCityAndFetchWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = prefs.getString('last_city');

    if (lastCity != null && lastCity.isNotEmpty) {
      _fetchWeather(cityName: lastCity);
    } else {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather({String? cityName}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weatherService = WeatherService();
      Weather weather;

      if (cityName != null && cityName.isNotEmpty) {
        weather = await weatherService.getWeatherByCity(cityName);
      } else {
        final locationService = LocationService();
        Position position = await locationService.getCurrentLocation();
        weather = await weatherService.getCurrentWeather(
          position.latitude,
          position.longitude,
        );
      }

      final prefs = await SharedPreferences.getInstance();
      if (weather.cityName != 'Current Location') {
        await prefs.setString('last_city', weather.cityName);
      }

      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  int _getDisplayTemp(double tempCelsius) {
    if (_isCelsius) return tempCelsius.round();
    return ((tempCelsius * 9 / 5) + 32).round();
  }

  String _formatTime(String rawTime) {
    DateTime parsed = DateTime.parse(rawTime);
    return DateFormat.jm().format(parsed);
  }

  // NEW: Ultra-premium 3-color gradient palettes!
  List<Color> _getBackgroundColors() {
    if (_weather == null) {
      // Default: A beautiful, sleek neon-blue gradient before the data loads
      return [const Color(0xFF1A2980), const Color(0xFF26D0CE)];
    }

    double temp = _weather!.temperature;
    int code = _weather!.weatherCode;

    // 1. Weather Overrides (If it is raining/storming, show a moody sky)
    if (code >= 51 && code <= 67 || code >= 95) {
      // Dark Stormy Blues
      return [
        const Color(0xFF141E30),
        const Color(0xFF243B55),
        const Color(0xFF3A6073),
      ];
    }

    // 2. Temperature based gradients (3 colors for maximum depth)
    if (temp <= 0) {
      // Deep Ice
      return [
        const Color(0xFF000428),
        const Color(0xFF004E92),
        const Color(0xFF1CB5E0),
      ];
    } else if (temp < 15) {
      // Cool Night Sky
      return [
        const Color(0xFF2C3E50),
        const Color(0xFF3498DB),
        const Color(0xFF2980B9),
      ];
    } else if (temp < 25) {
      // Elegant Dark Teal
      return [
        const Color(0xFF0F2027),
        const Color(0xFF203A43),
        const Color(0xFF2C5364),
      ];
    } else {
      // Warm Sunset (Pink/Orange/Purple)
      return [
        const Color(0xFF3A1C71),
        const Color(0xFFD76D77),
        const Color(0xFFFFAF7B),
      ];
    }
  }

  String _getWeatherEmoji(int code, double temp) {
    if (temp <= 0 && (code == 0 || code == 1 || code == 2)) return '🥶';
    if (code == 0) return '☀️';
    if (code == 1 || code == 2) return '⛅';
    if (code == 3) return '☁️';
    if (code >= 45 && code <= 48) return '🌫️';
    if (code >= 51 && code <= 57) return '🌧️';
    if (code >= 61 && code <= 67) return '☔';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 82) return '🌦️';
    if (code >= 85 && code <= 86) return '🌨️';
    if (code >= 95) return '⛈️';
    return '🌡️';
  }

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.greenAccent;
    if (aqi <= 100) return Colors.yellowAccent;
    if (aqi <= 150) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  void _showSearchDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          title: const Text(
            'Search City',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter city name',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _fetchWeather(cityName: controller.text);
              },
              child: const Text(
                'Search',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // NEW: Swapped the angle to a much wider diagonal for a smoother blend
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          // NEW: Flutter automatically handles lists of 2 or 3 colors perfectly!
          colors: _getBackgroundColors(),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Weather',
            style: TextStyle(fontWeight: FontWeight.w300, letterSpacing: 2),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _showSearchDialog,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isCelsius = !_isCelsius;
                });
              },
              child: Text(
                _isCelsius ? '°F' : '°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),

        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _buildUI(),
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white.withOpacity(0.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('last_city');
            _fetchWeather();
          },
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildUI() {
    if (_isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        key: const ValueKey('error'),
        child: _buildGlassCard(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error: $_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    if (_weather == null) {
      return const Center(
        key: ValueKey('empty'),
        child: Text(
          'Press the GPS button to begin',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
        ),
      );
    }

    String unit = _isCelsius ? '°C' : '°F';

    return RefreshIndicator(
      key: ValueKey(_weather!.cityName),
      color: Colors.black87,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await _fetchWeather(
          cityName: _weather!.cityName == 'Current Location'
              ? null
              : _weather!.cityName,
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _weather!.cityName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                _getWeatherEmoji(_weather!.weatherCode, _weather!.temperature),
                style: const TextStyle(fontSize: 100),
              ),

              const SizedBox(height: 10),
              Text(
                '${_getDisplayTemp(_weather!.temperature)}$unit',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              _buildGlassCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailIcon(
                          Icons.water_drop_outlined,
                          'Humidity',
                          '${_weather!.humidity}%',
                          Colors.white,
                        ),
                        _buildDetailIcon(
                          Icons.air,
                          'Wind',
                          '${_weather!.windSpeed} km/h',
                          Colors.white,
                        ),
                        _buildDetailIcon(
                          Icons.masks_outlined,
                          'AQI',
                          '${_weather!.aqi}',
                          _getAqiColor(_weather!.aqi),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(
                        color: Colors.white.withOpacity(0.2),
                        height: 1,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailIcon(
                          Icons.wb_twilight,
                          'Sunrise',
                          _formatTime(_weather!.sunrise),
                          Colors.white,
                        ),
                        _buildDetailIcon(
                          Icons.nights_stay_outlined,
                          'Sunset',
                          _formatTime(_weather!.sunset),
                          Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '5-DAY FORECAST',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              _buildGlassCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: Column(
                  children: _weather!.forecast.map((daily) {
                    DateTime parsedDate = DateTime.parse(daily.date);
                    String dayName = DateFormat('EEEE').format(parsedDate);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              dayName.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          Text(
                            _getWeatherEmoji(daily.weatherCode, daily.minTemp),
                            style: const TextStyle(fontSize: 26),
                          ),

                          SizedBox(
                            width: 80,
                            child: Text(
                              '${_getDisplayTemp(daily.maxTemp)}° / ${_getDisplayTemp(daily.minTemp)}°',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? width,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailIcon(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
