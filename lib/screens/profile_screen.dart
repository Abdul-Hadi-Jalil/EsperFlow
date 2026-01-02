import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
          
              // profile picture
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.black26,
                child: CircleAvatar(
                  radius: 59,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 64),
                ),
              ),
          
              SizedBox(height: 14),
          
              // name of user
              Text(
                'Awais Tahir',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
          
              SizedBox(height: 2),
          
              // blood type of user
              Text(
                'Blood Type: O+',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
          
              SizedBox(height: 2),
          
              // last donation date
              Text(
                'Last Donation: 2023-11-15',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
          
              SizedBox(height: 18),
          
              // edit profile button
              InkWell(
                onTap: () {
                  debugPrint("yes");
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  padding: EdgeInsets.all(14),
                  margin: EdgeInsets.symmetric(horizontal: 0), // Reduced margin
                  child: Center(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          
              SizedBox(height: 42),
          
              // donation history section
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Donation History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
          
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
          
                  // history content
                  DonationHistoryTile(
                    title: "Whole Blood Donation",
                    subTitle: "2023-11-15",
                  ),
                  DonationHistoryTile(
                    title: "Whole Blood Donation",
                    subTitle: "2023-8-13",
                  ),
                ],
              ),
          
              SizedBox(height: 40),
          
              // sign out button
              InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
          
                  // Navigate back to the root (App widget)
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/', // This goes back to the App widget
                      (route) => false,
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  padding: EdgeInsets.all(14),
                  margin: EdgeInsets.symmetric(horizontal: 0), // Reduced margin
                  child: Center(
                    child: Text(
                      'Sign Out',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
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
          if (currentIndex == 0) {
            Navigator.pushNamed(context, '/homeScreen');
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

class DonationHistoryTile extends StatelessWidget {
  final String title;
  final String subTitle;
  const DonationHistoryTile({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-16, 0),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.bloodtype, size: 24),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subTitle, style: TextStyle(color: Colors.red)),
      ),
    );
  }
}
