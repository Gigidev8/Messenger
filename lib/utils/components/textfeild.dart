import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obsecuretext;
  final TextEditingController textcontroller;

  const CustomTextField(
      {super.key,
      required this.hintText,
      required this.obsecuretext,
      required this.textcontroller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: TextField(
        obscureText: obsecuretext,
        controller: textcontroller,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                GoogleFonts.poppins(fontSize: 16), // Correct variable name
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.tertiary),
            ),
            fillColor: Theme.of(context).colorScheme.primary,
            filled: true

            // Enables the fillColor
            ),
      ),
    );
  }
}
