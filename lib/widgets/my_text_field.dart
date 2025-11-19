// used in login and register screens

import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obsecureFlag;
  final IconData? suffixIcon;
  const MyTextField({
    super.key,
    required this.hintText,
    this.obsecureFlag = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Colors.red.shade50,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(style: BorderStyle.none, width: 0),
        ),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      ),
      obscureText: obsecureFlag,
    );
  }
}
