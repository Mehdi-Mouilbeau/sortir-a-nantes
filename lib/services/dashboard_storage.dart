import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortir_a_nantes/models/dashboard/dashboard_page.dart';
import 'dart:convert';

class DashboardStorage {
  static const _key = 'dashboard_pages';

  static Future<List<DashboardPage>> loadPages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return [
        DashboardPage(name: "Mobilité", widgets: []),
        DashboardPage(name: "Événements", widgets: []),
      ];
    }

    final List decoded = jsonDecode(jsonString);
    return decoded
        .map((e) => DashboardPage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> savePages(List<DashboardPage> pages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(pages.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}
