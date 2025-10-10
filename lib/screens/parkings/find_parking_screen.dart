import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sortir_a_nantes/models/parking.dart';
import 'package:sortir_a_nantes/services/parking_service.dart';
import 'package:sortir_a_nantes/utils/parking_utils.dart';
import 'package:sortir_a_nantes/utils/maps_redirection.dart';

class FindParkingScreen extends StatefulWidget {
  const FindParkingScreen({super.key});

  @override
  State<FindParkingScreen> createState() => _FindParkingScreenState();
}

class _FindParkingScreenState extends State<FindParkingScreen> {
  final TextEditingController _addressController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng? _searchedLocation;
  Future<List<Parking>>? _nearbyParkingsFuture;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearching = false;

  /// adresse précise
  Future<LatLng?> _geocodeAddress(String address) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?format=json&q=$address&limit=1&countrycodes=fr");

    final response = await http.get(url, headers: {
      "User-Agent": "sortir_a_nantes_app/1.0 (contact@example.com)"
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  /// Suggestions d’adresses (auto-complétion)
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
    } else {
      setState(() => _suggestions = []);
    }

    setState(() => _isSearching = false);
  }

  /// Charge les parkings à proximité (500 m)
  Future<List<Parking>> _loadNearbyParkings(LatLng pos) async {
    try {
      final all = await ParkingService().fetchParkings();
      return filterNearbyParkings(
        all,
        pos.latitude,
        pos.longitude,
        radiusInMeters: 500,
      );
    } catch (e) {
      debugPrint("Erreur parkings : $e");
      return [];
    }
  }

  void _searchAddress(LatLng coords, String label) {
    FocusScope.of(context).unfocus(); // ferme le clavier
    _addressController.text = label;
    setState(() {
      _searchedLocation = coords;
      _suggestions = [];
      _nearbyParkingsFuture = _loadNearbyParkings(coords);
    });
    _mapController.move(coords, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trouver un parking")),
      body: Column(
        children: [
          //  Barre de recherche
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
                    if (coords != null) {
                      _searchAddress(coords, value);
                    }
                  },
                ),

                //  Liste des suggestions
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
                          leading: const Icon(Icons.place, color: Colors.blue),
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

          // Si aucune adresse saisie encore
          if (_searchedLocation == null)
            const Expanded(
              child: Center(
                child: Text(
                  "Entrez une adresse pour voir les parkings à proximité.",
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            // Résultats (carte + liste)
            Expanded(
              child: FutureBuilder<List<Parking>>(
                future: _nearbyParkingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Erreur : ${snapshot.error.toString()}"));
                  }

                  final parkings = snapshot.data ?? [];
                  final markers = <Marker>[
                    Marker(
                      point: _searchedLocation!,
                      width: 48,
                      height: 48,
                      child: const Icon(Icons.location_on,
                          size: 40, color: Colors.red),
                    ),
                    ...parkings.map(
                      (p) => Marker(
                        point: LatLng(p.lat, p.lon),
                        width: 80,
                        height: 60,
                        child: Column(
                          children: [
                            const Icon(Icons.local_parking,
                                size: 28, color: Colors.blue),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
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
                        child: parkings.isEmpty
                            ? const Center(
                                child: Text(
                                  "Aucun parking disponible à 500 m.",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ListView.separated(
                                itemCount: parkings.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final p = parkings[index];
                                  return ListTile(
                                    leading: const Icon(Icons.local_parking,
                                        color: Colors.blue),
                                    title: Text(
                                        p.name.isNotEmpty
                                            ? p.name
                                            : "Parking sans nom",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(p.address),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "${p.available} libres",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.directions_outlined),
                                          onPressed: () =>
                                              openGoogleMaps(p.lat, p.lon),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _mapController.move(
                                        LatLng(p.lat, p.lon), 17),
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
