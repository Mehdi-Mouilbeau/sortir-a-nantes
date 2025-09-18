import 'package:flutter/material.dart';
import 'package:sortir_a_nantes/screens/home/home_screen.dart';
import 'services/permissions_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PermissionsService.requestNotificationPermission();

  await PermissionsService.requestLocationPermission();

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
