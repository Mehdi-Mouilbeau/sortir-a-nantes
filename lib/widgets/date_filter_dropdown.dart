import 'package:flutter/material.dart';
import '../screens/events/events_list_screen.dart'; // pour DateFilter

class DateFilterDropdown extends StatelessWidget {
  final DateFilter? selectedDateFilter;
  final ValueChanged<DateFilter?> onChanged;

  const DateFilterDropdown({
    super.key,
    required this.selectedDateFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<DateFilter>(
        hint: const Text("Filtrer par date"),
        value: selectedDateFilter,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: DateFilter.today, child: Text("Aujourd'hui")),
          DropdownMenuItem(
              value: DateFilter.next3Days, child: Text("3 prochains jours")),
          DropdownMenuItem(value: DateFilter.thisWeek, child: Text("Cette semaine")),
          DropdownMenuItem(value: DateFilter.custom, child: Text("Choisir une période")),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
