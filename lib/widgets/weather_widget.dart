import 'package:flutter/material.dart';
import 'package:sortir_a_nantes/services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherWidget({super.key, required this.latitude, required this.longitude});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final data = await WeatherService().getCurrentWeather(
      widget.latitude,
      widget.longitude,
    );
    debugPrint('Weather raw data: $data');
    setState(() {
      weatherData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 100,
        height: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (weatherData == null) {
      return const Text("Météo indisponible");
    }

    final temp = weatherData!['main']['temp'].toStringAsFixed(0);
    final condition = weatherData!['weather'][0]['description'];
    final iconCode = weatherData!['weather'][0]['icon'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            'https://openweathermap.org/img/wn/$iconCode.png',
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$temp°C", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(condition, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
