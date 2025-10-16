import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/event/event.dart';

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
    int limit = 100,
  }) async {
    final queryParams = {
      "limit": "$limit",
    };

    final conditions = <String>[];

    // Ville
    if (city != null && city.isNotEmpty) {
      conditions.add("ville = \"$city\"");
    }

    // Dates
    if (startDate != null && endDate != null) {
      final start = _formatDate(startDate);
      final end = _formatDate(endDate);
      conditions.add("date >= '$start' AND date <= '$end'");
    }

    // Thèmes
    if (themes != null && themes.isNotEmpty) {
      final inClause = themes.map((t) => "'$t'").join(", ");
      conditions.add("themes_libelles IN ($inClause)");
    }

    // Ensembel des trois
    if (conditions.isNotEmpty) {
      queryParams['where'] = conditions.join(" AND ");
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
