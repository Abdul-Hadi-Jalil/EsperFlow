import 'package:esperflow/app.dart';
import 'package:esperflow/firebase_options.dart';
import 'package:esperflow/provider/register_provider.dart';
import 'package:esperflow/screens/about_us_screen.dart';
import 'package:esperflow/screens/additional_information_screen.dart';
import 'package:esperflow/screens/blood_request_screen.dart';
import 'package:esperflow/screens/emergency_contact_screen.dart';
import 'package:esperflow/screens/faq_screen.dart';
import 'package:esperflow/screens/home_screen.dart';
import 'package:esperflow/screens/login_screen.dart';
import 'package:esperflow/screens/profile_screen.dart';
import 'package:esperflow/screens/register_screen.dart';
import 'package:esperflow/screens/verified_hospital_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EsperFlow());
}

class EsperFlow extends StatelessWidget {
  const EsperFlow({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RegisterProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.red)),
        home: App(),
        routes: {
  '/homeScreen': (context) => HomeScreen(),
  '/loginScreen': (context) => LoginScreen(),
  '/registerScreen': (context) => RegisterScreen(),
  '/additionalInformationScreen': (context) => AdditionalInformationScreen(),
  '/bloodRequestScreen': (context) => BloodRequestScreen(),
  '/faqScreen': (context) => FaqScreen(),
  '/profileScreen': (context) => ProfileScreen(),
  '/emergencyContactScreen': (context) => EmergencyContactScreen(),
  '/aboutUsScreen': (context) => AboutUsScreen(), 
  '/verifiedHospitalsScreen': (context) => VerifiedHospitalsScreen(),
},
      ),
    );
  }
}
