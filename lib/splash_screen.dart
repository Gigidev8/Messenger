import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import your login screen
import 'package:ping_me/screens/auth_screens/loginpage.dart';
import 'package:ping_me/screens/homepages/chat_ui/homescreen/homescreen.dart';  // Import your home screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // Timer to navigate after a delay
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();  // Check login status as soon as the splash screen is initialized
  }

  // Function to check the login status
  Future<void> _checkLoginStatus() async {
    // Get the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    // Navigate after 3 seconds based on the login status
    Timer(const Duration(seconds: 3), () {
      if (user != null) {
        // User is logged in, navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homescreen()),
        );
      } else {
        // User is not logged in, navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,  // Set background color based on the theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            Image.asset(
              'lib/assets/logo/ping.png', 
              width: 200,  // Adjust size of your logo
              height: 200,
            ),
            const SizedBox(height: 20),
            // You can add a text here, like your app's name, below the logo
            Text(
              'Ping Me',  // Change this to your app name
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,  // Ensure the text color works in both modes
              ),
            ),
          ],
        ),
      ),
    );
  }
}
