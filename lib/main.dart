import 'package:esperflow/screens/additional_information_screen.dart';
import 'package:esperflow/screens/blood_request_screen.dart';
import 'package:esperflow/screens/faq_screen.dart';
import 'package:esperflow/screens/home_screen.dart';
import 'package:esperflow/screens/login_screen.dart';
import 'package:esperflow/screens/profile_screen.dart';
import 'package:esperflow/screens/register_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.red)),
      home: AdditionalInformationScreen(),
    );
  }
}
