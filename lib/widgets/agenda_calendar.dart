import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sortir_a_nantes/models/event/event.dart';
import 'package:sortir_a_nantes/screens/events/event_detail_screen.dart';

class AgendaCalendar extends StatefulWidget {
  final List<Event> events;
  final Function(DateTime, List<Event>)? onDaySelected;
  final VoidCallback?
      onEventChanged;

  const AgendaCalendar({
    super.key,
    required this.events,
    this.onDaySelected,
    this.onEventChanged,
  });

  @override
  State<AgendaCalendar> createState() => _AgendaCalendarState();
}

class _AgendaCalendarState extends State<AgendaCalendar> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void didUpdateWidget(covariant AgendaCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.events, widget.events)) {
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return widget.events.where((event) {
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    }).toList();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Event>(
          locale: "fr_FR",
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents.value = _getEventsForDay(selectedDay);
              });
              if (widget.onDaySelected != null) {
                widget.onDaySelected!(selectedDay, _selectedEvents.value);
              }
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return value.isEmpty
                  ? const Center(child: Text("Aucun événement ce jour-là"))
                  : ListView(
                      children: value
                          .map((e) => ListTile(
                                title: Text(e.name),
                                subtitle: Text(e.date.toString()),
                                leading: const Icon(Icons.event),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EventDetailScreen(event: e),
                                    ),
                                  );
                                  _selectedEvents.value =
                                      _getEventsForDay(_selectedDay!);
                                  if (widget.onEventChanged != null) {
                                    widget.onEventChanged!();
                                  }
                                },
                              ))
                          .toList(),
                    );
            },
          ),
        ),
      ],
    );
  }
}
