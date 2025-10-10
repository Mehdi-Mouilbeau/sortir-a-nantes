import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortir_a_nantes/models/event.dart';
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
      plannedEvents =
          plannedJson.map((e) => Event.fromJson(jsonDecode(e))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AgendaCalendar(
      events: plannedEvents,
      onEventChanged: _loadPlannedEvents,
    );
  }
}
