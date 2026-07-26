import 'package:esperflow/models/blood_request.dart';
import 'package:esperflow/services/blood_request_service.dart';
import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:esperflow/widgets/request_sent_dialog.dart';
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

  String? selectedUrgency = 'Not Urgent';

  bool _isSubmitting = false;

  /// Save to Firestore, then let the backend push the request to every
  /// registered user and tell us how many were reached.
  Future<void> saveBloodRequestData() async {
    if (_isSubmitting) return;

    final validationError = _validate();
    if (validationError != null) {
      _showSnackBar(validationError);
      return;
    }

    setState(() => _isSubmitting = true);

    final request = BloodRequest(
      fullName: _fullNameController.text.trim(),
      bloodGroup: selectedBloodGroup!,
      location: _locationController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      urgency: selectedUrgency ?? 'Not Urgent',
    );

    try {
      final result = await BloodRequestService.submit(request);
      if (!mounted) return;

      _clearForm();
      await showDialog(
        context: context,
        builder: (_) => RequestSentDialog(result: result),
      );
    } on BloodRequestException catch (e) {
      if (!mounted) return;
      await _showFailureDialog(e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _validate() {
    if (_fullNameController.text.trim().length < 2) {
      return 'Please enter your full name.';
    }
    if (selectedBloodGroup == null) {
      return 'Please select the blood group you need.';
    }
    if (_locationController.text.trim().length < 2) {
      return 'Please enter a location (city, area or hospital).';
    }
    final phone = _phoneNumberController.text.trim();
    if (phone.isNotEmpty && phone.replaceAll(RegExp(r'[^0-9]'), '').length < 7) {
      return 'Please enter a valid phone number, or leave it empty.';
    }
    return null;
  }

  void _clearForm() {
    _fullNameController.clear();
    _locationController.clear();
    _phoneNumberController.clear();
    setState(() {
      selectedBloodGroup = null;
      selectedUrgency = 'Not Urgent';
    });
  }

  /// Confirms before broadcasting — the request goes to every registered user.
  Future<bool> _confirmSubmission() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Send this request?'),
        content: const Text(
          'Your request will be sent as a notification to all users registered '
          'in the app, and your details will be visible to them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31A1A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _showFailureDialog(BloodRequestException error) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.orange, size: 36),
        title: Text(
          error.savedToFirebase ? 'Saved, but not sent' : 'Request failed',
          textAlign: TextAlign.center,
        ),
        content: Text(error.message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          if (error.requestId != null)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _retryBroadcast(error.requestId!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31A1A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Try again'),
            ),
        ],
      ),
    );
  }

  /// The request is already in Firestore — only the notification needs a retry.
  Future<void> _retryBroadcast(String requestId) async {
    setState(() => _isSubmitting = true);
    try {
      final result = await BloodRequestService.resend(requestId);
      if (!mounted) return;
      _clearForm();
      await showDialog(
        context: context,
        builder: (_) => RequestSentDialog(result: result),
      );
    } on BloodRequestException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Still could not notify donors. Please try again later.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                keyboardType: TextInputType.phone,
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
                onTap: _isSubmitting
                    ? null
                    : () async {
                        if (await _confirmSubmission()) {
                          await saveBloodRequestData();
                        }
                      },
                backgroundColor: _isSubmitting
                    ? Colors.grey
                    : const Color(0xFFE31A1A),
                text: _isSubmitting ? "Sending to donors..." : "Submit Request",
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
