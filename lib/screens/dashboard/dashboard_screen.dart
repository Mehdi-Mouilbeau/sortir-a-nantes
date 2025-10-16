import 'package:flutter/material.dart';
import 'package:sortir_a_nantes/models/dashboard/dashboard_page.dart';
import 'package:sortir_a_nantes/models/dashboard/dashboard_widget.dart';
import 'package:sortir_a_nantes/screens/events/events_list_screen.dart';
import 'package:sortir_a_nantes/screens/weather/weather_config_screen.dart';
import 'package:sortir_a_nantes/services/dashboard/dashboard_storage.dart';
import 'package:sortir_a_nantes/services/geocoding_service.dart';
import 'package:sortir_a_nantes/services/weather/weather_service.dart';
import 'package:sortir_a_nantes/widgets/dashboard/dashboard_event_card.dart';
import 'package:sortir_a_nantes/widgets/dashboard/dashboard_weather_card.dart';
import 'package:sortir_a_nantes/widgets/weather/weather_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  List<DashboardPage> pages = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    final loaded = await DashboardStorage.loadPages();
    setState(() => pages = loaded);
  }

  Future<void> _savePages() async => DashboardStorage.savePages(pages);

  void _addWidgetToPage(DashboardWidget widget) {
    if (pages[_currentPage].widgets.length >= 6) return;
    setState(() => pages[_currentPage].widgets.add(widget));
    _savePages();
  }

  void _addNewPage() {
    setState(() {
      pages.add(DashboardPage(name: "Nouvelle page", widgets: []));
      _currentPage = pages.length - 1;
      _pageController.jumpToPage(_currentPage);
    });
    _savePages();
  }

  void _renameCurrentPage() {
    final controller = TextEditingController(text: pages[_currentPage].name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Renommer la page"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => pages[_currentPage].name = controller.text);
              _savePages();
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _addWeatherWidget() async {
  // Ouvre l'écran de configuration pour choisir une ville
  final city = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => WeatherConfigScreen()),
  );

  if (city != null) {
    // Récupère les coordonnées de la ville
    final coords = await GeocodingService.getCoordinates(city);

    if (coords != null) {
      // On n'a plus besoin de récupérer weatherData ici puisque WeatherWidget le fera
      _addWidgetToPage(
        DashboardWidget(
          widget: WeatherWidget(
            latitude: coords.latitude,
            longitude: coords.longitude,
          ),
          type: 'weather',
          data: {
            'city': city,
          },
        ),
      );
    }
  }
}


  void _showAddWidgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un widget"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text("Recherche événements"),
              onTap: () async {
                Navigator.pop(context);
                final config = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventListScreen()),
                );
                if (config != null && config['event'] != null) {
                  _addWidgetToPage(
                    DashboardWidget(
                      widget: DashboardEventCard(eventData: config['event']),
                      type: "event",
                      data: config['event'],
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_parking),
              title: const Text("Recherche parkings"),
              onTap: () {
                _addWidgetToPage(DashboardWidget(
                    widget: const Text("Widget Parkings"), type: "parking"));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text("Météo"),
              onTap: () async {
                Navigator.pop(context); 
                _addWeatherWidget();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pages[_currentPage].name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewPage,
            tooltip: "Ajouter une page",
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _renameCurrentPage,
            tooltip: "Renommer la page",
          ),
        ],
      ),
      body: SafeArea(
        // ✅ Correction : évite que les points soient cachés sous la barre Android
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, pageIndex) {
                  final page = pages[pageIndex];
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      itemCount:
                          page.widgets.length < 6 ? page.widgets.length + 1 : 6,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, widgetIndex) {
                        if (widgetIndex < page.widgets.length) {
                          return Card(
                            elevation: 5,
                            child:
                                Center(child: page.widgets[widgetIndex].widget),
                          );
                        } else {
                          return GestureDetector(
                            onTap: _showAddWidgetDialog,
                            child: Card(
                              color: Colors.grey[200],
                              child: const Center(
                                  child: Icon(Icons.add, size: 50)),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: _currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index ? Colors.purple : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
