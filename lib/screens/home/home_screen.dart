import 'package:flutter/material.dart';
import 'package:sortir_a_nantes/screens/events/events_list_screen.dart';
import 'package:sortir_a_nantes/screens/velib/naolib_map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sortir à Nantes")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou icône
              const Icon(Icons.event, size: 100, color: Colors.purple),

              const SizedBox(height: 20),

              const Text(
                "Bienvenue dans Sortir à Nantes",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const Text(
                "Découvrez les événements à venir, trouvez un parking à proximité et profitez de la ville !",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EventListScreen()),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text("Voir les événements"),
              ),
              // ElevatedButton.icon(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => const NaolibMapScreen()),
              //     );
              //   },
              //   icon: const Icon(Icons.pedal_bike),
              //   label: const Text("Stations vélo Naolib"),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
