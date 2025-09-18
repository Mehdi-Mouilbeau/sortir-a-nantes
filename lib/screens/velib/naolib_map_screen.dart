import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/naolib_station.dart';
import '../../models/event.dart';
import '../../services/naolib_service.dart';

class NaolibMapScreen extends StatefulWidget {
  final Event? event;
  final double eventLat;
  final double eventLon;
  final String eventName;

  const NaolibMapScreen(
      {super.key,
      this.event,
      required,
      required this.eventLat,
      required this.eventLon,
      required this.eventName});

  @override
  State<NaolibMapScreen> createState() => _NaolibMapScreenState();
}

class _NaolibMapScreenState extends State<NaolibMapScreen> {
  late Future<List<NaolibStation>> _stationsFuture;
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _stationsFuture = NaolibService().fetchStations();
      });
    } catch (e) {
      debugPrint("Erreur position actuelle : $e");
    }
  }

  void _centerMapOn(LatLng pos, {double zoom = 16}) {
    _mapController.move(pos, zoom);
  }

  List<NaolibStation> _filterNearbyStations(
      List<NaolibStation> stations, double lat, double lon,
      {double radiusMeters = 1500}) {
    return stations.where((s) {
      final distance = Geolocator.distanceBetween(lat, lon, s.lat, s.lon);
      return distance <= radiusMeters;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final eventLoc = widget.event != null
        ? LatLng(widget.event!.latitude, widget.event!.longitude)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text("Stations Naolib")),
      body: FutureBuilder<List<NaolibStation>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          final stations = snapshot.data ?? [];

          // Stations proches de l'utilisateur et de l'événement
          final nearbyUser = _filterNearbyStations(
            stations,
            _currentLocation!.latitude,
            _currentLocation!.longitude,
            radiusMeters: 2000, 
          );

          final nearbyEvent = eventLoc != null
              ? _filterNearbyStations(
                  stations, eventLoc.latitude, eventLoc.longitude)
              : <NaolibStation>[];

          final markers = <Marker>[];

          // Marker position utilisateur
          markers.add(Marker(
            point: _currentLocation!,
            width: 40,
            height: 40,
            child: const Icon(Icons.person_pin_circle,
                size: 40, color: Colors.orange),
          ));

          // Marker position événement
          if (eventLoc != null) {
            markers.add(Marker(
              point: eventLoc,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, size: 40, color: Colors.red),
            ));
          }

          // Stations proches de l'utilisateur (bleu)
          for (var s in nearbyUser) {
            markers.add(Marker(
              point: LatLng(s.lat, s.lon),
              width: 80,
              height: 60,
              child: GestureDetector(
                onTap: () => _centerMapOn(LatLng(s.lat, s.lon)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_bike,
                        color: Colors.blue, size: 28),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 2,
                              offset: const Offset(0, 1))
                        ],
                      ),
                      child: Text(
                        "${s.availableBikes} vélos",
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ));
          }

          // Stations proches de l'événement (vert)
          for (var s in nearbyEvent) {
            markers.add(Marker(
              point: LatLng(s.lat, s.lon),
              width: 80,
              height: 60,
              child: GestureDetector(
                onTap: () => _centerMapOn(LatLng(s.lat, s.lon)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_bike,
                        color: Colors.green, size: 28),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 2,
                              offset: const Offset(0, 1))
                        ],
                      ),
                      child: Text(
                        "${s.availableStands} places",
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ));
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}
