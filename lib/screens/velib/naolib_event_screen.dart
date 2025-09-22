import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/naolib_station.dart';
import '../../models/event.dart';
import '../../services/naolib_service.dart';

class NaolibEventScreen extends StatefulWidget {
  final Event event;

  const NaolibEventScreen({super.key, required this.event});

  @override
  State<NaolibEventScreen> createState() => _NaolibEventScreenState();
}

class _NaolibEventScreenState extends State<NaolibEventScreen> {
  late Future<List<NaolibStation>> _stationsFuture;
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _stationsFuture = NaolibService().fetchStations();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint("Erreur position actuelle : $e");
    }
  }

  List<NaolibStation> _filterNearbyStations(
    List<NaolibStation> stations,
    double lat,
    double lon, {
    double radiusMeters = 1500,
  }) {
    return stations.where((s) {
      final distance = Geolocator.distanceBetween(lat, lon, s.lat, s.lon);
      return distance <= radiusMeters;
    }).toList();
  }

  void _centerMapOn(LatLng pos, {double zoom = 16}) {
    _mapController.move(pos, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final eventLoc = LatLng(widget.event.latitude, widget.event.longitude);

    return Scaffold(
      appBar: AppBar(title: const Text("Stations Naolib")),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<NaolibStation>>(
              future: _stationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Erreur : ${snapshot.error.toString()}"));
                }

                final stations = snapshot.data ?? [];

                final nearbyUser = _filterNearbyStations(
                  stations,
                  _currentLocation!.latitude,
                  _currentLocation!.longitude,
                );
                final nearbyEvent = _filterNearbyStations(
                  stations,
                  eventLoc.latitude,
                  eventLoc.longitude,
                );

                final markers = <Marker>[
                  Marker(
                    point: _currentLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.person_pin_circle,
                        size: 40, color: Colors.orange),
                  ),
                  Marker(
                    point: eventLoc,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on,
                        size: 40, color: Colors.red),
                  ),
                  ...nearbyUser.map((s) => Marker(
                        point: LatLng(s.lat, s.lon),
                        width: 60,
                        height: 60,
                        child: const Icon(Icons.directions_bike,
                            size: 28, color: Colors.blue),
                      )),
                  ...nearbyEvent.map((s) => Marker(
                        point: LatLng(s.lat, s.lon),
                        width: 60,
                        height: 60,
                        child: const Icon(Icons.directions_bike,
                            size: 28, color: Colors.green),
                      )),
                ];

                return Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentLocation!,
                          initialZoom: 14,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.example.sortir_a_nantes',
                          ),
                          MarkerLayer(markers: markers),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("🚴‍♂️ Prendre un vélo près de moi",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          ...nearbyUser.map((s) => Card(
                                child: ListTile(
                                  leading: const Icon(Icons.directions_bike,
                                      color: Colors.blue),
                                  title: Text(s.name),
                                  subtitle: Text(s.address),
                                  trailing: Text("${s.availableBikes} vélos",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  onTap: () => _centerMapOn(
                                      LatLng(s.lat, s.lon),
                                      zoom: 17),
                                ),
                              )),
                          const Divider(),

                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                                "📍 Déposer un vélo près de l'événement",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          ...nearbyEvent.map((s) => Card(
                                child: ListTile(
                                  leading: const Icon(Icons.local_parking,
                                      color: Colors.green),
                                  title: Text(s.name),
                                  subtitle: Text(s.address),
                                  trailing: Text("${s.availableStands} places",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  onTap: () => _centerMapOn(
                                      LatLng(s.lat, s.lon),
                                      zoom: 17),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
