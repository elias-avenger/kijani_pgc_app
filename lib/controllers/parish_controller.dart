import 'package:get/get.dart';
import 'package:kijani_pgc_app/models/group.dart';
import 'package:kijani_pgc_app/models/report.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/models/user_model.dart';
import 'package:kijani_pgc_app/repositories/group_repository.dart';
import 'package:kijani_pgc_app/repositories/report_repository.dart';
import 'package:kijani_pgc_app/services/getx_storage.dart';

class ParishController extends GetxController {
  final GroupRepository _groupRepo = GroupRepository();
  final StorageService _storageService = StorageService();

  final ReportRepository _reportRepo = ReportRepository();

  final parishData = <String, dynamic>{}.obs;
  final RxList<Group> groups = <Group>[].obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  var unSyncedReports = 0.obs;
  var userAvatar = ''.obs;
  var activeParish = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getParishData();
  }

  // Method to check if a user is logged in
  Future<void> getParishData() async {
    Data<List<Group>> localGroups =
        await _groupRepo.fetchLocalGroups(parish: activeParish.value);
    if (localGroups.status) {
      groups.assignAll(localGroups.data as Iterable<Group>);
    }
    //fetch user photo

    //fetch unSynced reports
    Data<List<DailyReport>> unSyncedData =
        await _reportRepo.fetchLocalReports();
    if (unSyncedData.status) {
      unSyncedReports.value = unSyncedData.data!.length;
    } else {
      unSyncedReports.value = 0;
    }
    // Get.offAllNamed(Routes.HOME);
    // } else {
    //   Get.offAllNamed(Routes.LOGIN);
    // }
  }

  //dispose controllers
  // @override
  // void onClose() {
  //   emailController.dispose();
  //   codeController.dispose();
  //   super.onClose();
  // }
}
