import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorite_events';

  Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  Future<void> toggleFavorite(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = (prefs.getStringList(_key) ?? []).toSet();
    if (favs.contains(eventId)) {
      favs.remove(eventId);
    } else {
      favs.add(eventId);
    }
    await prefs.setStringList(_key, favs.toList());
  }

  Future<bool> isFavorite(String eventId) async {
    final favs = await getFavorites();
    return favs.contains(eventId);
  }
}
