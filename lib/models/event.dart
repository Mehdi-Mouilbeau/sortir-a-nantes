class Event {
  final String id;
  final String name;
  final String description;
  final String theme;
  final String type;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isFull; // "complet"
  final String placeName; // "lieu"
  final String address; // "adresse"
  final String city; // "ville"
  final String postalCode; // "code_postal"
  final String? website; // "lieu_siteweb" (optionnel)
  final bool isFree; // "gratuit"
  final double latitude;
  final double longitude;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.theme,
    required this.type,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isFull,
    required this.placeName,
    required this.address,
    required this.city,
    required this.postalCode,
    this.website,
    required this.isFree,
    required this.latitude,
    required this.longitude,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: (json['id_manif'] ?? json['id'] ?? '').toString(),
      name: json['nom'] ?? '',
      description: json['description_evt'] ?? '',
      theme: (json['themes_libelles'] as List<dynamic>?)?.isNotEmpty == true
          ? (json['themes_libelles'] as List).first.toString()
          : '',
      type: (json['types_libelles'] as List<dynamic>?)?.isNotEmpty == true
          ? (json['types_libelles'] as List).first.toString()
          : '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      startTime: json['heure_debut'] ?? '',
      endTime: json['heure_fin'] ?? '',
      isFull: (json['complet']?.toString().toLowerCase() ?? 'non') == 'oui',
      placeName: json['lieu'] ?? '',
      address: json['adresse'] ?? '',
      city: json['ville'] ?? '',
      postalCode: json['code_postal']?.toString() ?? '',
      website: json['lieu_siteweb'] ?? json['url_site'] ?? null,
      isFree: (json['gratuit']?.toString().toLowerCase() ?? 'non') == 'oui',
      latitude: ((json['latitude'] ??
                  (json['location_latlong'] != null
                      ? json['location_latlong']['lat']
                      : null) ??
                  (json['location'] != null ? json['location']['lat'] : null)) as num?)
              ?.toDouble() ??
          0.0,
      longitude: ((json['longitude'] ??
                  (json['location_latlong'] != null
                      ? json['location_latlong']['lon']
                      : null) ??
                  (json['location'] != null ? json['location']['lon'] : null)) as num?)
              ?.toDouble() ??
          0.0,
    );
  }

  /// Convertit l'objet en Map compatible avec `fromJson` (pour stockage local)
  Map<String, dynamic> toJson() {
    return {
      // utilisation de 'id_manif' pour rester compatible avec fromJson
      'id_manif': id,
      'nom': name,
      'description_evt': description,
      // stocke theme/type comme listes pour la compatibilité
      'themes_libelles': theme.isNotEmpty ? [theme] : [],
      'types_libelles': type.isNotEmpty ? [type] : [],
      // garde isoString pour la date (fromJson sait parser ISO)
      'date': date.toIso8601String(),
      'heure_debut': startTime,
      'heure_fin': endTime,
      'complet': isFull ? 'oui' : 'non',
      'lieu': placeName,
      'adresse': address,
      'ville': city,
      'code_postal': postalCode,
      'lieu_siteweb': website,
      'gratuit': isFree ? 'oui' : 'non',
      // latitude/longitude au niveau racine (fromJson gère aussi location_latlong)
      'latitude': latitude,
      'longitude': longitude,
      // aussi fournir location_latlong au cas où
      'location_latlong': {'lat': latitude, 'lon': longitude},
    };
  }
}
