import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sortir_a_nantes/models/naolib_station.dart';
import 'package:sortir_a_nantes/services/naolib_service.dart';
import 'package:sortir_a_nantes/widgets/naobike/address_search_bar.dart';
import 'package:sortir_a_nantes/widgets/naobike/stations_list.dart';
import 'package:sortir_a_nantes/widgets/naobike/stations_map.dart';

class FindBikeStationScreen extends StatefulWidget {
  const FindBikeStationScreen({super.key});

  @override
  State<FindBikeStationScreen> createState() => _FindBikeStationScreenState();
}

class _FindBikeStationScreenState extends State<FindBikeStationScreen> {
  final MapController _mapController = MapController();

  LatLng? _searchedLocation;
  Future<List<NaolibStation>>? _nearbyStationsFuture;

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
        return dist <= 500;
      }).toList();
    } catch (e) {
      debugPrint("Erreur chargement stations : $e");
      return [];
    }
  }

  void _onAddressSelected(LatLng coords, String label) {
    setState(() {
      _searchedLocation = coords;
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
          AddressSearchBar(onAddressSelected: _onAddressSelected),
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
                    return Center(child: Text("Erreur : ${snapshot.error}"));
                  }
                  final stations = snapshot.data ?? [];
                  return Column(
                    children: [
                      StationsMap(
                        searchedLocation: _searchedLocation!,
                        stations: stations,
                        mapController: _mapController,
                      ),
                      Expanded(child: StationsList(stations: stations)),
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
