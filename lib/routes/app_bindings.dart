import 'package:get/get.dart';
import 'package:kijani_pmc_app/controllers/syncing_controller.dart';
import 'package:kijani_pmc_app/controllers/user_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController());
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UserController());
  }
}

class DataBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SyncingController());
  }
}
