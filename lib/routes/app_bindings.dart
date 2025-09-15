import 'package:get/get.dart';
import 'package:kijani_pgc_app/controllers/parish_controller.dart';
import 'package:kijani_pgc_app/controllers/syncing_controller.dart';
import 'package:kijani_pgc_app/controllers/user_controller.dart';

import '../controllers/group_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController());
  }
}

class DataBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SyncingController());
  }
}

class ParishBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ParishController());
  }
}

class GroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(GroupController());
  }
}
