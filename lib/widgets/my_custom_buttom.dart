// used in login and register screens

import 'package:flutter/material.dart';

class MyCustomButtom extends StatelessWidget {
  const MyCustomButtom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Text('Login', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
