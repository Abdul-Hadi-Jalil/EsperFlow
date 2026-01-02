import 'package:esperflow/provider/register_provider.dart';
import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? selectedBloodGroup;
  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _phoneNumberError;
  String? _bloodGroupError;
  String? _addressError;

  bool _validateForm() {
    bool isValid = true;

    // Reset all errors
    setState(() {
      _fullNameError = null;
      _emailError = null;
      _passwordError = null;
      _phoneNumberError = null;
      _bloodGroupError = null;
      _addressError = null;
    });

    // Validate Full Name
    if (_fullNameController.text.isEmpty) {
      setState(() {
        _fullNameError = 'Full name is required';
      });
      isValid = false;
    } else if (_fullNameController.text.length < 3) {
      setState(() {
        _fullNameError = 'Name must be at least 3 characters';
      });
      isValid = false;
    }

    // Validate Email
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      isValid = false;
    }

    // Validate Password
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      isValid = false;
    } else if (_passwordController.text.length < 7) {
      setState(() {
        _passwordError = 'Password must be at least 7 characters';
      });
      isValid = false;
    }

    // Validate Phone Number
    if (_phoneNumberController.text.isEmpty) {
      setState(() {
        _phoneNumberError = 'Phone number is required';
      });
      isValid = false;
    } else if (!_phoneNumberController.text.startsWith("+92")) {
      setState(() {
        _phoneNumberError = 'Phone number must start with +92';
      });
      isValid = false;
    } else if (_phoneNumberController.text.length != 13) {
      setState(() {
        _phoneNumberError = 'Phone number must be 13 characters (including +92)';
      });
      isValid = false;
    }

    // Validate Blood Group
    if (selectedBloodGroup == null) {
      setState(() {
        _bloodGroupError = 'Please select your blood group';
      });
      isValid = false;
    }

    // Validate Address
    if (_addressController.text.isEmpty) {
      setState(() {
        _addressError = 'Address is required';
      });
      isValid = false;
    } else if (_addressController.text.length < 10) {
      setState(() {
        _addressError = 'Please enter a more detailed address';
      });
      isValid = false;
    }

    return isValid;
  }

  void _clearErrorOnChange(String field) {
    switch (field) {
      case 'fullName':
        if (_fullNameError != null) {
          setState(() {
            _fullNameError = null;
          });
        }
        break;
      case 'email':
        if (_emailError != null) {
          setState(() {
            _emailError = null;
          });
        }
        break;
      case 'password':
        if (_passwordError != null) {
          setState(() {
            _passwordError = null;
          });
        }
        break;
      case 'phone':
        if (_phoneNumberError != null) {
          setState(() {
            _phoneNumberError = null;
          });
        }
        break;
      case 'address':
        if (_addressError != null) {
          setState(() {
            _addressError = null;
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> bloodGroups = [
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // logo
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'assets/images/esperflow_logo.png',
                  height: 120,
                  width: 120,
                ),
              ),

              // register as donor text
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Register as Donor',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // full name text field with error
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: _fullNameController,
                    hintText: "Full Name",
                    onChanged: (value) => _clearErrorOnChange('fullName'),
                  ),
                  if (_fullNameError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 5),
                      child: Text(
                        _fullNameError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 20),

              // email field with error
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: _emailController,
                    hintText: "Email",
                    onChanged: (value) => _clearErrorOnChange('email'),
                  ),
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 5),
                      child: Text(
                        _emailError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 20),

              // password field with error
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    obsecureFlag: true,
                    labelText: "Cannot be less than 7 characters",
                    onChanged: (value) => _clearErrorOnChange('password'),
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 5),
                      child: Text(
                        _passwordError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 20),

              // enter phone number field with error
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: _phoneNumberController,
                    hintText: "Phone Number (+92)",
                    onChanged: (value) => _clearErrorOnChange('phone'),
                  ),
                  if (_phoneNumberError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 5),
                      child: Text(
                        _phoneNumberError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 20),

              // drop down menu for blood group selection with error
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(9),
                      border: _bloodGroupError != null
                          ? Border.all(color: Colors.red)
                          : null,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBloodGroup,
                        hint: Text(
                          "Blood Group",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        items: bloodGroups.map((group) {
                          return DropdownMenuItem(
                              value: group, child: Text(group));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedBloodGroup = value!;
                            if (_bloodGroupError != null) {
                              _bloodGroupError = null;
                            }
                          });
                        },
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                  if (_bloodGroupError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 5),
                      child: Text(
                        _bloodGroupError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 20),

              // address field with error
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: _addressController,
                    hintText: "Current Address",
                    onChanged: (value) => _clearErrorOnChange('address'),
                  ),
                  if (_addressError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 5),
                      child: Text(
                        _addressError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 60),

              // register confirmation button
              MyCustomButtom(
                backgroundColor: Color(0xFFE31A1A),
                text: "Continue",
                textColor: Colors.white,
                onTap: () {
                  if (_validateForm()) {
                    context.read<RegisterProvider>().updateRegisterData(
                      newName: _fullNameController.text,
                      newEmail: _emailController.text,
                      newPassword: _passwordController.text,
                      newPhoneNumber: _phoneNumberController.text,
                      newBloodGroup: selectedBloodGroup ?? " ",
                      newAddress: _addressController.text,
                    );
                    
                    // Your original phone validation logic (keeping it as is)
                    if (_phoneNumberController.text.length == 13 &&
                        _phoneNumberController.text.startsWith("+92")) {
                      Navigator.pushNamed(
                        context,
                        '/additionalInformationScreen',
                      );
                    } else {
                      // This should rarely happen now since validation is done above
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please enter a valid Phone number"),
                        ),
                      );
                    }
                  } else {
                    // Show a general error message if validation fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Either you did not fill any field or did not write a field correctly"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}