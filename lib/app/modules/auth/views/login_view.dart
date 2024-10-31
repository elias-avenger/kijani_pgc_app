import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/global/enums/colors.dart';
import 'package:kijani_pmc_app/global/services/network_services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/bg.png"),
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.fitWidth,
                  opacity: 0.3,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 50,
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Center(
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Image(
                              image: const AssetImage("images/kijani_logo.png"),
                              color: kfGreen,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Kijani Forestry",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: kfGreen,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              "We plant trees to break the cycle of climate-induced poverty in Africa",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: kfGreen,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              autocorrect: false,
                              decoration: InputDecoration(
                                hintText: "Enter your email",
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kfGreen,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kfGreen,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                ),
                                border: const OutlineInputBorder(),
                                counterText: '',
                                hintStyle: GoogleFonts.lato(
                                  color: kfGreen,
                                  fontSize: 16.0,
                                ),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              controller: usernameController,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              autocorrect: false,
                              decoration: InputDecoration(
                                hintText: "Enter Code",
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kfGreen,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kfGreen,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                ),
                                border: const OutlineInputBorder(),
                                counterText: '',
                                hintStyle: GoogleFonts.lato(
                                  color: kfGreen,
                                  fontSize: 20.0,
                                ),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Pin';
                                }
                                return null;
                              },
                              controller: passwordController,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Obx(() {
                            return TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: kfGreen,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: authController.isButtonLoading.value
                                  ? null
                                  : () async {
                                      if (await NetworkServices()
                                          .checkAirtableConnection()) {
                                        await authController.login(
                                            usernameController.text.trim(),
                                            passwordController.text.trim());
                                      } else {
                                        Get.snackbar(
                                          'No internet connection',
                                          'Please check your internet connection and try again',
                                          colorText: Colors.white,
                                          backgroundColor: Colors.red,
                                        );
                                      }
                                    },
                              child: Text(
                                authController.isButtonLoading.value
                                    ? 'Checking user...'
                                    : 'Login',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              "© ${DateTime.now().year} Kijani Forestry. All rights reserved.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontSize: 10,
                                  color: Color.fromARGB(255, 22, 78, 26),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Full-screen loading overlay
          if (authController.isLoading.value &&
              !authController.isUpdating.value) // Modified condition
            Container(
              color: kfGreen,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Logged in as ${authController.userRole.value.toUpperCase()}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.none, // Ensure no underline
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 180,
                      width: 180,
                      child: Image(
                        image: AssetImage("images/kijani_logo.png"),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LoadingAnimationWidget.fourRotatingDots(
                      color: Colors.white,
                      size: 50,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'loading your data...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        decoration: TextDecoration.none, // Ensure no underline
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
