import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  // Charger les pages depuis SharedPreferences
  Future<void> _loadPages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('dashboard_pages');
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      setState(() {
        pages = decoded
            .map((e) => DashboardPage.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } else {
      // Si pas de données, créer deux pages par défaut
      setState(() {
        pages = [
          DashboardPage(name: "Mobilité", widgets: []),
          DashboardPage(name: "Événements", widgets: []),
        ];
      });
    }
  }

  // Sauvegarder les pages
  Future<void> _savePages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(pages.map((e) => e.toJson()).toList());
    await prefs.setString('dashboard_pages', jsonString);
  }

  void _addWidgetToPage(DashboardWidget widget) {
    if (pages[_currentPage].widgets.length >= 6) return;
    setState(() {
      pages[_currentPage].widgets.add(widget);
    });
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
    TextEditingController controller =
        TextEditingController(text: pages[_currentPage].name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Renommer la page"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                pages[_currentPage].name = controller.text;
              });
              _savePages();
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showAddWidgetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter un widget"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text("Recherche événements"),
                onTap: () {
                  _addWidgetToPage(DashboardWidget(
                      widget: const Text("Widget Événements")));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_parking),
                title: const Text("Recherche parkings"),
                onTap: () {
                  _addWidgetToPage(DashboardWidget(
                      widget: const Text("Widget Parkings")));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: const Text("Météo"),
                onTap: () {
                  _addWidgetToPage(
                      DashboardWidget(widget: const Text("Widget Météo")));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
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
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, pageIndex) {
                final page = pages[pageIndex];
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    itemCount: page.widgets.length < 6
                        ? page.widgets.length + 1
                        : 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, widgetIndex) {
                      if (widgetIndex < page.widgets.length) {
                        final widgetItem = page.widgets[widgetIndex];
                        return Card(
                          elevation: 5,
                          child: Center(child: widgetItem.widget),
                        );
                      } else {
                        return GestureDetector(
                          onTap: _showAddWidgetDialog,
                          child: Card(
                            color: Colors.grey[200],
                            child:
                                const Center(child: Icon(Icons.add, size: 50)),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
          // Page indicator (petits points)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.purple : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}

// Classes modèles

class DashboardPage {
  String name;
  List<DashboardWidget> widgets;

  DashboardPage({required this.name, required this.widgets});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'widgets': widgets.map((w) => w.toJson()).toList(),
    };
  }

  factory DashboardPage.fromJson(Map<String, dynamic> json) {
    final widgetList = (json['widgets'] as List<dynamic>)
        .map((e) => DashboardWidget.fromJson(e))
        .toList();
    return DashboardPage(name: json['name'], widgets: widgetList);
  }
}

class DashboardWidget {
  final String type; // pour identifier le type de widget
  final Widget widget;

  DashboardWidget({required this.widget, this.type = "text"});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': "", // ici tu peux stocker des infos si besoin
    };
  }

  factory DashboardWidget.fromJson(Map<String, dynamic> json) {
    return DashboardWidget(widget: const Text("Widget")); // reconstruct simple
  }
}
