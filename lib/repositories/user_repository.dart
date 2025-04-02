import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:kijani_pmc_app/models/user_model.dart';
import 'package:kijani_pmc_app/services/airtable_services.dart';
import 'package:kijani_pmc_app/services/local_storage.dart';

class UserRepository {
  final LocalStorage _localStorage = LocalStorage();
  //check if user exists
  Future<User?> checkUser({required String email, required String code}) async {
    try {
      String filter =
          'AND({Email}="$email", {AppCode}="$code", {Status}="Active")';
      List<AirtableRecord> data =
          await uGGardensBase.fetchRecordsWithFilter(kPGCsTable, filter);

      if (data.isNotEmpty) {
        AirtableRecord record = data.first;
        User user = User.fromJson(record.fields);
        return user;
      }
      return null;
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print("Airtable Exception: ${e.message}");
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return null;
    }
  }

  //get user data from local storage
  Future<User> getBranchData() async {
    final storedData = await _localStorage.getData(key: 'userData');
    return User.fromJson(storedData);
  }
}
