import 'package:flutter/material.dart';

class DashboardWeatherCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final String city;
  final Map<String, dynamic>? airQualityData;

  const DashboardWeatherCard({
    super.key,
    required this.weatherData,
    required this.city,
    this.airQualityData,
  });

  @override
  Widget build(BuildContext context) {
    final current = weatherData['current'] ?? {};
    final weather = (current['weather'] as List?)?.isNotEmpty == true ? current['weather'][0] : {};
    final temp = current['temp']?.toString() ?? '--';
    final description = weather['description'] ?? '';
    final icon = weather['icon'] ?? '01d';

    // Air quality (OpenWeatherMap: aqi 1=good, 5=very poor)
    final airQuality = airQualityData?['main']?['aqi']?.toString() ?? 'N/A';

    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(city, style: Theme.of(context).textTheme.titleMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://openweathermap.org/img/wn/$icon@2x.png',
                  width: 48,
                  height: 48,
                  errorBuilder: (_, __, ___) => Icon(Icons.cloud),
                ),
                const SizedBox(width: 8),
                Text('$temp°C', style: const TextStyle(fontSize: 22)),
              ],
            ),
            Text(description, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text('Qualité de l\'air : $airQuality', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}