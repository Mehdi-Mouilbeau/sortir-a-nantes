import 'package:flutter/material.dart';
import '../../models/event.dart';
import './event_detail_screen.dart';
import '../../services/event_service.dart';
import '../../widgets/city_dropdown.dart';
import '../../widgets/date_filter_dropdown.dart';

enum DateFilter {
  today,
  next3Days,
  thisWeek,
  custom,
}

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String? selectedCity;
  List<String> cities = [];

  DateFilter? selectedDateFilter;
  DateTimeRange? customRange;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  void _loadCities() async {
    try {
      final fetchedCities = await EventService().fetchCities();
      setState(() {
        cities = fetchedCities;
      });
    } catch (e) {
      print("Erreur chargement villes: $e");
    }
  }

  DateTime? getStartDate() {
    final now = DateTime.now();
    switch (selectedDateFilter) {
      case DateFilter.today:
        return DateTime(now.year, now.month, now.day);
      case DateFilter.next3Days:
      case DateFilter.thisWeek:
        return DateTime(now.year, now.month, now.day);
      case DateFilter.custom:
        return customRange?.start;
      default:
        return null;
    }
  }

  DateTime? getEndDate() {
    final now = DateTime.now();
    switch (selectedDateFilter) {
      case DateFilter.today:
        return DateTime(now.year, now.month, now.day);
      case DateFilter.next3Days:
        return DateTime(now.year, now.month, now.day).add(const Duration(days: 3));
      case DateFilter.thisWeek:
        return DateTime(now.year, now.month, now.day).add(const Duration(days: 7));
      case DateFilter.custom:
        return customRange?.end;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDate = getStartDate();
    final endDate = getEndDate();

    return Scaffold(
      appBar: AppBar(title: const Text("Évènements")),
      body: Column(
        children: [
          // Dropdown pour sélectionner la ville
          CityDropdown(
            cities: cities,
            selectedCity: selectedCity,
            onChanged: (value) {
              setState(() {
                selectedCity = value;
              });
            },
          ),

          // Dropdown pour filtrer par date
          DateFilterDropdown(
            selectedDateFilter: selectedDateFilter,
            onChanged: (value) async {
              if (value == DateFilter.custom) {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (range != null) {
                  setState(() {
                    customRange = range;
                    selectedDateFilter = value;
                  });
                }
              } else {
                setState(() {
                  selectedDateFilter = value;
                  customRange = null;
                });
              }
            },
          ),

          // Liste des événements
          Expanded(
            child: FutureBuilder<List<Event>>(
              future: EventService().fetchEvents(
                city: selectedCity,
                startDate: startDate,
                endDate: endDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Erreur : ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucun évènement trouvé"));
                }

                final events = snapshot.data!;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text(event.name),
                      subtitle: Text("${event.placeName} - ${event.city}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailScreen(event: event),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
