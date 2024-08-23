import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:new_iot_project/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBlJrjrqQg1nUXS1fA-oyy5hYJifiXLb90",
          appId: "1:568224775936:android:8db3e17b042d94ce0e3de5",
          messagingSenderId: "568224775936",
          projectId: "iot-weather-app-ea0fb"));
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SensorDataScreen(),
    );
  }
}
