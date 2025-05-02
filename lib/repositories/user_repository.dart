import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:kijani_pmc_app/models/return_data.dart';
import 'package:kijani_pmc_app/models/user_model.dart';
import 'package:kijani_pmc_app/services/airtable_services.dart';
import 'package:kijani_pmc_app/services/getx_storage.dart';

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
      return Data<User>.failure("User not found or inactive");
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print("Airtable Exception: ${e.message}");
      }
      return Data<User>.failure("Airtable Error");
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return Data<User>.failure("An error occurred while checking user");
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
        return Data<User>.success(storedUser.data!);
      } else {
        return Data<User>.failure("Failed to save user data locally");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user: $e');
      }
      return Data<User>.failure("Failed to save user data locally");
    }
  }

  Future<Data<User>> fetchLocalUser() async {
    try {
      User? data = storageService.fetchEntity(
          kUserDataKey, 'current', User.fromJson) as User?;
      if (data != null) {
        return Data<User>.success(data);
      } else {
        return Data<User>.failure("No user data found locally");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user: $e');
      }
      return Data<User>.failure("Failed to fetch user data locally");
    }
  }

  //fecth user id photo
  Future<Data<String>> fetchUserPhoto(User user) async {
    String fullid = user.id.split(" -- ").first.trim();
    String firstId = fullid.split("|").first.trim();
    String id = "$firstId | ${fullid.split("|").last.trim()}";

    try {
      String filter = 'SEARCH("$id", {ID}) > 0';
      List<AirtableRecord> data =
          await hrBase.fetchRecordsWithFilter(kUserPhotosTable, filter);
      if (data.isNotEmpty) {
        AirtableRecord record = data.first;
        List<dynamic> attachments =
            record.fields["Attach Passport Photo"] ?? [];
        return Data<String>.success(attachments.first['url']);
      }
      return Data<String>.failure("User photo not found");
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print("Airtable Exception: ${e.message}");
        print("Airtable Exception details: ${e.details}");
      }
      return Data<String>.failure("Airtable Error");
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return Data<String>.failure(
          "An error occurred while fetching user photo");
    }
  }
}
