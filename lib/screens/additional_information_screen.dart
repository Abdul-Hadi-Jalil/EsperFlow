import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> pickAndPreprocessImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {}
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
                          title: Text('Last Blood Donation'),
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
                        OutlinedButton(onPressed: () {}, child: Text('Yes')),
                        SizedBox(width: 10), // Added proper spacing
                        OutlinedButton(onPressed: () {}, child: Text('No')),
                      ],
                    ),

                    SizedBox(height: 15), // Reduced from 20
                    // check boxes for agreement
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: null),
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
                        Checkbox(value: false, onChanged: null),
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
                          onTap: () {
                            Navigator.pushNamed(context, '/loginScreen');
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
