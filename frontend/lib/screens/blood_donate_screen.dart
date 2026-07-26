import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class BloodDonateScreen extends StatefulWidget {
  const BloodDonateScreen({super.key});

  @override
  State<BloodDonateScreen> createState() => _BloodDonateScreenState();
}

class _BloodDonateScreenState extends State<BloodDonateScreen> {
  // controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();

  String? fullName = "";
  String? location = "";
  String? phoneNumber = "";
  String? availability = "";

  String? selectedBloodGroup;
  List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  bool allowCalls = true;
  bool activeDonorStatus = true;

  bool _isSubmitting = false;

  Future<void> saveBloodDonateData() async {
    setState(() {
      _isSubmitting = true;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _locationController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Donate Blood',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // info card
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Important',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your information will be visible to all users in the app. Please ensure all information is accurate.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              // full name field
              MyTextField(
                controller: _fullNameController,
                hintText: "Full Name",
              ),
              const SizedBox(height: 15),

              // Phone number field (optional)
              MyTextField(
                controller: _phoneNumberController,
                hintText: "Phone Number (Optional)",
              ),
              const SizedBox(height: 15),

              // drop down menu for blood group selection
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBloodGroup,
                    hint: Text(
                      "Select Your Blood Group",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    items: bloodGroups.map((group) {
                      return DropdownMenuItem(
                        value: group,
                        child: Row(
                          children: [
                            const Icon(Icons.bloodtype, size: 20),
                            const SizedBox(width: 10),
                            Text(group),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBloodGroup = value!;
                      });
                    },
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(9),
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // location field
              MyTextField(
                hintText: "Location (Optional)",
                controller: _locationController,
              ),
              const SizedBox(height: 15),

              MyTextField(
                hintText: "Availability Time (Optional)",
                controller: _availabilityController,
              ),

              const SizedBox(height: 25),

              Column(
                children: [
                  // Privacy and visibility text
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Privacy and Visisbility",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE31A1A),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Allow calls and Donor Status
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(
                      "Allow calls",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Users can call you"),
                    trailing: Switch(
                      activeThumbColor: Colors.white,
                      activeTrackColor: Color(0xFFE31A1A),
                      value: allowCalls,
                      onChanged: (value) {
                        setState(() {
                          allowCalls = value;
                        });
                      },
                    ),
                  ),

                  ListTile(
                    leading: Icon(Icons.remove_red_eye_outlined),
                    title: Text(
                      "Active Donor Status",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Active Donors appear in search"),
                    trailing: Switch(
                      activeThumbColor: Colors.white,
                      activeTrackColor: Color(0xFFE31A1A),
                      value: activeDonorStatus,
                      onChanged: (value) {
                        setState(() {
                          activeDonorStatus = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // submit button
              MyCustomButtom(
                onTap: () async {
                  fullName = _fullNameController.text.trim();
                  location = _locationController.text.trim();
                  phoneNumber = _phoneNumberController.text.trim();
                  availability = _availabilityController.text.trim();

                  // get the device id
                  String? deviceId;
                  deviceId = Uuid().v4(); // Generate unique ID

                  // create fcm token and save data to firebase
                  // Get FCM token
                  final FirebaseMessaging messaging =
                      FirebaseMessaging.instance;

                  NotificationSettings settings = await messaging
                      .requestPermission(alert: true, badge: true, sound: true);

                  String? fcmToken;
                  if (settings.authorizationStatus ==
                      AuthorizationStatus.authorized) {
                    fcmToken = await messaging.getToken();
                  }

                  // Save to Firebase with the token
                  await FirebaseFirestore.instance
                      .collection('donors')
                      .doc(deviceId)
                      .set({
                        'fullName': fullName,
                        'location': location,
                        'phoneNumber': phoneNumber,
                        'availability': availability,
                        'bloodGroup': selectedBloodGroup,
                        'allowCalls': allowCalls,
                        'activeDonorStatus': activeDonorStatus,
                        'fcmToken': fcmToken,
                        'registeredAt': FieldValue.serverTimestamp(),
                      });

                  // todo: Show success alert dialog
                },
                backgroundColor: const Color(0xFFE31A1A),
                text: _isSubmitting ? "Submitting..." : "Submit Donation",
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
