import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sortir_a_nantes/models/naolib_station.dart';
import 'package:sortir_a_nantes/services/naolib_service.dart';
import 'package:sortir_a_nantes/utils/maps_redirection.dart';
import 'package:geolocator/geolocator.dart';

class FindBikeStationScreen extends StatefulWidget {
  const FindBikeStationScreen({super.key});

  @override
  State<FindBikeStationScreen> createState() => _FindBikeStationScreenState();
}

class _FindBikeStationScreenState extends State<FindBikeStationScreen> {
  final TextEditingController _addressController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng? _searchedLocation;
  Future<List<NaolibStation>>? _nearbyStationsFuture;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearching = false;

  Future<void> _fetchSuggestions(String query) async {
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isSearching = true);

    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?format=json&q=$query&addressdetails=1&limit=5&countrycodes=fr");
    final response = await http.get(url, headers: {
      "User-Agent": "sortir_a_nantes_app/1.0 (contact@example.com)"
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      setState(() {
        _suggestions = data
            .map((item) => {
                  "display_name": item["display_name"],
                  "lat": double.parse(item["lat"]),
                  "lon": double.parse(item["lon"]),
                })
            .toList();
      });
    }

    setState(() => _isSearching = false);
  }

  Future<LatLng?> _geocodeAddress(String address) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?format=json&q=$address&limit=1&countrycodes=fr");
    final response = await http.get(url, headers: {
      "User-Agent": "sortir_a_nantes_app/1.0 (contact@example.com)"
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return LatLng(
          double.parse(data[0]['lat']),
          double.parse(data[0]['lon']),
        );
      }
    }
    return null;
  }

  Future<List<NaolibStation>> _loadNearbyStations(LatLng pos) async {
    try {
      final all = await NaolibService().fetchStations();
      return all.where((s) {
        final dist = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          s.lat,
          s.lon,
        );
        return dist <= 500; // rayon 500m
      }).toList();
    } catch (e) {
      debugPrint("Erreur chargement stations : $e");
      return [];
    }
  }

  void _searchAddress(LatLng coords, String label) {
    FocusScope.of(context).unfocus();
    _addressController.text = label;
    setState(() {
      _searchedLocation = coords;
      _suggestions = [];
      _nearbyStationsFuture = _loadNearbyStations(coords);
    });
    _mapController.move(coords, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trouver une station Naolib")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: "Entrez une adresse",
                    border: const OutlineInputBorder(),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                  ),
                  onChanged: _fetchSuggestions,
                  onSubmitted: (value) async {
                    final coords = await _geocodeAddress(value);
                    if (coords != null) _searchAddress(coords, value);
                  },
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          leading:
                              const Icon(Icons.place, color: Colors.orange),
                          title: Text(
                            suggestion["display_name"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            final coords = LatLng(
                              suggestion["lat"],
                              suggestion["lon"],
                            );
                            _searchAddress(coords, suggestion["display_name"]);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          if (_searchedLocation == null)
            const Expanded(
              child: Center(
                child: Text(
                  "Saisissez une adresse pour voir les stations Naolib à proximité.",
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: FutureBuilder<List<NaolibStation>>(
                future: _nearbyStationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Erreur : ${snapshot.error.toString()}"));
                  }

                  final stations = snapshot.data ?? [];

                  final markers = <Marker>[
                    Marker(
                      point: _searchedLocation!,
                      width: 48,
                      height: 48,
                      child: const Icon(Icons.location_on,
                          size: 40, color: Colors.red),
                    ),
                    ...stations.map(
                      (s) => Marker(
                        point: LatLng(s.lat, s.lon),
                        width: 80,
                        height: 60,
                        child: Column(
                          children: [
                            const Icon(Icons.pedal_bike,
                                size: 28, color: Colors.orange),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${s.availableBikes}",
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];

                  return Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _searchedLocation!,
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(markers: markers),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: stations.isEmpty
                            ? const Center(
                                child: Text(
                                  "Aucune station Naolib à 500 m.",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ListView.separated(
                                itemCount: stations.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final s = stations[index];
                                  return ListTile(
                                    leading: const Icon(Icons.pedal_bike,
                                        color: Colors.orange),
                                    title: Text(s.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(s.address),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "${s.availableBikes} vélos",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${s.availableStands} libres",
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.directions),
                                          onPressed: () => openGoogleMaps(
                                              s.lat, s.lon),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _mapController.move(
                                        LatLng(s.lat, s.lon), 17),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
