import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/data/providers/parish_provider.dart';

class ParishBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ParishProvider());
  }
}
