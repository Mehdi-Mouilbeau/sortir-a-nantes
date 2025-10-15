import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sortir_a_nantes/models/naolib_station.dart';

class StationsMap extends StatelessWidget {
  final LatLng searchedLocation;
  final List<NaolibStation> stations;
  final MapController mapController;

  const StationsMap({
    super.key,
    required this.searchedLocation,
    required this.stations,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(
        point: searchedLocation,
        width: 48,
        height: 48,
        child: const Icon(Icons.location_on, size: 40, color: Colors.red),
      ),
      ...stations.map(
        (s) => Marker(
          point: LatLng(s.lat, s.lon),
          width: 80,
          height: 60,
          child: Column(
            children: [
              const Icon(Icons.pedal_bike, size: 28, color: Colors.orange),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${s.availableBikes}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
        options: MapOptions(
          initialCenter: searchedLocation,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
