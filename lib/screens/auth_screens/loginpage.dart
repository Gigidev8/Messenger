import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ping_me/screens/auth_screens/create_account_screen.dart';
import 'package:ping_me/screens/auth_screens/forgot_pass_screen.dart';
import 'package:ping_me/screens/homepages/chat_ui/homescreen/homescreen.dart';
import 'package:ping_me/utils/components/custom_button.dart';
import 'package:ping_me/utils/components/textfeild.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle login with Firebase Auth
  Future<void> _login() async {
    try {
      // Attempt to sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // If login is successful, navigate to the Home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homescreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase errors (e.g., wrong credentials, account not found)
      String errorMessage = e.message ?? 'An error occurred. Please try again later.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
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
                // App Logo
                Image.asset(
                  "lib/assets/logo/ping.png",
                  height: 80.0,
                ),
                const SizedBox(height: 25),
                // Welcome Text
                Text(
                  "Welcome Back",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 45),
                // Email Input Field
                CustomTextField(
                  hintText: "Email",
                  obsecuretext: false,
                  textcontroller: _emailController,
                ),
                const SizedBox(height: 15),
                // Password Input Field
                CustomTextField(
                  hintText: "Password",
                  obsecuretext: true,
                  textcontroller: _passwordController,
                ),
                const SizedBox(height: 15),
                // Forgot Password Button
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: () {
                        // Navigate to Forgot Password screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Login Button
                ModernButton(
                  text: "Login",
                  onPressed: _login,
                ),
                const SizedBox(height: 20),
                // Create New Account Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateAccountPage(),
                      ),
                    );
                  },
                  child: Text(
                    "Create New Account",
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
