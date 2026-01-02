import 'package:esperflow/widgets/menu_item_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // used for bottom navigation
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // circle avatar
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/profileScreen');
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        radius: 19,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 24),
                      ),
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
                    onTap: () =>
                        Navigator.pushNamed(context, '/bloodRequestScreen'),
                  ),
                
                  MenuItemCard(
  iconData: Icons.medical_services_rounded,
  text: 'Verified Hospitals',
  onTap: () => Navigator.pushNamed(context, '/verifiedHospitalsScreen'),
),
                  MenuItemCard(
  iconData: Icons.corporate_fare_outlined,
  text: 'Blood Banks',
  onTap: () => Navigator.pushNamed(context, '/bloodBanksScreen'),
),
                  MenuItemCard(
                    iconData: Icons.history,
                    text: 'Donation History',
                  ),
                  MenuItemCard(
                    iconData: Icons.question_answer_outlined,
                    text: 'FAQs',
                    onTap: () => Navigator.pushNamed(context, '/faqScreen'),
                  ),
                  MenuItemCard(
  iconData: Icons.phone_outlined,
  text: 'Emergency Contact',
  onTap: () => Navigator.pushNamed(context, '/emergencyContactScreen'), // Add this line
),
                    MenuItemCard(
  iconData: Icons.info_outline,
  text: 'About Us',
  onTap: () => Navigator.pushNamed(context, '/aboutUsScreen'), // Add this line
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
          if (currentIndex == 1) {
            Navigator.pushNamed(context, '/profileScreen');
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black,
              child: CircleAvatar(
                radius: 19,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
