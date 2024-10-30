import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/modules/pmc/controllers/pmc_controller.dart';

class PmcBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PmcController>(() => PmcController());
  }
}
