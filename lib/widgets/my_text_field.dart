import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obsecureFlag;
  final IconData? suffixIcon;
  final String? labelText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixTap;

  const MyTextField({
    super.key,
    required this.hintText,
    this.obsecureFlag = false,
    this.suffixIcon,
    required this.controller,
    this.labelText,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.onSuffixTap,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obsecureFlag;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      obscureText: _isObscured,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        fillColor: Colors.red.shade50,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(style: BorderStyle.none, width: 0),
        ),
        suffixIcon: widget.obsecureFlag
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                  widget.onSuffixTap?.call();
                },
              )
            : (widget.suffixIcon != null ? Icon(widget.suffixIcon) : null),
      ),
    );
  }
}