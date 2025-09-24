import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sortir_a_nantes/screens/home/home_screen.dart';
import 'package:sortir_a_nantes/services/notification_service.dart';
import 'package:sortir_a_nantes/services/permissions_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialisation des services
  await NotificationService().init();
  await PermissionsService.requestNotificationPermission();
  await PermissionsService.requestLocationPermission();

  await initializeDateFormatting('fr_FR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sorties en Ville',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
