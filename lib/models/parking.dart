class Parking {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final int available;

  Parking({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.available,
  });

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['grp_ident'] ?? '',
      name: json['grp_nom'] ?? '',
      address: json['grp_adresse'] ?? '',
      lat: (json['location']['lat'] as num).toDouble(),
      lon: (json['location']['lon'] as num).toDouble(),
      available: json['grp_disponible'] != null
          ? int.tryParse(json['grp_disponible'].toString()) ?? 0
          : 0,
    );
  }
}
