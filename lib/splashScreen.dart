import 'package:flutter/material.dart';
import 'dart:async';
import 'package:musicdownloaders/screens/app.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Set a timer for 2 seconds to navigate to the main app
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/splash_screen.png',  // Correct path without extra spaces
          width: 200.0,  // Adjust the width and height as needed
          height: 200.0,
        ),
      ),
      backgroundColor: Colors.black,  // Optional: set background color to black for contrast
    );
  }
}
