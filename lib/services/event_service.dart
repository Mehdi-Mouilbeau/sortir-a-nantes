import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class EventService {
  final String baseUrl =
      "https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets/244400404_agenda-evenements-nantes-metropole_v2/records";

  /// utilitaire pour formatter la date au bon format
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<List<Event>> fetchEvents({
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    final queryParams = {
      "limit": "$limit",
    };

    // filtre par ville
    if (city != null && city.isNotEmpty) {
      queryParams['where'] = "ville = \"$city\"";
    }

    // filtre par date
    if (startDate != null && endDate != null) {
      final start = _formatDate(startDate);
      final end = _formatDate(endDate);

      // si on a déjà une clause WHERE (ex : ville), on concatène
      if (queryParams.containsKey('where')) {
        queryParams['where'] =
            "${queryParams['where']} AND date >= '$start' AND date <= '$end'";
      } else {
        queryParams['where'] = "date >= '$start' AND date <= '$end'";
      }
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List eventsJson = data['results'];

      // transformation en Event + suppression des doublons
      final events = eventsJson.map((json) => Event.fromJson(json)).toList();
      final uniqueEvents = {for (var e in events) e.id: e}.values.toList();

      return uniqueEvents;
    } else {
      throw Exception("Erreur lors du chargement des évènements");
    }
  }

  /// récupérer la liste des villes disponibles
  Future<List<String>> fetchCities() async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      "group_by": "ville",
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results
          .map((e) => e['ville'].toString())
          .where((v) => v.isNotEmpty)
          .toSet()
          .toList();
    } else {
      throw Exception("Erreur lors du chargement des villes");
    }
  }
}
