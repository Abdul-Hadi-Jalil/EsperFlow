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

      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize < 10240) {
        // 10KB minimum
        _imageValidationError = 'Image file is too small. Please upload a clearer photo';
        return false;
      }
      if (fileSize > 10485760) {
        // 10MB maximum
        _imageValidationError = 'Image file is too large (max 10MB)';
        return false;
      }

      // Decode image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        _imageValidationError = 'Cannot read image file. Please try another photo';
        return false;
      }

      // Get dimensions
      final width = image.width;
      final height = image.height;

      // Check minimum resolution (not too strict)
      if (width < 400 || height < 250) {
        _imageValidationError =
            'Image resolution is too low. Please upload a clearer photo';
        return false;
      }

      // Check aspect ratio - ID cards are typically rectangular
      // Pakistan CNIC is roughly 3:2 ratio (landscape) or 2:3 (portrait)
      final aspectRatio = width / height;
      
      // Allow flexible aspect ratio (between 0.5 and 2.5)
      // This covers both portrait and landscape orientations
      if (aspectRatio < 0.5 || aspectRatio > 2.5) {
        _imageValidationError =
            'Image doesn\'t appear to be a card. Please ensure the full card is visible';
        return false;
      }

      // Check if image is not too square (likely not a card)
      if (aspectRatio > 0.9 && aspectRatio < 1.1) {
        _imageValidationError =
            'Image appears to be square. Please capture the rectangular ID card';
        return false;
      }

      // Analyze image content to detect card-like features
      final isCardLike = await _detectCardFeatures(image);
      
      if (!isCardLike) {
        _imageValidationError =
            'Image doesn\'t appear to be an ID card. Please upload a clear photo of your CNIC';
        return false;
      }

      return true;
    } catch (e) {
      _imageValidationError =
          'Error validating image: ${e.toString()}. Please try another photo';
      return false;
    } finally {
      setState(() {
        _isProcessingImage = false;
      });
    }
  }

  Future<bool> _detectCardFeatures(img.Image image) async {
    try {
      final width = image.width;
      final height = image.height;
      final random = Random();

      // 1. Check for edge detection (cards have defined edges)
      int edgeCount = 0;
      final edgeSamples = 30;

      for (int i = 0; i < edgeSamples; i++) {
        final x = random.nextInt(width - 1);
        final y = random.nextInt(height - 1);

        final current = image.getPixel(x, y);
        final right = image.getPixel(x + 1, y);
        final down = image.getPixel(x, y + 1);

        // Calculate edge strength
        final edgeStrengthH = _colorDifference(current, right);
        final edgeStrengthV = _colorDifference(current, down);

        if (edgeStrengthH > 80 || edgeStrengthV > 80) {
          edgeCount++;
        }
      }

      // Cards should have some edges but not too many
      if (edgeCount < 3) {
        return false; // Too uniform, might be blank
      }

      // 2. Check color variation (cards have text, logos, colors)
      int colorVariations = 0;
      final colorSamples = 40;
      
      for (int i = 0; i < colorSamples; i++) {
        final x1 = random.nextInt(width);
        final y1 = random.nextInt(height);
        final x2 = random.nextInt(width);
        final y2 = random.nextInt(height);

        final pixel1 = image.getPixel(x1, y1);
        final pixel2 = image.getPixel(x2, y2);

        final diff = _colorDifference(pixel1, pixel2);

        if (diff > 60) {
          colorVariations++;
        }
      }

      // Cards should have reasonable color variation
      if (colorVariations < colorSamples / 5) {
        return false; // Too uniform
      }

      // 3. Check brightness distribution (cards aren't all dark or all bright)
      int brightPixels = 0;
      int darkPixels = 0;
      final brightnessSamples = 50;

      for (int i = 0; i < brightnessSamples; i++) {
        final x = random.nextInt(width);
        final y = random.nextInt(height);
        final pixel = image.getPixel(x, y);

        final brightness = (pixel.r + pixel.g + pixel.b) / 3;

        if (brightness > 200) brightPixels++;
        if (brightness < 50) darkPixels++;
      }

      // Reject if too many dark or bright pixels (overexposed/underexposed)
      if (brightPixels > brightnessSamples * 0.8 ||
          darkPixels > brightnessSamples * 0.8) {
        return false;
      }

      // 4. Check for rectangular regions (cards have rectangular structure)
      // Sample the center and edges to see if there's content
      final centerX = width ~/ 2;
      final centerY = height ~/ 2;
      final centerRadius = min(width, height) ~/ 6;

      int centerActivity = 0;
      for (int i = 0; i < 15; i++) {
        final x1 = centerX + random.nextInt(centerRadius) - centerRadius ~/ 2;
        final y1 = centerY + random.nextInt(centerRadius) - centerRadius ~/ 2;
        final x2 = centerX + random.nextInt(centerRadius) - centerRadius ~/ 2;
        final y2 = centerY + random.nextInt(centerRadius) - centerRadius ~/ 2;

        if (x1 >= 0 && x1 < width && y1 >= 0 && y1 < height &&
            x2 >= 0 && x2 < width && y2 >= 0 && y2 < height) {
          final pixel1 = image.getPixel(x1, y1);
          final pixel2 = image.getPixel(x2, y2);

          if (_colorDifference(pixel1, pixel2) > 50) {
            centerActivity++;
          }
        }
      }

      // Cards should have activity in the center (text, photo, etc.)
      if (centerActivity < 3) {
        return false;
      }

      // If all checks pass, it's likely a card
      return true;
    } catch (e) {
      debugPrint('Error in card detection: $e');
      return false;
    }
  }

  int _colorDifference(img.Pixel p1, img.Pixel p2) {
    return ((p1.r - p2.r).abs() + (p1.g - p2.g).abs() + (p1.b - p2.b).abs())
        .toInt();
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ID card image validated successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          setState(() {
            selectedImage = null;
          });
          if (_imageValidationError != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_imageValidationError!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        const SnackBar(
          content: Text('Please upload CNIC image'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate health issue selection
    if (healthIssue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select health history option'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate checkboxes
    if (!healthCondition) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to health conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (!termConditions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        formattedCNIC = '${formattedCNIC.substring(0, 5)}-'
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
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Additional Information',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Last blood donation field with selected date display
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        child: Center(
                          child: ListTile(
                            title: lastBloodDonation == null
                                ? const Text('Last Blood Donation (Optional)')
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Last Blood Donation',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        _formatDateForDisplay(
                                          lastBloodDonation!,
                                        ),
                                        style: const TextStyle(
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
                                    lastBloodDonation =
                                        selectedDate.toIso8601String();
                                  });
                                }
                              },
                              icon: const Icon(Icons.calendar_month_rounded),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

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
                              padding: const EdgeInsets.only(left: 12, top: 4),
                              child: Text(
                                _cnicError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 15),

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
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.symmetric(horizontal: 0),
                              child: Center(
                                child: _isProcessingImage
                                    ? const Row(
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
                                          const SizedBox(width: 8),
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
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Text(
                                'Image: ${selectedImage!.name}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Health history section
                      const Text(
                        'Health History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Have you had any diseases or health issues in the past 3 years',
                        style: TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 10),

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
                          const SizedBox(width: 10),
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

                      const SizedBox(height: 15),

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
                          const Expanded(
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
                          const Expanded(
                            child: Text(
                              'I agree to the terms and conditions',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
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
                            backgroundColor: const Color(0xFFE31A1A),
                            text: "Submit",
                            textColor: Colors.white,
                            onTap: () async {
                              if (_validateAllFields()) {
                                try {
                                  await createUser();
                                  await saveUserDataToFirestore();

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
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
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'This email is already registered'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Footer text
                      const Center(
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

  @override
  void dispose() {
    _cnicController.dispose();
    super.dispose();
  }
}