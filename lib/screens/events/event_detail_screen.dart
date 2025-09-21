import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortir_a_nantes/main.dart';
import 'package:sortir_a_nantes/models/event.dart';
import 'package:sortir_a_nantes/screens/parkings/parking_screen.dart';
import 'package:sortir_a_nantes/screens/velib/naolib_event_screen.dart';
import 'package:sortir_a_nantes/services/notification_service.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool isPlanned = false;

  @override
  void initState() {
    super.initState();
    _loadPlannedStatus();
  }

  Future<void> _loadPlannedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final plannedEvents = prefs.getStringList("plannedEvents") ?? [];
    setState(() {
      isPlanned = plannedEvents.contains(widget.event.id.toString());
    });
  }

  Future<void> _togglePlanned() async {
    final prefs = await SharedPreferences.getInstance();
    final plannedEvents = prefs.getStringList("plannedEvents") ?? [];

    if (isPlanned) {
      plannedEvents.removeWhere((e) {
        try {
          final map = jsonDecode(e) as Map<String, dynamic>;
          final storedId = (map['id_manif'] ?? map['id'] ?? '').toString();
          return storedId == widget.event.id.toString();
        } catch (_) {
          return false;
        }
      });
    } else {
      plannedEvents.add(jsonEncode(widget.event.toJson()));
    }

    await prefs.setStringList("plannedEvents", plannedEvents);

    setState(() {
      isPlanned = !isPlanned;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPlanned
            ? "Événement ajouté à mon agenda 🎉"
            : "Événement retiré de mon agenda"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng eventLocation =
        LatLng(widget.event.latitude, widget.event.longitude);

    return Scaffold(
      appBar: AppBar(title: Text(widget.event.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(widget.event.description),
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
                            eventLat: widget.event.latitude,
                            eventLon: widget.event.longitude,
                            eventName: widget.event.name,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_parking),
                    label: const Text("Voir les parkings disponibles"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await flutterLocalNotificationsPlugin
                          .resolvePlatformSpecificImplementation<
                              IOSFlutterLocalNotificationsPlugin>()
                          ?.requestPermissions(
                              alert: true, badge: true, sound: true);

                      await flutterLocalNotificationsPlugin
                          .resolvePlatformSpecificImplementation<
                              AndroidFlutterLocalNotificationsPlugin>()
                          ?.requestNotificationsPermission();

                      await NotificationService().scheduleNotification(
                        id: int.parse(widget.event.id),
                        title: widget.event.name,
                        body: widget.event.description,
                        scheduledDate: widget.event.date,
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
                    onPressed: _togglePlanned,
                    icon: Icon(isPlanned ? Icons.check : Icons.event_available,
                        color: Colors.white),
                    label: Text(isPlanned
                        ? "Retirer de mon agenda"
                        : "Ajouter à mon agenda"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPlanned
                          ? Colors.red
                          : const Color.fromRGBO(33, 150, 243, 1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NaolibEventScreen(event: widget.event),
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
