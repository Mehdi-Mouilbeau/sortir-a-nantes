import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps(double destinationLat, double destinationLng) async {
  // Google Maps directions depuis la position actuelle
  final url = 'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=driving';

  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Impossible d’ouvrir Google Maps';
  }
}