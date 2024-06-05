// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 2), // Change the duration as needed
      () => Navigator.pushReplacementNamed(context, '/movie_screen'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // Assuming the logo is stored in assets folder
              width: 300,
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 20, // Adjust the width as needed
              height: 20, // Adjust the height as needed
              child: CircularProgressIndicator(
                strokeWidth: 1, // Adjust the stroke width as needed
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(
                    255, 255, 0, 140)), // Change the color as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
