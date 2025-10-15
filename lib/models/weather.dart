class SimpleWeather {
  final String description;
  final String icon; 
  final double temperature; 
  final double feelsLike; 
  final int humidity; 
  final double pressure; 
  final double windSpeed; 
  final int windDeg; 
  final double? rain;
  final int clouds;
  final int visibility;
  final double? airQuality;
  final int? pollenLevel;
  final int sunrise;
  final int sunset;
  final bool weatherChangingSoon;

  SimpleWeather({
    required this.description,
    required this.icon,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDeg,
    this.rain,
    required this.clouds,
    required this.visibility,
    this.airQuality,
    this.pollenLevel,
    required this.sunrise,
    required this.sunset,
    required this.weatherChangingSoon,
  });

  factory SimpleWeather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? {};
    final weatherList = (current['weather'] as List?) ?? [];
    final weather = weatherList.isNotEmpty ? weatherList.first : {};

    return SimpleWeather(
      description: weather['description'] ?? 'Inconnu',
      icon: weather['icon'] ?? '',
      temperature: (current['temp'] ?? 0).toDouble(),
      feelsLike: (current['feels_like'] ?? 0).toDouble(),
      humidity: current['humidity'] ?? 0,
      pressure: (current['pressure'] ?? 0).toDouble(),
      windSpeed: (current['wind_speed'] ?? 0).toDouble(),
      windDeg: current['wind_deg'] ?? 0,
      rain: (current['rain']?['1h'] ?? 0).toDouble(),
      clouds: current['clouds'] ?? 0,
      visibility: current['visibility'] ?? 0,
      airQuality: (json['air_quality']?['aqi'] ?? 0).toDouble(),
      pollenLevel: json['pollen']?['index'],
      sunrise: current['sunrise'] ?? 0,
      sunset: current['sunset'] ?? 0,
      weatherChangingSoon: _isWeatherChangingSoon(json),
    );
  }

  static bool _isWeatherChangingSoon(Map<String, dynamic> json) {
    final hourly = (json['hourly'] as List?) ?? [];
    if (hourly.length < 2) return false;

    final now = (hourly[0]['weather'] as List?)?.first?['main'] ?? '';
    final next = (hourly[1]['weather'] as List?)?.first?['main'] ?? '';
    return now != next;
  }
}
