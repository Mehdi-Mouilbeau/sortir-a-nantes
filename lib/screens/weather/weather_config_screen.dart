import 'package:flutter/material.dart';

class WeatherConfigScreen extends StatefulWidget {
  const WeatherConfigScreen({super.key});

  @override
  State<WeatherConfigScreen> createState() => _WeatherConfigScreenState();
}

class _WeatherConfigScreenState extends State<WeatherConfigScreen> {
  final TextEditingController _controller = TextEditingController();
  String? selectedCity;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rechercher une ville')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Ville',
                hintText: 'Tapez le nom de la ville',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedCity == null || selectedCity!.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context, selectedCity);
                    },
              child: Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
