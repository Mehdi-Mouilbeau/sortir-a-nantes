# 🌆 Sortir à Nantes

Une application Flutter pour découvrir les événements, lieux et activités à Nantes.  
Elle utilise la géolocalisation, un calendrier interactif et des notifications locales.

---

## 🚀 Prérequis

Avant de lancer le projet, assure-toi d’avoir installé :

- **Flutter 3.32.0**
- **Dart 3.8.0**
- **Gradle 8.13**
- **Java JDK 17**
- **Android Studio** ou **VS Code** avec les extensions Flutter/Dart

## API

Une clé API https://openweathermap.org/api est nécessaire pour l'application

- API_WEATHER_KEY=ta_cle_api

- pubspec.yaml : 

flutter:
  assets:
    - .env

## Lancement de l'application

- flutter pub get
- flutter run

## Permissions déjà configurer dans AndroidManifest.xml

<!-- Localisation -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>

<!-- Alarmes et notifications -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Réseau -->
<uses-permission android:name="android.permission.INTERNET"/>
