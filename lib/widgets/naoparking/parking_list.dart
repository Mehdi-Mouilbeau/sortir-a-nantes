import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sortir_a_nantes/models/parking.dart';
import 'package:sortir_a_nantes/utils/maps_redirection.dart';

class ParkingList extends StatelessWidget {
  final List<Parking> parkings;
  final MapController mapController;

  const ParkingList({
    super.key,
    required this.parkings,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    if (parkings.isEmpty) {
      return const Center(
        child: Text("Aucun parking disponible à 500 m.",
            style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.separated(
      itemCount: parkings.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final p = parkings[index];
        return ListTile(
          leading: const Icon(Icons.local_parking, color: Colors.blue),
          title: Text(
            p.name.isNotEmpty ? p.name : "Parking sans nom",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(p.address),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${p.available} libres",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.directions_outlined),
                onPressed: () => openGoogleMaps(p.lat, p.lon),
              ),
            ],
          ),
          onTap: () => mapController.move(LatLng(p.lat, p.lon), 17),
        );
      },
    );
  }
}
