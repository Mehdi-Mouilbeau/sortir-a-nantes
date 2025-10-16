import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = dotenv.env['API_WEATHER_KEY'] ?? '';

  Future<Map<String, dynamic>?> getCurrentWeather(
      double latitude, double longitude) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&lang=fr&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, double>?> getCoordinates(String city) async {
    final url =
        'http://api.openweathermap.org/geo/1.0/direct?q=$city&limit=1&appid=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return {
            'latitude': data[0]['lat'] as double,
            'longitude': data[0]['lon'] as double,
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAirQuality(double latitude, double longitude) async {
    final url =
        'http://api.openweathermap.org/data/2.5/air_pollution?lat=$latitude&lon=$longitude&appid=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['list'] != null && data['list'].isNotEmpty) {
          return data['list'][0];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
