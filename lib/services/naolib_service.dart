import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/naolib_station.dart';

class NaolibService {
  Future<List<NaolibStation>> fetchStations() async {
    final url = Uri.parse(
        "https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets/244400404_disponibilite-temps-reel-velos-libre-service-naolib-nantes-metropole/records?limit=100");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> results = data['results'];

      final stations = results.map((e) {
        final stationJson = e;
        return NaolibStation.fromJson(stationJson);
      }).toList();

      print("Nombre total de stations chargées : ${stations.length}");
      return stations;
    } else {
      throw Exception("Erreur lors du chargement des stations Naolib");
    }
  }
}
