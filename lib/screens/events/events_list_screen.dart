import 'package:flutter/material.dart';
import 'package:sortir_a_nantes/widgets/event_card_list.dart';
import '../../models/event.dart';
import './event_detail_screen.dart';
import '../../services/event_service.dart';
import '../../widgets/city_dropdown.dart';
import '../../widgets/date_filter_dropdown.dart';
import '../../widgets/theme_dropdown.dart';

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

  List<String> allThemes = [];
  List<String> selectedThemes = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
    _loadThemes();
  }

  void _loadCities() async {
    try {
      final fetchedCities = await EventService().fetchCities();
      setState(() {
        cities = fetchedCities;
      });
    } catch (e) {
      debugPrint("Erreur chargement villes: $e");
    }
  }

  void _loadThemes() async {
    try {
      final fetchedThemes = await EventService().fetchThemes();
      setState(() {
        allThemes = fetchedThemes;
      });
    } catch (e) {
      debugPrint("Erreur chargement thèmes: $e");
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
        return DateTime(now.year, now.month, now.day)
            .add(const Duration(days: 3));
      case DateFilter.thisWeek:
        return DateTime(now.year, now.month, now.day)
            .add(const Duration(days: 7));
      case DateFilter.custom:
        return customRange?.end;
      default:
        return null;
    }
  }

  bool get hasFilters {
    return (selectedCity != null && selectedCity!.isNotEmpty) ||
        selectedDateFilter != null ||
        selectedThemes.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final startDate = getStartDate();
    final endDate = getEndDate();

    return Scaffold(
      appBar: AppBar(title: const Text("Évènements")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8, // espace horizontal
              runSpacing: 8, // espace vertical si ça passe à la ligne
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 -
                      16, // moitié de l’écran
                  child: CityDropdown(
                    cities: cities,
                    selectedCity: selectedCity,
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 16,
                  child: DateFilterDropdown(
                    selectedDateFilter: selectedDateFilter,
                    onChanged: (value) async {
                      if (value == DateFilter.custom) {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
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
                ),
              ],
            ),
          ),

          if (allThemes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ThemeDropdown(
                allThemes: allThemes,
                selectedThemes: selectedThemes,
                onChanged: (values) {
                  setState(() {
                    selectedThemes = values;
                  });
                },
              ),
            ),

          // Liste des événements
          Expanded(
            child: hasFilters
                ? FutureBuilder<List<Event>>(
                    future: EventService().fetchEvents(
                      city: selectedCity,
                      startDate: startDate,
                      endDate: endDate,
                      themes: selectedThemes,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text("Erreur : ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text("Aucun évènement trouvé"));
                      }

                      final events = snapshot.data!;
                      return ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return EventCardList(
                            event: event,
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
                  )
                : const Center(
                    child: Text(
                        "Choisis une ville, une date ou un thème pour afficher les évènements"),
                  ),
          ),
        ],
      ),
    );
  }
}
