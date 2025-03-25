import 'package:airtable_crud/airtable_plugin.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';
import 'package:kijani_pmc_app/global/services/network_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BcController extends GetxController {
  final AuthController authData = Get.find<AuthController>();
  final String title = 'BC';
  var bcId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (authData.userRole.toString() == 'bc') {
      checkNetworkAndFetchData();
    }
  }

  // Check network connectivity and fetch data accordingly
  void checkNetworkAndFetchData() async {
    bool isConnected = await NetworkServices().checkAirtableConnection();
    if (isConnected) {
      await fetchBcDetailsFromAirtable();
    } else {
      await fetchIdFromSharedPreferences();
    }
  }

  // Fetch BC details from Airtable when online
  Future<void> fetchBcDetailsFromAirtable() async {
    try {
      var res = await currentNurseryBase.fetchRecordsWithFilter(
          'BCs', 'AND({Email}="${authData.userData['BC-Email'].trim()}")');
      if (res.isNotEmpty) {
        // Save the ID to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('bcId', res[0].fields['ID']);
        bcId.value = res[0].fields['ID'];
      } else {
        print("No records found in Airtable.");
        // Fetch from SharedPreferences if no records found
        await fetchIdFromSharedPreferences();
      }
    } on AirtableException catch (e) {
      print("Error fetching BC details: ${e.message}");
      print("ERROR DETAILS: ${e.details}");
      // Fetch from SharedPreferences in case of error
      await fetchIdFromSharedPreferences();
    } catch (e) {
      print("An error occurred: ${e.toString()}");
      // Fetch from SharedPreferences in case of error
      await fetchIdFromSharedPreferences();
    }
  }

  // Fetch ID from SharedPreferences when offline
  Future<void> fetchIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bcId.value = prefs.getString('bcId') ?? '';
    if (bcId.value.isEmpty) {
      print("No BC ID found in SharedPreferences.");
      // Handle the case where no data is available
      // For example, notify the user or take appropriate action
    }
  }
}
