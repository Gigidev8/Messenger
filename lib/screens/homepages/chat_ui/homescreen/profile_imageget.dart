import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileImageWidget extends StatefulWidget {
  const ProfileImageWidget({Key? key}) : super(key: key);

  @override
  _ProfileImageWidgetState createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  String? _profileImageUrl; // This will hold the Base64 profile image

  // Fetch current user's profile image from Firestore
  Future<void> _getUserProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!.toLowerCase();
        // Fetch user data from Firestore using email as the document ID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .get();

        if (userDoc.exists) {
          setState(() {
            _profileImageUrl = userDoc['profileImage']; // Get the Base64 string
          });
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  // Decode the Base64 string to an Image widget
  Image _decodeBase64ToImage(String base64String) {
    // Convert the Base64 string to bytes
    final decodedBytes = base64Decode(base64String);
    return Image.memory(decodedBytes);
  }

  @override
  void initState() {
    super.initState();
    _getUserProfile(); // Fetch the profile when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _profileImageUrl == null
        ? Icon(Icons.person, color: theme.colorScheme.tertiary)
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: _profileImageUrl == null
                  ? null
                  : _decodeBase64ToImage(_profileImageUrl!).image,
            ),
          );
  }
}
