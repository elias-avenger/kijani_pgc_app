import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:kijani_pgc_app/controllers/user_controller.dart';
import 'package:kijani_pgc_app/routes/app_bindings.dart';
import 'package:kijani_pgc_app/routes/app_pages.dart';
import 'package:kijani_pgc_app/screens/auth/login_screen.dart';
import 'package:kijani_pgc_app/screens/home/home_screen.dart';
import 'package:kijani_pgc_app/services/getx_storage.dart';

void main() async {
  StorageService storageService = StorageService();
  await storageService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final UserController userController = Get.put(UserController());
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return StyledToast(
      locale: const Locale('en', 'US'),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialBinding: UserBinding(),
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.pages,
        home: Obx(() {
          if (isLoading.value) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final userData = userController.branchData;
          return userData.isEmpty ? LoginScreen() : const HomeScreen();
        }),
      ),
    );
  }

  Future<void> _checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Update check failed: updated $e");
      }
    }
  }
}
