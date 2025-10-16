import 'package:flutter/material.dart';
import 'package:sortir_a_nantes/models/event/event.dart';
import 'package:sortir_a_nantes/services/events/event_service.dart';
import 'package:sortir_a_nantes/services/notification_service.dart';
import 'package:sortir_a_nantes/widgets/weather/weather_widget.dart';
import 'package:sortir_a_nantes/widgets/events/event_card.dart';
import 'package:sortir_a_nantes/screens/events/event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    _eventsFuture = EventService().fetchEvents(
      startDate: now,
      endDate: nextWeek,
      limit: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Erreur : ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucun événement trouvé"));
        }

        final events = snapshot.data!;
        final displayCount = events.length > 6 ? 6 : events.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Vos événements à Nantes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(child: WeatherWidget(latitude: 47.2184, longitude: -1.5536)),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await NotificationService().testNotification();
                },
                child: const Text("Tester une notif immédiate"),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: displayCount,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventCard(
                    event: event,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
