// used in login and register screens

import 'package:flutter/material.dart';

class MyCustomButtom extends StatelessWidget {
  final Color backgroundColor;
  final String text;
  final Color? textColor;
  const MyCustomButtom({
    super.key,
    required this.backgroundColor,
    required this.text,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9),
      ),
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
