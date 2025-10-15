import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sortir_a_nantes/models/parking.dart';
import 'package:sortir_a_nantes/services/parking_service.dart';
import 'package:sortir_a_nantes/services/geocoding_service.dart';
import 'package:sortir_a_nantes/utils/parking_utils.dart';
import 'package:sortir_a_nantes/widgets/naoparking/parking_list.dart';
import 'package:sortir_a_nantes/widgets/naoparking/parking_map.dart';

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

  Future<void> _fetchSuggestions(String query) async {
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isSearching = true);
    final results = await GeocodingService.fetchSuggestions(query);
    setState(() {
      _suggestions = results;
      _isSearching = false;
    });
  }

  Future<void> _searchByAddress(String address) async {
    final coords = await GeocodingService.geocodeAddress(address);
    if (coords != null) {
      _searchAddress(coords, address);
    }
  }

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
    FocusScope.of(context).unfocus();
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
          // Barre de recherche
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
                  onSubmitted: _searchByAddress,
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
                        final s = _suggestions[index];
                        return ListTile(
                          leading: const Icon(Icons.place, color: Colors.blue),
                          title: Text(
                            s["display_name"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _searchAddress(
                            LatLng(s["lat"], s["lon"]),
                            s["display_name"],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Résultats
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
            Expanded(
              child: FutureBuilder<List<Parking>>(
                future: _nearbyParkingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Erreur : ${snapshot.error}"));
                  }

                  final parkings = snapshot.data ?? [];

                  return Column(
                    children: [
                      ParkingMap(
                        mapController: _mapController,
                        center: _searchedLocation!,
                        parkings: parkings,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ParkingList(
                          parkings: parkings,
                          mapController: _mapController,
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
