import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NewGroupForm extends StatefulWidget {
  const NewGroupForm({super.key, required this.parishName});
  final String parishName;

  @override
  State<NewGroupForm> createState() => _NewGroupFormState();
}

class _NewGroupFormState extends State<NewGroupForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'images/kijani_logo.png',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff23566d),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'You are registering a new group for ${widget.parishName.split('|').last} Parish',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 14,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Group Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xff23566d),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xff23566d),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a group name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              EasyButton(
                height: 65,
                borderRadius: 16.0,
                buttonColor: const Color(0xff23566d),
                idleStateWidget: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                loadingStateWidget: LoadingAnimationWidget.fourRotatingDots(
                    color: Colors.white, size: 30),
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    //TODO: add functionality to register group

                    //imitate a delay
                    await Future.delayed(const Duration(seconds: 2));
                    //snackbar
                    Get.snackbar(
                      'Success',
                      'Group registered successfully',
                      colorText: Colors.white,
                      backgroundColor: Colors.green,
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
