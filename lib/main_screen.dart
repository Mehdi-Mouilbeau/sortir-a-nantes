import 'package:flutter/material.dart';
import 'package:sortir_a_nantes/screens/home/home_screen.dart';
import 'package:sortir_a_nantes/screens/events/events_list_screen.dart';
import 'package:sortir_a_nantes/screens/discorver/discover.dart';
import 'package:sortir_a_nantes/screens/agenda/agenda_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    EventListScreen(),
    DiscoverScreen(),
    AgendaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sortir à Nantes")),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true, // <-- tous les labels visibles
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Découvrir"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Événements"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Rechercher"),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: "Agenda"),
        ],
      ),
    );
  }
}
