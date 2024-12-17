import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_me/screens/auth_screens/loginpage.dart';

class SettingsBottomSheet {
  // Function to show the settings bottom sheet
  static void showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // To allow the content to be scrollable if needed
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)), // Rounded top corners
      ),
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title text
              Text(
                'Settings',
                style: TextStyle(
                  color: theme.colorScheme.tertiary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Button for Sign Out
              ElevatedButton.icon(
                onPressed: () async {
                  // Sign out the user
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  minimumSize: Size(double.infinity, 50), // Take full width
                ),
                icon: Icon(Icons.logout, color: theme.colorScheme.tertiary),
                label: Text(
                  'Sign Out',
                  style: TextStyle(color: theme.colorScheme.tertiary),
                ),
              ),
              const SizedBox(height: 15),

              // Button for Settings
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to the settings page (placeholder for now)
                  Navigator.pushNamed(context, '/settings');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  minimumSize: Size(double.infinity, 50), // Take full width
                ),
                icon: Icon(Icons.settings, color: theme.colorScheme.tertiary),
                label: Text(
                  'Settings',
                  style: TextStyle(color: theme.colorScheme.tertiary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
