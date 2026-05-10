import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({super.key});

  @override
  State<BloodRequestScreen> createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  // controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String? selectedBloodGroup;
  List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  String? selectedUrgency = 'No'; // Default to "No"

  bool _isSubmitting = false;

  Future<void> saveBloodRequestData() async {
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
          'Request Blood',
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
                      'Your request will be visible to all users in the app. Please ensure all information is accurate.',
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
                      "Select Blood Group",
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
                hintText: "Location (City/Area/Hospital)",
                controller: _locationController,
              ),
              const SizedBox(height: 15),

              // Urgent or Not
              Row(
                spacing: 20,
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Urgent',
                        groupValue: selectedUrgency,
                        onChanged: (value) {
                          setState(() {
                            selectedUrgency = value;
                          });
                        },
                      ),
                      SizedBox(width: 4),
                      Text('Urgent'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Not Urgent',
                        groupValue: selectedUrgency,
                        onChanged: (value) {
                          setState(() {
                            selectedUrgency = value;
                          });
                        },
                      ),
                      SizedBox(width: 4),
                      Text('Not Urgent'),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // submit button
              MyCustomButtom(
                onTap: () {
                  // Alert dialog will appear to confirm the submission of the blood request
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: const Text(
                          "Your request will be visible to all users in the app.",
                        ),
                        actions: [
                          ElevatedButton(
                            child: const Text("Exit"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  saveBloodRequestData();
                },
                backgroundColor: const Color(0xFFE31A1A),
                text: _isSubmitting ? "Submitting..." : "Submit Request",
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
