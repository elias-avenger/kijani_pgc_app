import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/modules/group/controllers/group_controller.dart';

class GroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupController());
  }
}
