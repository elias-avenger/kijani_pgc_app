import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/modules/mel/controllers/report_controller.dart';

class MelReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MELReportController>(() => MELReportController());
  }
}
