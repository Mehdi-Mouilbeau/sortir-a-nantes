import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/naolib_station.dart';

class NaolibService {
  final String baseUrl =
      "https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets/244400404_disponibilite-temps-reel-velos-libre-service-naolib-nantes-metropole/records?limit=100";

  Future<List<NaolibStation>> fetchStations() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode != 200) {
        throw Exception(
            "Erreur API Naolib : code ${response.statusCode}");
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final List results = data['results'] ?? [];

      return results.map((json) {
        final fields = json['fields'] ?? {};
        final position = fields['position'] ?? {};
        return NaolibStation(
          number: fields['number']?.toString() ?? '',
          name: fields['name'] ?? '',
          address: fields['address'] ?? '',
          availableBikes: int.tryParse(fields['available_bikes']?.toString() ?? '0') ?? 0,
          availableStands: int.tryParse(fields['available_bike_stands']?.toString() ?? '0') ?? 0,
          lat: (position['lat'] ?? 0.0).toDouble(),
          lon: (position['lon'] ?? 0.0).toDouble(),
        );
      }).toList();
    } catch (e) {
      print("Erreur fetchStations: $e");
      throw Exception("Erreur lors du chargement des stations Naolib");
    }
  }
}
