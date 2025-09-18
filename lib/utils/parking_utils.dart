import 'package:geolocator/geolocator.dart';
import '../models/parking.dart';

List<Parking> filterNearbyParkings(
  List<Parking> parkings,
  double eventLat,
  double eventLon, {
  double radiusInMeters = 1000,
}) {
  return parkings.where((p) {
    final distance = Geolocator.distanceBetween(
      eventLat,
      eventLon,
      p.lat,
      p.lon,
    );
    return distance <= radiusInMeters && p.available > 0;
  }).toList();
}
