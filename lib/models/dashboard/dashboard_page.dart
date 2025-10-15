import 'package:sortir_a_nantes/widgets/dashboard/dashboard_weather_card.dart';

import 'dashboard_widget.dart';

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

  DashboardWidget createWidget(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'weather':
        return DashboardWidget(
          widget: DashboardWeatherCard(
            weatherData: data['weatherData'] ?? {},
            city: data['city'] ?? '',
            airQualityData: data['airQualityData'],
          ),
          type: 'weather',
          data: data,
        );
      // Add more cases for different widget types
      default:
        throw Exception('Widget type $type not recognized');
    }
  }
}
