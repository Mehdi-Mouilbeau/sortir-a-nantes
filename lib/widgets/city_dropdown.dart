import 'package:flutter/material.dart';

class CityDropdown extends StatelessWidget {
  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String?> onChanged;

  const CityDropdown({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        hint: const Text("Choisir une ville"),
        value: selectedCity,
        isExpanded: true,
        items: cities.map((city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
