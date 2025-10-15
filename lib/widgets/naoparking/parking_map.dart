import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sortir_a_nantes/models/parking.dart';

class ParkingMap extends StatelessWidget {
  final MapController mapController;
  final LatLng center;
  final List<Parking> parkings;

  const ParkingMap({
    super.key,
    required this.mapController,
    required this.center,
    required this.parkings,
  });

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(
        point: center,
        width: 48,
        height: 48,
        child: const Icon(Icons.location_on, size: 40, color: Colors.red),
      ),
      ...parkings.map(
        (p) => Marker(
          point: LatLng(p.lat, p.lon),
          width: 80,
          height: 60,
          child: Column(
            children: [
              const Icon(Icons.local_parking, size: 28, color: Colors.blue),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${p.available}",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return SizedBox(
      height: 300,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(initialCenter: center, initialZoom: 15),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
