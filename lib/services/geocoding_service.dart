import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const _headers = {
    "User-Agent": "sortir_a_nantes_app/1.0 (contact@example.com)"
  };

  // Rectangle englobant Nantes et alentours (Ouest, Nord, Est, Sud)
  static const String _viewBox = "-1.65,47.30,-1.45,47.17"; // [minLon,maxLat,maxLon,minLat]

  static Future<List<Map<String, dynamic>>> fetchSuggestions(String query) async {
    if (query.length < 3) return [];

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?format=json"
      "&q=$query"
      "&addressdetails=1"
      "&limit=5"
      "&countrycodes=fr"
      "&viewbox=$_viewBox"
      "&bounded=1",
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((item) => {
        "display_name": item["display_name"],
        "lat": double.parse(item["lat"]),
        "lon": double.parse(item["lon"]),
      }).toList();
    }
    return [];
  }

  static Future<LatLng?> geocodeAddress(String address) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?format=json"
      "&q=$address"
      "&limit=1"
      "&countrycodes=fr"
      "&viewbox=$_viewBox"
      "&bounded=1",
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return LatLng(
          double.parse(data[0]['lat']),
          double.parse(data[0]['lon']),
        );
      }
    }
    return null;
  }

   static Future<LatLng?> getCoordinates(String city) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?format=json"
      "&q=$city"
      "&limit=1"
      "&countrycodes=fr"
      "&viewbox=$_viewBox"
      "&bounded=1",
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return LatLng(
          double.parse(data[0]['lat']),
          double.parse(data[0]['lon']),
        );
      }
    }
    return null;
  }
}
