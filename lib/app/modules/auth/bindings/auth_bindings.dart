import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/data/providers/userdata_provider.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/app/modules/bc/controllers/bc_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<UserdataProvider>(() => UserdataProvider());
    Get.lazyPut<BcController>(() => BcController());
  }
}
