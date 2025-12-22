import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esperflow/provider/register_provider.dart';
import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AdditionalInformationScreen extends StatefulWidget {
  const AdditionalInformationScreen({super.key});

  @override
  State<AdditionalInformationScreen> createState() =>
      _AdditionalInformationScreenState();
}

class _AdditionalInformationScreenState
    extends State<AdditionalInformationScreen> {
  final TextEditingController _cnicController = TextEditingController();

  String? lastBloodDonation;
  bool? healthIssue;

  bool healthCondition = false;
  bool termConditions = false;

  XFile? selectedImage;

  Future<void> pickAndPreprocessImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage = image;
    }
  }

  // function to create and register user
  Future<void> createUser() async {
    try {
      final registerProvider = Provider.of<RegisterProvider>(
        context,
        listen: false,
      );

      // Create user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: registerProvider.email,
            password: registerProvider.password,
          );

      // Get the created user
      User? user = userCredential.user;

      if (user != null) {
        // User registered successfully
        debugPrint('User registered successfully: ${user.uid}');
        return; // Success
      } else {
        throw Exception('User registration failed');
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow; // Re-throw to handle in UI
    }
  }

  Future<void> saveUserDataToFirestore() async {
    try {
      final registerProvider = Provider.of<RegisterProvider>(
        context,
        listen: false,
      );
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Use user.uid as document ID instead of add()
      await FirebaseFirestore.instance.collection("User").doc(user.uid).set({
        "uid": user.uid,
        "Full Name": registerProvider.name,
        "Email": registerProvider.email,
        "Phone Number": registerProvider.phoneNumber,
        "Blood Group": registerProvider.bloodGroup,
        "Current Address": registerProvider.address,
        "Last Blood Donation": lastBloodDonation,
        "CNIC Number": _cnicController.text,
        "Health Issue": healthIssue,
      });

      debugPrint('User data saved to Firestore successfully');
    } catch (e) {
      debugPrint('Firestore save error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // addition information text
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 20), // Reduced from 30
                    // last blood donation field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 0,
                      ), // Reduced margin
                      child: Center(
                        child: ListTile(
                          title: Text('Last Blood Donation (Optional)'),
                          trailing: IconButton(
                            onPressed: () {
                              showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2030),
                              );
                            },
                            icon: Icon(Icons.calendar_month_rounded),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 15), // Reduced from 20
                    // CNIC field
                    MyTextField(
                      hintText: "CNIC Number",
                      controller: _cnicController,
                    ),

                    SizedBox(height: 15), // Reduced from 20
                    // upload cnic image button
                    InkWell(
                      onTap: pickAndPreprocessImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: EdgeInsets.all(14),
                        margin: EdgeInsets.symmetric(
                          horizontal: 0,
                        ), // Reduced margin
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Removed 'spacing' parameter
                              Icon(Icons.camera_alt_outlined, size: 15),
                              SizedBox(width: 8), // Added proper spacing
                              Text(
                                'Upload CNIC Frontend Side',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20), // Reduced from 32
                    // health history
                    Text(
                      'Health History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ), // Reduced font size
                    ),

                    SizedBox(height: 10), // Reduced from 14

                    Text(
                      'Have you had any diseases or health issues in the past 3 years',
                      style: TextStyle(fontSize: 14), // Added font size
                    ),

                    SizedBox(height: 10),

                    // yes/no option
                    Row(
                      children: [
                        OutlinedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              healthIssue == true
                                  ? Colors.red.shade100
                                  : Colors.white,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              healthIssue = true;
                            });
                          },
                          child: Text('Yes'),
                        ),
                        SizedBox(width: 10), // Added proper spacing
                        OutlinedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              healthIssue == false
                                  ? Colors.red.shade100
                                  : Colors.white,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              healthIssue = false;
                            });
                          },
                          child: Text('No'),
                        ),
                      ],
                    ),

                    SizedBox(height: 15), // Reduced from 20
                    // check boxes for agreement
                    Row(
                      children: [
                        Checkbox(
                          value: healthCondition,
                          onChanged: (newValue) {
                            setState(() {
                              healthCondition = newValue!;
                            });
                          },
                        ),
                        Expanded(
                          // Added Expanded to prevent text overflow
                          child: Text(
                            'I agree to the health conditions',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: termConditions,
                          onChanged: (newValue) {
                            setState(() {
                              termConditions = newValue!;
                            });
                          },
                        ),
                        Expanded(
                          // Added Expanded to prevent text overflow
                          child: Text(
                            'I agree to the terms and conditions',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15), // Reduced from 20
                  ],
                ),

                Column(
                  children: [
                    // back and submit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // back button
                        MyCustomButtom(
                          backgroundColor: Colors.red.shade50,
                          text: "Back",
                          textColor: Colors.black,
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),

                        // submit button
                        MyCustomButtom(
                          backgroundColor: Color(0xFFE31A1A),
                          text: "Submit",
                          textColor: Colors.white,
                          onTap: () async {
                            await createUser();

                            await saveUserDataToFirestore();

                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    // footer text
                    Center(
                      child: Text(
                        'Your data is secure and used only for donation purposes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ), // Reduced font size
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
