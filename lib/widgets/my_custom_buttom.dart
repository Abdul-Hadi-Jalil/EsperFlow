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
      color: backgroundColor,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Text(
          text,
          style: textColor != null ? TextStyle(color: textColor) : null,
        ),
      ),
    );
  }
}
