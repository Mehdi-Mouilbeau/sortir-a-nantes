import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortir_a_nantes/models/event.dart';
import 'package:sortir_a_nantes/screens/events/event_detail_screen.dart';
import 'package:sortir_a_nantes/widgets/agenda_calendar.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  List<Event> plannedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadPlannedEvents();
  }

  Future<void> _loadPlannedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final plannedJson = prefs.getStringList("plannedEvents") ?? [];

    setState(() {
      plannedEvents = plannedJson
          .map((e) => Event.fromJson(jsonDecode(e)))
          .toList();
    });
  debugPrint("Planned stored: ${prefs.getStringList('plannedEvents')}");
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Mon agenda")),
    body: Column(
      children: [
        // Le calendrier visuel
        Expanded(
          flex: 2,
          child: AgendaCalendar(events: plannedEvents),
        ),

        const Divider(),

        // La liste classique
        Expanded(
          flex: 3,
          child: plannedEvents.isEmpty
              ? const Center(child: Text("Aucun événement dans ton agenda"))
              : ListView.builder(
                  itemCount: plannedEvents.length,
                  itemBuilder: (context, index) {
                    final event = plannedEvents[index];
                    return ListTile(
                      title: Text(event.name),
                      subtitle: Text(event.date.toString()),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailScreen(event: event),
                          ),
                        ).then((_) => _loadPlannedEvents());
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
