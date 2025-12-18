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

              // full name text field
              MyTextField(
                controller: _fullNameController,
                hintText: "Full Name",
              ),

              SizedBox(height: 20),

              // email field
              MyTextField(controller: _emailController, hintText: "Email"),

              SizedBox(height: 20),

              // password field
              MyTextField(
                controller: _passwordController,
                hintText: "Password",
              ),

              SizedBox(height: 20),

              // enter phone number field
              MyTextField(
                controller: _phoneNumberController,
                hintText: "Phone Number (+92)",
              ),

              SizedBox(height: 20),

              // drop down menu for blood group selection
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBloodGroup,
                    hint: Text(
                      "Blood Group",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    items: bloodGroups.map((group) {
                      return DropdownMenuItem(value: group, child: Text(group));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBloodGroup = value!;
                      });
                    },
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // address field
              MyTextField(
                controller: _addressController,
                hintText: "Current Address",
              ),

              SizedBox(height: 60),

              // register confirmation button
              MyCustomButtom(
                backgroundColor: Color(0xFFE31A1A),
                text: "Continue",
                textColor: Colors.white,
                onTap: () {
                  context.read<RegisterProvider>().updateRegisterData(
                    newName: _fullNameController.text,
                    newEmail: _emailController.text,
                    newPassword: _passwordController.text,
                    newPhoneNumber: _phoneNumberController.text,
                    newBloodGroup: selectedBloodGroup ?? " ",
                    newAddress: _addressController.text,
                  );
                  Navigator.pushNamed(context, '/additionalInformationScreen');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
