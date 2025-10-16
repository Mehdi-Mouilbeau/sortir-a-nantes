import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/parking/parking.dart';

class ParkingService {
  final String baseUrl =
      "https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets/244400404_parkings-publics-nantes-disponibilites/records";

  Future<List<Parking>> fetchParkings() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => Parking.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des parkings");
    }
  }
}
