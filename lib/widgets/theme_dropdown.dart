import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class ThemeDropdown extends StatelessWidget {
  final List<String> allThemes;
  final List<String> selectedThemes;
  final Function(List<String>) onChanged;

  const ThemeDropdown({
    super.key,
    required this.allThemes,
    required this.selectedThemes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSelectDialogField<String>(
      items: allThemes.map((t) => MultiSelectItem(t, t)).toList(),
      initialValue: selectedThemes,
      title: const Text("Thématiques"),
      buttonText: const Text("Filtrer par thèmes"),
      buttonIcon: const Icon(Icons.filter_alt),
      searchable: true,
      onConfirm: (values) {
        onChanged(values);
      },
      chipDisplay: MultiSelectChipDisplay(
        chipColor: Colors.blue.shade100,
        textStyle: const TextStyle(color: Colors.black),
        onTap: (value) {
          final updated = List<String>.from(selectedThemes)..remove(value);
          onChanged(updated);
        },
      ),
    );
  }
}
