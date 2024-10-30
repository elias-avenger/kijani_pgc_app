import 'dart:convert';
import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:kijani_pmc_app/app/data/models/planting_update.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlantingUpdateProvider extends GetxController {
  List<PlantingUpdate> plantingUpdates = [];

  Future<List<PlantingUpdate>?> fetchPlantingUpdates(String gardenId) async {
    try {
      // Fetch records from Airtable
      var response = await currentGardenBase.fetchRecordsWithFilter(
          'Planting Updates', 'AND({Garden} = "$gardenId")');

      if (kDebugMode) {
        print(
            "Planting updates fetched for garden $gardenId: ${response.length}");
        response.forEach((record) {
          print(record.fields);
        });
      }

      // Parse the records into PlantingUpdate objects
      List<PlantingUpdate> fetchedUpdates = response
          .map((record) => PlantingUpdate.fromJson(record.fields))
          .toList();

      // Save fetched updates to local list and SharedPreferences
      plantingUpdates.addAll(fetchedUpdates);
      await _saveUpdatesToSharedPreferences(fetchedUpdates);

      return fetchedUpdates;
    } on AirtableException catch (e) {
      print("Airtable Error: ${e.message}, Details: ${e.details}");
    } catch (e) {
      print("FETCH PLANTING UPDATES ERROR: ${e.toString()}");
    }
    return null;
  }

  Future<PlantingUpdate?> getUpdateById(String id) async {
    return plantingUpdates.firstWhere((update) => update.id == id);
  }

  // Save planting updates to SharedPreferences
  Future<void> _saveUpdatesToSharedPreferences(
      List<PlantingUpdate> updates) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> updatesJsonList =
        updates.map((update) => jsonEncode(update.toJson())).toList();
    await prefs.setStringList('planting_updates', updatesJsonList);

    print("Planting updates saved to SharedPreferences:");
    updatesJsonList.forEach(print);
  }

  // Load planting updates from SharedPreferences
  Future<List<PlantingUpdate>> loadUpdatesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? updatesJsonList = prefs.getStringList('planting_updates');
    if (updatesJsonList != null) {
      return updatesJsonList
          .map((updateJson) => PlantingUpdate.fromJson(jsonDecode(updateJson)))
          .toList();
    }
    return [];
  }
}
