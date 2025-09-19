import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sortir_a_nantes/models/event.dart';
import 'package:sortir_a_nantes/screens/parkings/parking_screen.dart';
import 'package:sortir_a_nantes/screens/velib/naolib_event_screen.dart';
import 'package:sortir_a_nantes/services/favorite_service.dart';
import 'package:sortir_a_nantes/services/notification_service.dart';
import 'package:sortir_a_nantes/widgets/notification_pluging.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final LatLng eventLocation = LatLng(event.latitude, event.longitude);

    return Scaffold(
      appBar: AppBar(title: Text(event.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(event.description),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: eventLocation,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: eventLocation,
                        width: 48,
                        height: 48,
                        child: const Icon(Icons.location_on,
                            size: 40, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParkingScreen(
                            eventLat: event.latitude,
                            eventLon: event.longitude,
                            eventName: event.name,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_parking),
                    label: const Text("Voir les parkings disponibles"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await NotificationService().scheduleNotification(
                        id: int.parse(event.id),
                        title: event.name,
                        body: event.description,
                        scheduledDate: event.date, // Ensure event.date is a DateTime
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Notification programmée !')),
                      );
                    },
                    icon: const Icon(Icons.notifications),
                    label: const Text("Me rappeler de cet événement"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NaolibEventScreen(event: event),
                        ),
                      );
                    },
                    icon:
                        const Icon(Icons.directions_bike, color: Colors.white),
                    label: const Text("Trouver un vélo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
