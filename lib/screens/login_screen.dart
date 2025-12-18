import 'package:esperflow/widgets/my_custom_buttom.dart';
import 'package:esperflow/widgets/my_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            children: [
              Text('Donate Life, Save Lives'),

              // email text field
              MyTextField(
                controller: _emailController,
                hintText: "Email",
                suffixIcon: Icons.email_outlined,
              ),

              // password field
              MyTextField(
                controller: _passwordController,
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
                onTap: signIn,
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
      ),
    );
  }
}
