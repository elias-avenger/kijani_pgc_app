import 'dart:convert';
import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:kijani_pmc_app/app/data/models/farmer.dart';
import 'package:kijani_pmc_app/app/data/models/group.dart';
import 'package:kijani_pmc_app/app/data/models/parish_model.dart';
import 'package:kijani_pmc_app/app/data/providers/farmer_provider.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupProvider extends GetxController {
  final FarmerProvider farmerProvider = FarmerProvider();
  List<Group> groups = [];

  Future<List<Group>?> fetchGroupsForParish(Parish parish) async {
    if (kDebugMode) {
      print('Fetching groups for parish ${parish.parishId}');
    }
    try {
      var response = await nurseryBase.fetchRecordsWithFilter(
          'Group Allocation',
          'AND({Parish ID} = "${parish.parishId}", {Season Status} = "Current")');
      List<Group> fetchedGroups =
          response.map((record) => Group.fromJson(record.fields)).toList();

      // Fetch farmers for each group
      for (var group in fetchedGroups) {
        List<Farmer>? farmers =
            await farmerProvider.fetchFarmersForGroup(group);
        if (farmers != null) {
          group.farmers.addAll(farmers);
        }
      }

      // Save the fetched groups to the local list and SharedPreferences
      groups.addAll(fetchedGroups);
      await _saveGroupsToSharedPreferences(fetchedGroups);

      return fetchedGroups;
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print(e.message + e.details!);
      }
    } catch (e) {
      if (kDebugMode) {
        print("ERROR: ${e.toString()}");
      }
    }
    return null;
  }

  Future<Group?> getGroupById(String id) async {
    return groups.firstWhere((group) => group.id == id);
  }

  // Save groups to SharedPreferences
  Future<void> _saveGroupsToSharedPreferences(List<Group> groups) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> groupJsonList =
        groups.map((group) => jsonEncode(group.toJson())).toList();
    await prefs.setStringList('groups', groupJsonList);

    if (kDebugMode) {
      print("Groups saved to SharedPreferences:");
    }
  }

  // Load groups from SharedPreferences
  Future<List<Group>> loadGroupsFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? groupJsonList = prefs.getStringList('groups');
    if (groupJsonList != null) {
      return groupJsonList
          .map((groupJson) => Group.fromJson(jsonDecode(groupJson)))
          .toList();
    }
    return [];
  }
}
