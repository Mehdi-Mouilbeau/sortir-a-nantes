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
      id: json['id_manif']?.toString() ?? '',
      name: json['nom'] ?? '',
      description: json['description_evt'] ?? '',
      theme: (json['themes_libelles'] as List<dynamic>?)?.isNotEmpty == true
          ? json['themes_libelles'][0]
          : '',
      type: (json['types_libelles'] as List<dynamic>?)?.isNotEmpty == true
          ? json['types_libelles'][0]
          : '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      startTime: json['heure_debut'] ?? '',
      endTime: json['heure_fin'] ?? '',
      isFull: (json['complet']?.toLowerCase() ?? 'non') == "oui",
      placeName: json['lieu'] ?? '',
      address: json['adresse'] ?? '',
      city: json['ville'] ?? '',
      postalCode: json['code_postal']?.toString() ?? '',
      website: json['lieu_siteweb'],
      isFree: (json['gratuit']?.toLowerCase() ?? 'non') == "oui",
      latitude: (json['latitude'] ?? json['location_latlong']?['lat'] ?? 0.0)
          .toDouble(),
      longitude: (json['longitude'] ?? json['location_latlong']?['lon'] ?? 0.0)
          .toDouble(),
    );
  }
}
