import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:ping_me/screens/auth_screens/welcome_screen.dart';
import 'package:ping_me/utils/components/custom_button.dart';
import 'package:ping_me/utils/components/textfeild.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _profileImage; // Stores the actual image file

  // Function to pick the profile image
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Function to create a user and save Base64 image in Firestore
 Future<void> _createUser() async {
  try {
    // Register the user with email and password
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // Convert the profile image to Base64 if it exists
    String? base64Image;
    if (_profileImage != null) {
      img.Image image = img.decodeImage(_profileImage!.readAsBytesSync())!;
      base64Image = base64Encode(img.encodeJpg(image));
    }

    // Use the user's email as the document ID in Firestore
    String emailID = _emailController.text.trim().toLowerCase();

    // Save user information in Firestore
    await FirebaseFirestore.instance.collection('users').doc(emailID).set({
      'name': _nameController.text,
      'email': _emailController.text,
      'profileImage': base64Image, // Storing the Base64 string
    });

    // Navigate to the Welcome Screen after success
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomeScreen(),
      ),
    );
  } catch (e) {
    // Handle errors
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create Account",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Theme.of(context).colorScheme.tertiary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 25),
                CustomTextField(
                  hintText: "Name",
                  obsecuretext: false,
                  textcontroller: _nameController,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  hintText: "Email",
                  obsecuretext: false,
                  textcontroller: _emailController,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  hintText: "Password",
                  obsecuretext: true,
                  textcontroller: _passwordController,
                ),
                const SizedBox(height: 25),
                ModernButton(
                  text: "Create Account",
                  onPressed: _createUser,
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to login
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
