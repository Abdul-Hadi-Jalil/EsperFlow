import 'package:esperflow/widgets/menu_item_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                // circle avatar
                CircleAvatar(),

                // logo
                // TODO: put the logo , or image of esperflow

                // notification bell icon
                IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
              ],
            ),

            // grid view of menu items for user
            Padding(
              padding: EdgeInsetsGeometry.all(20),
              child: GridView.count(
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2,
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  MenuItemCard(
                    iconData: Icons.bloodtype_outlined,
                    text: "Request Blood",
                  ),
                  MenuItemCard(
                    iconData: Icons.heart_broken_outlined,
                    text: "Organ Donor",
                  ),
                  MenuItemCard(
                    iconData: Icons.medical_services_rounded,
                    text: "Verified Hospitals",
                  ),
                  MenuItemCard(
                    iconData: Icons.corporate_fare_outlined,
                    text: "Blood Banks",
                  ),
                  MenuItemCard(
                    iconData: Icons.history,
                    text: "Donation History",
                  ),
                  MenuItemCard(
                    iconData: Icons.question_answer_outlined,
                    text: "FAQs",
                  ),
                  MenuItemCard(
                    iconData: Icons.phone_outlined,
                    text: "Emergency Contact",
                  ),
                  MenuItemCard(
                    iconData: Icons.question_answer_outlined,
                    text: "About Us",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
