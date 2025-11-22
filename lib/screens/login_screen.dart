import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'ESPERFLOW',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          spacing: 20,
          children: [
            Text('Donate Life, Save Lives'),

            // email text field
            MyTextField(hintText: "Email", suffixIcon: Icons.email_outlined),

            // password field
            MyTextField(
              hintText: "Password",
              obsecureFlag: true,
              suffixIcon: Icons.remove_red_eye_outlined,
            ),

            // forgot text button
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Align(
                alignment: AlignmentGeometry.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),

            // login button
            MyCustomButtom(
              backgroundColor: Color(0xFFE31A1A),
              text: "Login",
              textColor: Colors.white,
              onTap: () {
                Navigator.pushNamed(context, '/homeScreen');
              },
            ),

            // esperflow logo
            Image.asset('assets/images/esperflow_logo.png'),

            // register option if user dont have an account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account?',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/registerScreen');
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
