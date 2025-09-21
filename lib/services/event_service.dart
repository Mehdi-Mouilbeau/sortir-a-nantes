import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class EventService {
  final String baseUrl =
      "https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets/244400404_agenda-evenements-nantes-metropole_v2/records";

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<List<Event>> fetchEvents({
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? themes,
    int limit = 50,
  }) async {
    final queryParams = {
      "limit": "$limit",
    };

    String whereClause = "";

    // filtre par ville
    if (city != null && city.isNotEmpty) {
      whereClause = "ville = \"$city\"";
    }

    // filtre par date
    if (startDate != null && endDate != null) {
      final start = _formatDate(startDate);
      final end = _formatDate(endDate);

      if (whereClause.isNotEmpty) {
        whereClause += " AND date >= '$start' AND date <= '$end'";
      } else {
        whereClause = "date >= '$start' AND date <= '$end'";
      }
    }

    // filtre par thèmes
    if (themes != null && themes.isNotEmpty) {
      final inClause = themes.map((t) => "'$t'").join(", ");
      if (queryParams.containsKey('where')) {
        queryParams['where'] =
            "${queryParams['where']} AND themes_libelles IN ($inClause)";
      } else {
        queryParams['where'] = "themes_libelles IN ($inClause)";
      }
    }

    if (whereClause.isNotEmpty) {
      queryParams['where'] = whereClause;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List eventsJson = data['results'];

      final events = eventsJson.map((json) => Event.fromJson(json)).toList();
      final uniqueEvents = {for (var e in events) e.id: e}.values.toList();

      return uniqueEvents;
    } else {
      throw Exception("Erreur lors du chargement des évènements");
    }
  }

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

  Future<List<String>> fetchThemes() async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      "group_by": "themes_libelles",
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      return results
          .map((e) => e['themes_libelles'])
          .where((t) => t != null && t.toString().isNotEmpty)
          .expand((t) => (t is List ? t : [t]))
          .cast<String>()
          .toSet()
          .toList();
    } else {
      throw Exception("Erreur lors du chargement des thèmes");
    }
  }
}
