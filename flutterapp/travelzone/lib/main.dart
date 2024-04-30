import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:travelzone/firebase_options.dart';

import 'package:travelzone/screens/home_screen.dart'; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);




  runApp(const MainApp());
}

// ... остальной код приложения
class MainApp extends StatelessWidget {
  const MainApp({super.key});

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(), // Указываем HomeScreen в качестве главной страницы
    );
  }
}
