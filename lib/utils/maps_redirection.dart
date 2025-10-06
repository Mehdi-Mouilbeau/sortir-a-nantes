import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps(
    double destinationLat, double destinationLng) async {
  // Google Maps directions depuis la position actuelle
  final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=driving');

  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    throw 'Impossible d’ouvrir Google Maps';
  }
}
