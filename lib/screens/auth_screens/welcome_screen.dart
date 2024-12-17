import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ping_me/screens/homepages/chat_ui/homescreen/homescreen.dart';
import 'package:ping_me/utils/components/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 20),
            // Logo and tagline
            Column(
              children: [
                // App image
                Image.asset(
                  'lib/assets/logo/privacy.png', // Replace with your image path
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 20),
                // Tagline
                Text(
                  "Your Privacy, Our Priority",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "We ensure your data stays secure and private while you connect with friends and loved ones.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            // Continue button
            Column(
              children: [
                ModernButton(
                  text: "Continue",
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Homescreen())); // Navigate to Home Screen
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
