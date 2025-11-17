import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          // register as donor text
          Text('Register as Donor'),

          // full name text field
          MyTextField(),

          // email field
          MyTextField(),

          // enter phone number field
          MyTextField(),

          // drop down menu for blood group selection
          // TODO: will be implemented

          // address field
          MyTextField(),

          // register confimation button
          MyCustomButtom(),
        ],
      ),
    );
  }
}
