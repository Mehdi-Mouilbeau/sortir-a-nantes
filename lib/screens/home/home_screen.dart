import 'package:flutter/material.dart';
import 'package:sortir_a_nantes/models/event.dart';
import 'package:sortir_a_nantes/screens/agenda/agenda_screen.dart';
import 'package:sortir_a_nantes/screens/events/events_list_screen.dart';
import 'package:sortir_a_nantes/services/event_service.dart';
import 'package:sortir_a_nantes/widgets/weather_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Event>> _eventsFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _eventsFuture = EventService().fetchEvents(limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildDiscoverPage(),
      const EventListScreen(),
      const AgendaScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Sortir à Nantes")),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "Découvrir",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Événements",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: "Agenda",
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverPage() {
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
              // Section titre + météo
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
                  WeatherWidget(
                    latitude: 47.2184,
                    longitude: -1.5536,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // GridView des events
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: displayCount,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        event.image.isNotEmpty
                            ? Image.network(
                                event.image,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${event.city} • ${event.date.year}-${event.date.month.toString().padLeft(2, '0')}-${event.date.day.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
