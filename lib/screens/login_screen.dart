import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('ESPERFLOW'),
          Text('Donate Life, Save Lives'),

          // email text field
          MyTextField(),

          // password field
          MyTextField(),

          // forgot text button
          TextButton(onPressed: () {}, child: Text('Forgot Password')),

          // login button
          MyCustomButtom(),

          // esperflow logo
          // TODO: use image or icon

          // register option if user dont have an account
          Row(
            children: [
              Text('Don\'t have an account? '),
              TextButton(onPressed: () {}, child: Text('Register')),
            ],
          ),
        ],
      ),
    );
  }
}
