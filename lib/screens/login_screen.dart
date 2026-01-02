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
  String? _emailError;
  String? _passwordError;

  Future<void> signIn() async {
    // Reset previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Get values
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Email validation
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      return;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    // Password validation
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      return;
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
      return;
    }

    // If validation passes, proceed with Firebase authentication
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      String errorMessage = 'Login failed';
      
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid email or password';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many attempts. Please try again later';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> showResetPasswordDialog(BuildContext context) async {
    final emailController = TextEditingController();
    String? dialogEmailError;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Reset Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    errorText: dialogEmailError,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (dialogEmailError != null) {
                      setState(() {
                        dialogEmailError = null;
                      });
                    }
                  },
                ),
                if (dialogEmailError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dialogEmailError!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  
                  if (email.isEmpty) {
                    setState(() {
                      dialogEmailError = 'Email is required';
                    });
                    return;
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                    setState(() {
                      dialogEmailError = 'Please enter a valid email address';
                    });
                    return;
                  }
                  
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: email,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password reset email sent!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text("Send"),
              ),
            ],
          );
        },
      ),
    );
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
            children: [
              SizedBox(height: 20),
              Text(
                'Donate Life, Save Lives',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 30),

              // email text field with error
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    controller: _emailController,
                    hintText: "Email",
                    suffixIcon: Icons.email_outlined,
                    onChanged: (value) {
                      if (_emailError != null) {
                        setState(() {
                          _emailError = null;
                        });
                      }
                    },
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
                    suffixIcon: Icons.remove_red_eye_outlined,
                    onChanged: (value) {
                      if (_passwordError != null) {
                        setState(() {
                          _passwordError = null;
                        });
                      }
                    },
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

              // forgot text button
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      showResetPasswordDialog(context);
                    },
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

              SizedBox(height: 20),

              // login button
              MyCustomButtom(
                backgroundColor: Color(0xFFE31A1A),
                text: "Login",
                textColor: Colors.white,
                onTap: signIn,
              ),

              SizedBox(height: 30),

              // esperflow logo
              Image.asset('assets/images/esperflow_logo.png'),

              SizedBox(height: 20),

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