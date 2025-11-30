import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String _apiKey = 'b379950557f94a44ade90852252911';
  static const String _baseUrl = 'http://api.weatherapi.com/v1';

  // Check if location services are enabled and permissions are granted
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Fetch weather data based on coordinates
  Future<WeatherData?> getWeatherByLocation(double latitude, double longitude) async {
    try {
      final url = Uri.parse('$_baseUrl/forecast.json?key=$_apiKey&q=$latitude,$longitude&days=1&aqi=no&alerts=no');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        print('Failed to load weather data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  // Get current weather (combines location and weather fetching)
  Future<WeatherData?> getCurrentWeather() async {
    try {
      Position? position = await getCurrentLocation();
      if (position == null) {
        return null;
      }

      return await getWeatherByLocation(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current weather: $e');
      return null;
    }
  }

  // Open app settings (for when permission is denied)
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}

// Weather data model
class WeatherData {
  final String locationName;
  final String region;
  final String country;
  final double temperatureC;
  final double temperatureF;
  final String condition;
  final String conditionIcon;
  final double windKph;
  final double windMph;
  final int humidity;
  final double precipMm;
  final String localTime;
  final String sunrise;
  final String sunset;

  WeatherData({
    required this.locationName,
    required this.region,
    required this.country,
    required this.temperatureC,
    required this.temperatureF,
    required this.condition,
    required this.conditionIcon,
    required this.windKph,
    required this.windMph,
    required this.humidity,
    required this.precipMm,
    required this.localTime,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    final forecast = json['forecast']['forecastday'][0];
    final astro = forecast['astro'];

    return WeatherData(
      locationName: location['name'] ?? '',
      region: location['region'] ?? '',
      country: location['country'] ?? '',
      temperatureC: (current['temp_c'] ?? 0).toDouble(),
      temperatureF: (current['temp_f'] ?? 0).toDouble(),
      condition: current['condition']['text'] ?? '',
      conditionIcon: current['condition']['icon'] ?? '',
      windKph: (current['wind_kph'] ?? 0).toDouble(),
      windMph: (current['wind_mph'] ?? 0).toDouble(),
      humidity: current['humidity'] ?? 0,
      precipMm: (current['precip_mm'] ?? 0).toDouble(),
      localTime: location['localtime'] ?? '',
      sunrise: astro['sunrise'] ?? '',
      sunset: astro['sunset'] ?? '',
    );
  }

  // Get weather icon based on condition
  String getWeatherIcon() {
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('sunny') || lowerCondition.contains('clear')) {
      return 'sunny';
    } else if (lowerCondition.contains('cloud')) {
      return 'cloudy';
    } else if (lowerCondition.contains('rain') || lowerCondition.contains('drizzle')) {
      return 'rainy';
    } else if (lowerCondition.contains('snow')) {
      return 'snowy';
    } else if (lowerCondition.contains('thunder') || lowerCondition.contains('storm')) {
      return 'thunderstorm';
    } else if (lowerCondition.contains('fog') || lowerCondition.contains('mist')) {
      return 'foggy';
    } else {
      return 'cloudy';
    }
  }

  // Format day of week from localTime
  String getDayOfWeek() {
    try {
      DateTime dateTime = DateTime.parse(localTime);
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[dateTime.weekday - 1];
    } catch (e) {
      return 'Today';
    }
  }
}


