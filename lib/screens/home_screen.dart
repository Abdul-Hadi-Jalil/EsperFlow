import 'package:esperflow/widgets/menu_item_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of menu items
  final List<Map<String, dynamic>> menuItems = [
    {'iconData': Icons.bloodtype_outlined, 'text': "Request Blood"},
    {'iconData': Icons.heart_broken_outlined, 'text': "Organ Donor"},
    {'iconData': Icons.medical_services_rounded, 'text': "Verified Hospitals"},
    {'iconData': Icons.corporate_fare_outlined, 'text': "Blood Banks"},
    {'iconData': Icons.history, 'text': "Donation History"},
    {'iconData': Icons.question_answer_outlined, 'text': "FAQs"},
    {'iconData': Icons.phone_outlined, 'text': "Emergency Contact"},
    {'iconData': Icons.question_answer_outlined, 'text': "About Us"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // circle avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        radius: 19,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 24),
                      ),
                    ),

                    // logo
                    Image.asset(
                      'assets/images/esperflow_logo.png',
                      height: 150,
                      width: 150,
                    ),

                    // notification bell icon
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.notifications, size: 24),
                    ),
                  ],
                ),

                // grid view of menu items for user
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    MenuItemCard(
                      iconData: Icons.bloodtype_outlined,
                      text: 'Request Blood',
                    ),
                    MenuItemCard(
                      iconData: Icons.heart_broken_outlined,
                      text: 'Organ Donor',
                    ),
                    MenuItemCard(
                      iconData: Icons.medical_services_rounded,
                      text: 'Verified Hospitals',
                    ),
                    MenuItemCard(
                      iconData: Icons.corporate_fare_outlined,
                      text: 'Blood Banks',
                    ),
                    MenuItemCard(
                      iconData: Icons.history,
                      text: 'Donation History',
                    ),
                    MenuItemCard(
                      iconData: Icons.question_answer_outlined,
                      text: 'FAQs',
                    ),
                    MenuItemCard(
                      iconData: Icons.phone_outlined,
                      text: 'Emergency Contact',
                    ),
                    MenuItemCard(
                      iconData: Icons.info_outline,
                      text: 'About Us',
                    ),
                  ],
                ),

                SizedBox(height: 40),

                // bottom image of home screen
                Image.asset('assets/images/home_screen_footer.png'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
