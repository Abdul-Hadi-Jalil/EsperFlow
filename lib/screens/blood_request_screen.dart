import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esperflow/screens/blood_request_list_screen.dart';
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
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _additionalController = TextEditingController();

  String? selectedBloodGroup;
  List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  String? selectedQuantity;
  List<String> bloodQuantity = [
    '50ml',
    '100ml',
    '150ml',
    '200ml',
    '250ml',
    '300ml',
    '350ml',
    '400ml',
  ];

  bool _isSubmitting = false;

  Future<void> saveBloodRequestData() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Save to Firestore
      await FirebaseFirestore.instance.collection('BloodRequests').add({
        "fullName": _fullNameController.text,
        "phoneNumber": _phoneNumberController.text,
        "bloodGroup": selectedBloodGroup,
        "requiredQuantity": selectedQuantity,
        "location": _locationController.text,
        "hospitalName": _hospitalNameController.text,
        "additionalNotes": _additionalController.text,
        "timestamp": FieldValue.serverTimestamp(),
        "status": "Pending",
      });

      // Clear form after successful submission
      _clearForm();
      
      // Show simple success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Blood request submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('Error: $e');
      // Show simple error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit request. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _clearForm() {
    _fullNameController.clear();
    _phoneNumberController.clear();
    _locationController.clear();
    _hospitalNameController.clear();
    _additionalController.clear();
    setState(() {
      selectedBloodGroup = null;
      selectedQuantity = null;
    });
  }

  bool _validateForm() {
    if (_fullNameController.text.isEmpty) {
      _showValidationError('Please enter your full name');
      return false;
    }
    if (_phoneNumberController.text.isEmpty) {
      _showValidationError('Please enter your phone number');
      return false;
    }
    if (selectedBloodGroup == null) {
      _showValidationError('Please select a blood group');
      return false;
    }
    if (selectedQuantity == null) {
      _showValidationError('Please select required blood quantity');
      return false;
    }
    if (_locationController.text.isEmpty) {
      _showValidationError('Please enter location');
      return false;
    }
    if (_hospitalNameController.text.isEmpty) {
      _showValidationError('Please enter hospital name');
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _locationController.dispose();
    _phoneNumberController.dispose();
    _hospitalNameController.dispose();
    _additionalController.dispose();
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BloodRequestsListScreen(),
                ),
              );
            },
            icon: const Icon(Icons.list),
            tooltip: 'View Requests',
          ),
        ],
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

              // phone number field
              MyTextField(
                controller: _phoneNumberController,
                hintText: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),

              // drop down menu for blood group selection
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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

              // drop down menu for required blood quantity
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedQuantity,
                    hint: Text(
                      "Required Blood Quantity",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    items: bloodQuantity.map((quantity) {
                      return DropdownMenuItem(
                        value: quantity,
                        child: Row(
                          children: [
                            const Icon(Icons.bloodtype, size: 20),
                            const SizedBox(width: 10),
                            Text(quantity),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedQuantity = value!;
                      });
                    },
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(9),
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),

              // note for donor
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 10),
                child: Text(
                  'Each donor can safely donate up to 400ml',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // location field
              MyTextField(
                hintText: "Location (City/Area)",
                controller: _locationController,
              ),
              const SizedBox(height: 15),

              // hospital or cnic field
              MyTextField(
                hintText: "Hospital Name",
                controller: _hospitalNameController,
              ),
              const SizedBox(height: 15),

              // additional notes
              MyTextField(
                hintText: "Additional Notes (Optional)",
                controller: _additionalController,
              ),
              const SizedBox(height: 25),

              // submit button
              MyCustomButtom(
                onTap: () {
                  if (_validateForm()) {
                    saveBloodRequestData();
                  }
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