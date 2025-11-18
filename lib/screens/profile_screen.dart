import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'), centerTitle: true),
      body: Column(
        children: [
          // profile picture
          CircleAvatar(),

          // name of user
          Text('Awais Tahir'),

          // blood type of user
          Text('Blood Type: O+'),

          // last donation date
          Text('Last Donation: 2023-11-15'),

          // edit profile button
          MyCustomButtom(
            backgroundColor: Colors.red.shade300,
            text: "Edit Profile",
          ),

          // donation history section
        ],
      ),
    );
  }
}
