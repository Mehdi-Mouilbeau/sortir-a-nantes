class NaolibStation {
  final String number;
  final String name;
  final String address;
  final int availableBikes;
  final int availableStands;
  final double lat;
  final double lon;

  NaolibStation({
    required this.number,
    required this.name,
    required this.address,
    required this.availableBikes,
    required this.availableStands,
    required this.lat,
    required this.lon,
  });

  factory NaolibStation.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] ?? {};
    return NaolibStation(
      number: json['number'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      availableBikes: int.tryParse(json['available_bikes'] ?? '0') ?? 0,
      availableStands: int.tryParse(json['available_bike_stands'] ?? '0') ?? 0,
      lat: (pos['lat'] ?? 0.0).toDouble(),
      lon: (pos['lon'] ?? 0.0).toDouble(),
    );
  }
}
