import 'package:flutter/material.dart';
import 'package:musicdownloaders/screens/app.dart';
import 'package:musicdownloaders/splashScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'Spotify Clone',
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}
