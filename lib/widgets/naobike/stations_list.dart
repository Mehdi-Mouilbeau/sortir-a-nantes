import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sortir_a_nantes/models/naolib_station.dart';
import 'package:sortir_a_nantes/utils/maps_redirection.dart';

class StationsList extends StatelessWidget {
  final List<NaolibStation> stations;

  const StationsList({super.key, required this.stations});

  @override
  Widget build(BuildContext context) {
    if (stations.isEmpty) {
      return const Center(
        child: Text("Aucune station Naolib à 500 m.", style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.separated(
      itemCount: stations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final s = stations[index];
        return ListTile(
          leading: const Icon(Icons.pedal_bike, color: Colors.orange),
          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(s.address),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${s.availableBikes} vélos", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text("${s.availableStands} libres", style: const TextStyle(color: Colors.grey)),
              IconButton(
                icon: const Icon(Icons.directions),
                onPressed: () => openGoogleMaps(s.lat, s.lon),
              ),
            ],
          ),
        );
      },
    );
  }
}
