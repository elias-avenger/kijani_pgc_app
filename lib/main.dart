import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:kijani_pmc_app/controllers/reports_controller.dart';
import 'package:kijani_pmc_app/controllers/user_controller.dart';
import 'package:kijani_pmc_app/screens/login_screen.dart';
import 'package:kijani_pmc_app/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register the ReportsController here
  Get.put(ReportsController()); // Registering ReportsController globally
  Get.put(UserController()); // Already registered UserController

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic> data = {};
  bool isLoading = true;
  final myPMC = Get.put(UserController());
  @override
  void initState() {
    super.initState();
    checkForUpdate();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: //isLoading
            //? const LoadingScreen():
            data.isEmpty
                ? const LoginScreen()
                : const MainScreen() //UserPage(userData: data),
        );
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    data = await myPMC.getBranchData();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          update();
        }
      });
    }).catchError((e) {
      if (kDebugMode) {
        print(e.toString());
      }
    });
  }

  void update() async {
    if (kDebugMode) {
      print('Updating');
    }

    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((e) {
      if (kDebugMode) {
        print(e.toString());
      }
    });
  }
}
