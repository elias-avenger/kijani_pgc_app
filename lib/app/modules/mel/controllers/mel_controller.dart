import 'package:airtable_crud/airtable_plugin.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';

class MelController extends GetxController {
  var reports = 4.obs;

  // Retrieve the AuthController instance
  final AuthController auth = Get.find<AuthController>();
  final String title = 'MEL';

  @override
  void onInit() {
    super.onInit();
    // Call fetchReports when the controller is initialized
    fetchReports();
  }

  // Fetch MEL reports
  Future<void> fetchReports() async {
    String filter =
        'AND({MEL}="${auth.userData['MEL Officer'].trim()} -- ${auth.userData['Branch'].trim()}")';
    try {
      var res =
          await currentGardenBase.fetchRecordsWithFilter('MEL Reports', filter);
      // Process the fetched reports and update 'reports' variable accordingly
      print(
          "REPORT LENGTH:: FOR ${auth.userData['MEL Officer'].trim()} -- ${auth.userData['Branch'].trim()} ===== ${res.length}");
      reports.value =
          res.length; // Update reports count with the number of fetched records
    } on AirtableException catch (e) {
      print("AIRTABLE ERROR MESSAGE: ${e.message}");
      print("AIRTABLE ERROR DETAILS: ${e.details}");
    } catch (e) {
      print(e.toString());
    }
  }
}
