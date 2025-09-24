class Event {
  final String id;
  final String name;
  final String description;
  final List<String> theme;
  final String type;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isFull; 
  final String placeName; 
  final String address; 
  final String city; 
  final String postalCode; 
  final String? website; 
  final bool isFree; 
  final double latitude;
  final double longitude;
  final String image;

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
    required this.image,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: (json['id_manif'] ?? json['id'] ?? '').toString(),
      name: json['nom'] ?? '',
      description: json['description_evt'] ?? '',
      image: json['media_url'] ?? '',
      theme: (json['themes_libelles'] as List<dynamic>?)?.isNotEmpty == true
          ? (json['themes_libelles'] as List<dynamic>).map((e) => e.toString()).toList()
          : <String>[],
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
      website: json['lieu_siteweb'] ?? json['url_site'],
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
      'id_manif': id,
      'nom': name,
      'description_evt': description,
      'media_url': image,
      'themes_libelles': theme.isNotEmpty ? [theme] : [],
      'types_libelles': type.isNotEmpty ? [type] : [],
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
      'latitude': latitude,
      'longitude': longitude,
      'location_latlong': {'lat': latitude, 'lon': longitude},
    };
  }
}
