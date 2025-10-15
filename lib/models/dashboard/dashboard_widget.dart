import 'package:flutter/material.dart';
import '../../widgets/dashboard/dashboard_event_card.dart';

class DashboardWidget {
  final String type;
  final Widget widget;
  final Map<String, dynamic> data;

  DashboardWidget({
    required this.widget,
    this.type = "text",
    this.data = const {},
  });

  Map<String, dynamic> toJson() {
    return {'type': type, 'data': data};
  }

  factory DashboardWidget.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final data = json['data'] as Map<String, dynamic>? ?? {};

    switch (type) {
      case 'event':
        return DashboardWidget(
          widget: DashboardEventCard(eventData: data),
          type: 'event',
          data: data,
        );
      case 'weather':
        return DashboardWidget(
          widget: Text('Météo à ${data['city'] ?? ''}'),
          type: 'weather',
          data: data,
        );
      default:
        return DashboardWidget(
          widget: const Text("Widget inconnu"),
          type: type,
          data: data,
        );
    }
  }
}
