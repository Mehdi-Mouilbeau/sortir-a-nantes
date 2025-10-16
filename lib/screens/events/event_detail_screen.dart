import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortir_a_nantes/models/event/event.dart';
import 'package:sortir_a_nantes/screens/parkings/parking_screen.dart';
import 'package:sortir_a_nantes/screens/bikestation/naolib_event_screen.dart';
import 'package:sortir_a_nantes/services/notification_service.dart';
import 'package:sortir_a_nantes/utils/date_utils.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16).copyWith(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE DE L'ÉVÉNEMENT
              if (widget.event.image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.event.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                          child: Icon(Icons.broken_image, size: 50)),
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // TITRE
              Text(
                widget.event.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),

              // DESCRIPTION
              Text(widget.event.description),
              const SizedBox(height: 16),

              // CARTE
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
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.sortir_a_nantes',
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

              // BOUTONS
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
                        final DateTime now = DateTime.now();

                        // jamais avant aujourd’hui
                        final DateTime safeInitialDate =
                            widget.event.date.isBefore(now)
                                ? now
                                : widget.event.date;

                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: safeInitialDate,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 365)),
                        );

                        if (pickedDate == null) return;

                        // jamais avant l’heure actuelle si même jour
                        final TimeOfDay initialTime =
                            pickedDate.isAtSameMomentAs(DateTime(
                                    now.year, now.month, now.day))
                                ? TimeOfDay.fromDateTime(now)
                                : TimeOfDay.fromDateTime(widget.event.date);

                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: initialTime,
                        );

                        if (pickedTime == null) return;

                        final DateTime scheduledDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        if (scheduledDate.isBefore(now)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Impossible de programmer une notification dans le passé."),
                            ),
                          );
                          return;
                        }

                        debugPrint(
                            "Notification programmée pour : ${AppDateUtils.format(scheduledDate)}");

                        await NotificationService().scheduleNotification(
                          id: int.parse(widget.event.id),
                          title: widget.event.name,
                          body: widget.event.description,
                          scheduledDate: scheduledDate,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Notification programmée pour le ${AppDateUtils.format(scheduledDate)}",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications),
                      label: const Text("Me rappeler de cet événement"),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _togglePlanned,
                      icon: Icon(
                          isPlanned ? Icons.check : Icons.event_available,
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
                      icon: const Icon(Icons.directions_bike,
                          color: Colors.white),
                      label: const Text("Trouver un vélo"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Ajoute l'évènement au dashboard
                        Navigator.pop(context, {
                          'event': widget.event.toJson(),
                        });
                      },
                      icon: Icon(Icons.dashboard_customize),
                      label: Text("Ajouter cet évènement au dashboard"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
