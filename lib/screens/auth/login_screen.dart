import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/components/widgets/buttons/primary_button.dart';
import 'package:kijani_pmc_app/components/widgets/text_field.dart';
import 'package:kijani_pmc_app/controllers/user_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final UserController controller = Get.find<UserController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: Get.height * 0.1),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Image.asset("images/kijani_logo.png"),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Kijani PGC App",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Login to access your app account",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 40),
                      CustomTextField(
                        label: "Email Address",
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Email is required";
                          }
                          if (!GetUtils.isEmail(value.trim())) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: "Your Code",
                        controller: controller.codeController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Code is required!";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        text: "Login",
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await controller.login();
                          }
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
