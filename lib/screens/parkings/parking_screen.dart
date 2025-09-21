import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sortir_a_nantes/models/parking.dart';
import 'package:sortir_a_nantes/services/parking_service.dart';
import 'package:sortir_a_nantes/utils/parking_utils.dart';

class ParkingScreen extends StatefulWidget {
  final double eventLat;
  final double eventLon;
  final String eventName;

  const ParkingScreen({
    super.key,
    required this.eventLat,
    required this.eventLon,
    required this.eventName,
  });

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  late Future<List<Parking>> _nearbyParkingsFuture;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _nearbyParkingsFuture = _loadNearbyParkings();
  }

  Future<List<Parking>> _loadNearbyParkings() async {
    try {
      final allParkings = await ParkingService().fetchParkings();
      return filterNearbyParkings(
        allParkings,
        widget.eventLat,
        widget.eventLon,
        radiusInMeters: 1000,
      );
    } catch (e) {
      debugPrint("Erreur lors du chargement des parkings : $e");
      return [];
    }
  }

  void _centerMapOn(LatLng pos, {double zoom = 17}) {
    _mapController.move(pos, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final LatLng eventLocation = LatLng(widget.eventLat, widget.eventLon);

    return Scaffold(
      appBar: AppBar(title: Text("Parkings près de ${widget.eventName}")),
      body: Column(
        children: [
          // Carte
          SizedBox(
            height: 320,
            child: FutureBuilder<List<Parking>>(
              future: _nearbyParkingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Erreur parkings : ${snapshot.error}"));
                }

                final parkings = snapshot.data ?? [];

                final markers = <Marker>[
                  Marker(
                    point: eventLocation,
                    width: 48,
                    height: 48,
                    child: const Icon(Icons.location_on, size: 40, color: Colors.red),
                  ),
                ];
                for (var p in parkings) {
                  markers.add(
                    Marker(
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
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: eventLocation,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: FutureBuilder<List<Parking>>(
              future: _nearbyParkingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Erreur parkings : ${snapshot.error}"));
                }

                final parkings = snapshot.data ?? [];
                if (parkings.isEmpty) {
                  return const Center(child: Text("Aucun parking disponible dans un rayon de 1 km."));
                }

                return ListView.separated(
                  itemCount: parkings.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = parkings[index];
                    return ListTile(
                      leading: const Icon(Icons.local_parking, color: Colors.blue),
                      title: Text(p.name.isNotEmpty ? p.name : p.address),
                      subtitle: Text(p.address),
                      trailing: Text(
                        "${p.available} libres",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _centerMapOn(LatLng(p.lat, p.lon)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
