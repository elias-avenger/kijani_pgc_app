import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:kijani_pmc_app/app/data/models/group.dart';
import 'package:kijani_pmc_app/app/data/models/parish_model.dart';
import 'package:kijani_pmc_app/app/data/providers/group_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParishProvider extends GetxController {
  final List<Parish> parishes = [];

  final GroupProvider groupProvider = GroupProvider();

  // Function to fetch parishes and their hierarchical data
  Future<void> fetchParishes(List<Parish> parishList) async {
    for (var parish in parishList) {
      parishes.add(parish); // Add the parish to the list

      // Fetch groups for each parish
      List<Group>? groups = await groupProvider.fetchGroupsForParish(parish);
      parish.groups.addAll(groups!);

      if (kDebugMode) {
        print('Groups fetched for parish ${parish.name}');
      }
    }

    await _saveParishesToSharedPreferences(parishes);
  }

  // Save parishes to SharedPreferences
  Future<void> _saveParishesToSharedPreferences(List<Parish> parishes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> parishJsonList =
        parishes.map((parish) => jsonEncode(parish.toJson())).toList();
    print("Saving the following parishes:");
    await prefs.setStringList('parishes', parishJsonList);
  }

  Future<void> fetchParishesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> parishJsonList = prefs.getStringList('parishes') ?? [];
    parishes.addAll(
        parishJsonList.map((json) => Parish.fromJson(jsonDecode(json))));
  }

  Future<Parish?> getParishById(String id) async {
    return parishes.firstWhere((parish) => parish.parishId == id);
  }
}
