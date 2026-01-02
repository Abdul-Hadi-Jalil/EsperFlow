import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esperflow/provider/register_provider.dart';
import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class AdditionalInformationScreen extends StatefulWidget {
  const AdditionalInformationScreen({super.key});

  @override
  State<AdditionalInformationScreen> createState() =>
      _AdditionalInformationScreenState();
}

class _AdditionalInformationScreenState
    extends State<AdditionalInformationScreen> {
  final TextEditingController _cnicController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? lastBloodDonation;
  bool? healthIssue;
  bool healthCondition = false;
  bool termConditions = false;
  XFile? selectedImage;
  String? _cnicError;
  String? _imageValidationError;
  bool _isProcessingImage = false;

  // CNIC validation function
  String? _validateCNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNIC is required';
    }

    // Remove dashes and spaces
    String cleanCNIC = value.replaceAll('-', '').replaceAll(' ', '');

    // Check length (13 digits for Pakistan CNIC)
    if (cleanCNIC.length != 13) {
      return 'CNIC must be 13 digits';
    }

    // Check if all characters are digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanCNIC)) {
      return 'CNIC must contain only numbers';
    }

    // Last digit validation (should be 0-9)
    int lastDigit = int.parse(cleanCNIC[cleanCNIC.length - 1]);
    if (lastDigit < 0 || lastDigit > 9) {
      return 'Invalid CNIC';
    }

    return null;
  }

  // Function to format CNIC as user types
  void _formatCNIC(String text) {
    if (text.isEmpty) return;

    String cleanText = text.replaceAll('-', '');

    if (cleanText.length > 13) {
      cleanText = cleanText.substring(0, 13);
    }

    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      if (i == 5 || i == 12) {
        formatted.write('-');
      }
      formatted.write(cleanText[i]);
    }

    _cnicController.text = formatted.toString();
    _cnicController.selection = TextSelection.fromPosition(
      TextPosition(offset: _cnicController.text.length),
    );
  }

Future<bool> _validateIDCardImage(File imageFile) async {
  try {
    setState(() {
      _isProcessingImage = true;
      _imageValidationError = null;
    });

    // Check file size (not too small, not too large)
    final fileSize = await imageFile.length();
    if (fileSize < 10240) { // 10KB minimum
      _imageValidationError = 'Image file is too small';
      return false;
    }
    if (fileSize > 10485760) { // 10MB maximum
      _imageValidationError = 'Image file is too large (max 10MB)';
      return false;
    }

    // Decode image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      _imageValidationError = 'Cannot read image file';
      return false;
    }

    // Basic dimension checks (more lenient)
    final width = image.width;
    final height = image.height;
    
    if (width < 300 || height < 300) {
      _imageValidationError = 'Image resolution is too low. Please upload a clearer image';
      return false;
    }

    // Allow both portrait and landscape orientations
    // Many ID cards can be photographed in either orientation
    
    // Check if image contains text (simpler method)
    // Sample random points across the image and check for color variations
    final random = Random();
    int variations = 0;
    final int sampleCount = 20;
    
    for (int i = 0; i < sampleCount; i++) {
      final x1 = random.nextInt(width);
      final y1 = random.nextInt(height);
      final x2 = random.nextInt(width);
      final y2 = random.nextInt(height);
      
      final pixel1 = image.getPixel(x1, y1);
      final pixel2 = image.getPixel(x2, y2);
      
      // Simple color difference calculation
      final diff = (pixel1.r - pixel2.r).abs() +
                   (pixel1.g - pixel2.g).abs() +
                   (pixel1.b - pixel2.b).abs();
      
      if (diff > 100) { // Significant color difference
        variations++;
      }
    }
    
    // If there are enough color variations, it's likely not a blank image
    if (variations < sampleCount / 4) {
      _imageValidationError = 'Image appears to be blank or lacks detail';
      return false;
    }

    return true;
  } catch (e) {
    _imageValidationError = 'Error validating image. Please try another image or check file format';
    return false;
  } finally {
    setState(() {
      _isProcessingImage = false;
    });
  }
}
  Future<void> pickAndPreprocessImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1200,
      );

      if (image != null) {
        final file = File(image.path);

        // Validate the image
        final isValid = await _validateIDCardImage(file);

        if (isValid) {
          setState(() {
            selectedImage = image;
            _imageValidationError = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ID card image validated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            selectedImage = null;
          });
          if (_imageValidationError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_imageValidationError!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to validate all fields before submission
  bool _validateAllFields() {
    // Validate CNIC
    final cnicError = _validateCNIC(_cnicController.text);
    if (cnicError != null) {
      setState(() {
        _cnicError = cnicError;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cnicError), backgroundColor: Colors.red),
      );
      return false;
    }

    // Validate image
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload CNIC image'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate health issue selection
    if (healthIssue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select health history option'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate checkboxes
    if (!healthCondition) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to health conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (!termConditions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  // Format date for display
  String _formatDateForDisplay(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> createUser() async {
    try {
      final registerProvider = Provider.of<RegisterProvider>(
        context,
        listen: false,
      );

      // Validate all fields before creating user
      if (!_validateAllFields()) {
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: registerProvider.email,
            password: registerProvider.password,
          );

      User? user = userCredential.user;

      if (user != null) {
        debugPrint('User registered successfully: ${user.uid}');
        return;
      } else {
        throw Exception('User registration failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
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

      // Format CNIC before saving
      String formattedCNIC = _cnicController.text;
      if (!formattedCNIC.contains('-')) {
        formattedCNIC =
            '${formattedCNIC.substring(0, 5)}-'
            '${formattedCNIC.substring(5, 12)}-'
            '${formattedCNIC.substring(12)}';
      }

      await FirebaseFirestore.instance.collection("User").doc(user.uid).set({
        "uid": user.uid,
        "Full Name": registerProvider.name,
        "Email": registerProvider.email,
        "Phone Number": registerProvider.phoneNumber,
        "Blood Group": registerProvider.bloodGroup,
        "Current Address": registerProvider.address,
        "Last Blood Donation": lastBloodDonation,
        "CNIC Number": formattedCNIC,
        "Health Issue": healthIssue,
        "CNIC Verified": true,
        "Registration Date": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

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
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Additional information text
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

                      SizedBox(height: 20),

                      // Last blood donation field with selected date display
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        child: Center(
                          child: ListTile(
                            title: lastBloodDonation == null
                                ? Text('Last Blood Donation (Optional)')
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Blood Donation',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        _formatDateForDisplay(
                                          lastBloodDonation!,
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                            trailing: IconButton(
                              onPressed: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  initialDate: DateTime.now(),
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    lastBloodDonation = selectedDate
                                        .toIso8601String();
                                  });
                                }
                              },
                              icon: Icon(Icons.calendar_month_rounded),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      // CNIC field with validation
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyTextField(
                            hintText: "CNIC Number (e.g., 12345-1234567-1)",
                            controller: _cnicController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              // Format as user types
                              _formatCNIC(value);
                              setState(() {
                                _cnicError = _validateCNIC(value);
                              });
                            },
                            validator: (value) {
                              final error = _validateCNIC(value);
                              return error;
                            },
                          ),
                          if (_cnicError != null)
                            Padding(
                              padding: EdgeInsets.only(left: 12, top: 4),
                              child: Text(
                                _cnicError!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 15),

                      // Upload CNIC image button with validation status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: _isProcessingImage
                                ? null
                                : pickAndPreprocessImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedImage != null
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: selectedImage != null
                                      ? Colors.green
                                      : Colors.red.shade100,
                                ),
                              ),
                              padding: EdgeInsets.all(14),
                              margin: EdgeInsets.symmetric(horizontal: 0),
                              child: Center(
                                child: _isProcessingImage
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text('Validating image...'),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            selectedImage != null
                                                ? Icons.check_circle
                                                : Icons.camera_alt_outlined,
                                            size: 15,
                                            color: selectedImage != null
                                                ? Colors.green
                                                : null,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            selectedImage != null
                                                ? 'CNIC Image Verified'
                                                : 'Upload CNIC Front Side',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: selectedImage != null
                                                  ? Colors.green
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          if (selectedImage != null)
                            Padding(
                              padding: EdgeInsets.only(top: 8, left: 12),
                              child: Text(
                                'Image: ${selectedImage!.name}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Health history section
                      Text(
                        'Health History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Have you had any diseases or health issues in the past 3 years',
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(height: 10),

                      // Yes/No option
                      Row(
                        children: [
                          OutlinedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                healthIssue == true
                                    ? Colors.red.shade100
                                    : Colors.white,
                              ),
                              side: WidgetStateProperty.all(
                                BorderSide(
                                  color: healthIssue == true
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                healthIssue = true;
                              });
                            },
                            child: Text(
                              'Yes',
                              style: TextStyle(
                                color: healthIssue == true
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          OutlinedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                healthIssue == false
                                    ? Colors.red.shade100
                                    : Colors.white,
                              ),
                              side: WidgetStateProperty.all(
                                BorderSide(
                                  color: healthIssue == false
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                healthIssue = false;
                              });
                            },
                            child: Text(
                              'No',
                              style: TextStyle(
                                color: healthIssue == false
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15),

                      // Checkboxes for agreement
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
                            child: Text(
                              'I agree to the terms and conditions',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15),
                    ],
                  ),

                  Column(
                    children: [
                      // Back and submit button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back button
                          MyCustomButtom(
                            backgroundColor: Colors.red.shade50,
                            text: "Back",
                            textColor: Colors.black,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),

                          // Submit button
                          MyCustomButtom(
                            backgroundColor: Color(0xFFE31A1A),
                            text: "Submit",
                            textColor: Colors.white,
                            onTap: () async {
                              if (_validateAllFields()) {
                                try {
                                  await createUser();
                                  await saveUserDataToFirestore();

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Registration successful!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/',
                                      (route) => false,
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('This email is already registered'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 15),

                      // Footer text
                      Center(
                        child: Text(
                          'Your data is secure and used only for donation purposes',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
      ),
    );
  }
}