class BikeStation {
  final String number;
  final String name;
  final String address;
  final int bikeStands; 
  final int availableBikes;
  final int availableStands;
  final double lat;
  final double lon;
  final DateTime lastUpdate;

  BikeStation({
    required this.number,
    required this.name,
    required this.address,
    required this.bikeStands,
    required this.availableBikes,
    required this.availableStands,
    required this.lat,
    required this.lon,
    required this.lastUpdate,
  });

  factory BikeStation.fromJson(Map<String, dynamic> json) {
    return BikeStation(
      number: json['number'] ?? "",
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      bikeStands: json['bike_stands'] ?? 0,
      availableBikes: int.tryParse(json['available_bikes'] ?? "0") ?? 0,
      availableStands: int.tryParse(json['available_bike_stands'] ?? "0") ?? 0,
      lat: json['position']?['lat']?.toDouble() ?? 0.0,
      lon: json['position']?['lon']?.toDouble() ?? 0.0,
      lastUpdate: DateTime.tryParse(json['last_update'] ?? "") ?? DateTime.now(),
    );
  }
}
