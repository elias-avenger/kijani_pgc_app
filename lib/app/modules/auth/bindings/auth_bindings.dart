import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/app/modules/mel/controllers/mel_controller.dart';
import 'package:kijani_pmc_app/app/modules/pmc/controllers/pmc_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<MelController>(() => MelController());
    Get.lazyPut<PmcController>(() => PmcController());
  }
}
