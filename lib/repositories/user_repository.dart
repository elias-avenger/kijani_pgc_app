import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/models/user_model.dart';
import 'package:kijani_pgc_app/services/airtable_services.dart';
import 'package:kijani_pgc_app/services/getx_storage.dart';

class UserRepository {
  final StorageService storageService = StorageService();
  //check if user exists
  Future<Data<User>> checkUser(
      {required String email, required String code}) async {
    try {
      String filter =
          'AND({Email}="$email", {AppCode}="$code", {Status}="Active")';
      List<AirtableRecord> data =
          await uGGardensBase.fetchRecordsWithFilter(kPGCsTable, filter);

      if (data.isNotEmpty) {
        AirtableRecord record = data.first;
        User user = User.fromJson(record.fields);
        return Data.success(user);
      }
      return Data.failure("User not found or inactive");
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print("Airtable Exception: ${e.message}");
      }
      return Data.failure("Airtable Error");
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return Data.failure("An error occurred while checking user");
    }
  }

  Future<Data<User>> saveUser(User user) async {
    try {
      await storageService.saveEntity(
        kUserDataKey,
        'current',
        user,
        user.toJson,
      );

      // Verify if the data was stored by reading it back
      Data<User> storedUser = await fetchLocalUser();
      if (storedUser.status) {
        return Data.success(storedUser.data!);
      } else {
        return Data.failure("Failed to save user data locally");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user: $e');
      }
      return Data.failure("Failed to save user data locally");
    }
  }

  Future<Data<User>> fetchLocalUser() async {
    try {
      User? data = storageService.fetchEntity(
          kUserDataKey, 'current', User.fromJson) as User?;
      if (data != null) {
        return Data.success(data);
      } else {
        return Data.failure("No user data found locally");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user: $e');
      }
      return Data.failure("Failed to fetch user data locally");
    }
  }
}
