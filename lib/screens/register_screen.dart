import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // register as donor text
            Text('Register as Donor'),

            // full name text field
            MyTextField(hintText: "Full Name"),

            // email field
            MyTextField(hintText: "Email"),

            // enter phone number field
            MyTextField(hintText: "Phone Number (+92)"),

            // drop down menu for blood group selection
            // TODO: will be implemented

            // address field
            MyTextField(hintText: "Current Address"),

            // register confimation button
            MyCustomButtom(
              backgroundColor: Colors.red,
              text: "Continue",
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
