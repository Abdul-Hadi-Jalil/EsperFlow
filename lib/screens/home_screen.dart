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
      body: Container(
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
                    backgroundColor: Colors.grey.shade300,
                    // TODO: Add user profile image
                  ),

                  // logo
                  // TODO: put the logo , or image of esperflow
                  Container(
                    width: 100,
                    height: 30,
                    color: Colors.grey.shade200,
                    child: Center(child: Text('LOGO')), // Placeholder
                  ),

                  // notification bell icon
                  IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
                ],
              ),

              SizedBox(height: 20), // Added spacing
              // grid view of menu items for user
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.4, // Adjusted for better proportions
                  ),
                  itemCount: menuItems.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return MenuItemCard(
                      iconData: menuItems[index]['iconData'] as IconData,
                      text: menuItems[index]['text'] as String,
                    );
                  },
                ),
              ),

              // bottom image of home screen
              // TODO: an image of home screen
              Container(
                margin: EdgeInsets.only(top: 20),
                width: double.infinity,
                height: 100,
                color: Colors.grey.shade200,
                child: Center(child: Text('Home Screen Image')), // Placeholder
              ),
            ],
          ),
        ),
      ),
    );
  }
}
