import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kijani_pmc_app/controllers/user_controller.dart';
import 'package:kijani_pmc_app/services/internet_check.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailFieldController = TextEditingController();
  final codeFieldController = TextEditingController();

  //global key
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String errorMessage = '';
  String loadingText = '';
  final myPMC = Get.put(UserController());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage("images/bg.png"),
            //   alignment: Alignment.bottomCenter,
            //   fit: BoxFit.fitWidth,
            //   opacity: 0.3,
            // ),
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
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image(
                        image: AssetImage("images/kijani_logo.png"),
                        color: Color(0xff23566d),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Kijani Forestry",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff23566d),
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
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff23566d),
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
                        // autofocus: true,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "Enter your email",
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff23566d),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff23566d),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          border: OutlineInputBorder(),
                          counterText: '',
                          hintStyle: TextStyle(
                            color: Color(0xff23566d),
                            fontSize: 16.0,
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        controller: emailFieldController,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                        // autofocus: true,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "Enter Code",
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff23566d),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff23566d),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          border: OutlineInputBorder(),
                          counterText: '',
                          hintStyle: TextStyle(
                            color: Color(0xff23566d),
                            fontSize: 16.0,
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Pin';
                          }
                          return null;
                        },
                        controller: codeFieldController,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Color(0xFFAA0000),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                      loadingStateWidget:
                          LoadingAnimationWidget.fourRotatingDots(
                              color: Colors.white, size: 30),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          var internetStatus =
                              await InternetCheck().getAirtableConMessage();
                          if (internetStatus == 'connected') {
                            String msg = await myPMC.authenticate(
                              email: emailFieldController.text.toLowerCase(),
                              code: codeFieldController.text.trim(),
                            );
                            if (msg == 'Success') {
                              Map<String, dynamic> userData =
                                  await myPMC.getBranchData();
                              Get.to(const MainScreen());
                            }
                          } else {
                            Get.snackbar(
                              "No internet",
                              "Please check your internet connection and try again",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 5),
                            );
                          }
                        }
                      },
                    ),
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
                            color: Color(0xff23566d),
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
    );
    //}
  }
}
