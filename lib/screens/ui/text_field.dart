import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.inputType,
    required this.validate,
  });

  final TextEditingController controller;
  final String labelText;
  final TextInputType inputType;
  final String? Function(String?)? validate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        keyboardType: inputType,
        decoration: InputDecoration(
          focusColor: Colors.grey[600],
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey[600]), // Label color
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
        ),
        controller: controller,
        validator: validate,
      ),
    );
  }
}
