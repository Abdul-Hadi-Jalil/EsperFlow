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

  // Store the selected blood group before clearing for dialog display
  String? _submittedBloodGroup;

  Future<void> saveBloodRequestData() async {
    setState(() {
      _isSubmitting = true;
    });

    // Store the blood group before clearing
    _submittedBloodGroup = selectedBloodGroup;

    try {
      // Save to Firestore using "Blood Request" collection (with space)
      await FirebaseFirestore.instance.collection('Blood Request').add({
        "fullName": _fullNameController.text,
        "phoneNumber": _phoneNumberController.text,
        "bloodGroup": selectedBloodGroup,
        "requiredQuantity": selectedQuantity,
        "location": _locationController.text,
        "hospitalName": _hospitalNameController.text,
        "additionalNotes": _additionalController.text,
        "timestamp": FieldValue.serverTimestamp(),
        "status": "Pending",
        "requestDate": DateTime.now().toIso8601String(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Blood request submitted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Find matching donors from Firebase
      List<Map<String, dynamic>> matchingDonors = await findMatchingDonors();

      // Show matching donors
      if (matchingDonors.isNotEmpty) {
        _showAvailableDonors(matchingDonors);
      } else {
        _showNoDonorsDialog();
      }

    } catch (e) {
      print('Error saving blood request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit request: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> findMatchingDonors() async {
    try {
      // Query Firebase for users with matching blood group
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('Blood Group', isEqualTo: selectedBloodGroup)
          .get();

      List<Map<String, dynamic>> matchingDonors = [];
      DateTime threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));

      // Filter donors based on last donation date
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        
        // Check if user has donated before
        if (data["Last Blood Donation"] != null) {
          // Convert Firestore Timestamp to DateTime
          DateTime lastDonation = (data["Last Blood Donation"] as Timestamp).toDate();
          
          // Only include if last donation was more than 3 months ago
          if (lastDonation.isBefore(threeMonthsAgo)) {
            matchingDonors.add({
              ...data,
              'id': doc.id, // Include document ID for reference
            });
          }
        } else {
          // Never donated before, eligible to donate
          matchingDonors.add({
            ...data,
            'id': doc.id,
          });
        }
      }

      print('Found ${matchingDonors.length} matching donors for $selectedBloodGroup');
      return matchingDonors;
    } catch (e) {
      print('Error finding donors: $e');
      return [];
    }
  }

  void _showAvailableDonors(List<Map<String, dynamic>> donors) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Donors',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${donors.length} donor${donors.length > 1 ? 's' : ''} found with $_submittedBloodGroup',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Donors list
              Flexible(
                child: donors.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'No donors available',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(15),
                        itemCount: donors.length,
                        itemBuilder: (context, index) {
                          final donor = donors[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.red.shade100,
                                        child: Text(
                                          donor["Full Name"] != null && 
                                          donor["Full Name"].isNotEmpty 
                                              ? donor["Full Name"][0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              donor["Full Name"] ?? 'Unknown',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade700,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                donor["Blood Group"] ?? 'N/A',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.phone, 
                                    donor["Phone Number"] ?? 'Not provided'
                                  ),
                                  const SizedBox(height: 6),
                                  _buildInfoRow(
                                    Icons.location_on, 
                                    donor["Current Address"] ?? 'Address not available'
                                  ),
                                  const SizedBox(height: 6),
                                  _buildInfoRow(
                                    Icons.calendar_today,
                                    'Last Donation: ${_formatLastDonation(donor["Last Blood Donation"])}',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _clearForm(); // Clear form after closing dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastDonation(dynamic lastDonation) {
    if (lastDonation == null) return "Never";
    
    try {
      DateTime date = (lastDonation as Timestamp).toDate();
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "N/A";
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  void _showNoDonorsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 10),
            const Text('No Donors Available'),
          ],
        ),
        content: Text(
          'Currently, there are no available donors with $_submittedBloodGroup blood group. '
          'Your request has been submitted and will be visible to all users.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm(); // Clear form after closing dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
      _submittedBloodGroup = null;
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
        duration: const Duration(seconds: 2),
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