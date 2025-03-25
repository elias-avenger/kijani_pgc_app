import 'package:airtable_crud/airtable_plugin.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/global/services/network_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';

class UserdataProvider extends GetxController {
  var reports = 0.obs;

  // Retrieve the AuthController instance
  final AuthController auth = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    loadReportsFromStorage();
  }

  // Load reports from Shared Preferences
  Future<void> loadReportsFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    reports.value = prefs.getInt('reports') ?? 0;
    await checkConnectivityAndFetch(auth.userRole.toString());
  }

  // Check connectivity and fetch reports if internet is available
  Future<void> checkConnectivityAndFetch(String reportType) async {
    var connectivityResult = await NetworkServices().checkAirtableConnection();
    if (connectivityResult) {
      await fetchReports(reportType);
    } else {
      print("No internet connection. Using cached data.");
    }
  }

  // Function to fetch reports based on report type
  Future<void> fetchReports(String reportType) async {
    String filter;
    String tableName;
    var base;

    // Set filter and table name based on the report type and user data
    switch (reportType) {
      case 'pmc':
        filter =
            'AND({PMC}="${auth.userData['Branch']} | ${auth.userData['PMC']}")';
        tableName = 'PMC Reports';
        base = currentGardenBase;
        break;
      case 'mel':
        filter =
            'AND({MEL}="${auth.userData['MEL Officer'].trim()} -- ${auth.userData['Branch'].trim()}")';
        tableName = 'MEL Reports';
        base = currentGardenBase;
        break;
      case 'bc':
        filter = 'AND({BC Email}="${auth.userData['BC-Email'].trim()}")';
        tableName = 'BCs Daily Reports';
        base = currentNurseryBase;
        break;
      default:
        print("Unknown report type: $reportType");
        return;
    }

    try {
      var res = await base.fetchRecordsWithFilter(tableName, filter);
      print("FILTER::: $filter");
      print("REPORT LENGTH for $reportType: ${res.length}");

      // Update the main reports count and save it to storage
      reports.value = res.length;
      await saveReportsToStorage(reports.value);
    } on AirtableException catch (e) {
      print("AIRTABLE ERROR MESSAGE: ${e.message}");
      print("AIRTABLE ERROR DETAILS: ${e.details}");
    } catch (e) {
      print(e.toString());
    }
  }

  // Save reports count to Shared Preferences
  Future<void> saveReportsToStorage(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reports', count);
  }
}
