import 'dart:convert';
import 'package:airtable_crud/airtable_plugin.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:kijani_pmc_app/app/data/models/farmer.dart';
import 'package:kijani_pmc_app/app/data/models/garden.dart';
import 'package:kijani_pmc_app/app/data/models/planting_update.dart';
import 'package:kijani_pmc_app/app/data/providers/planting_update_provider.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GardenProvider extends GetxController {
  final PlantingUpdateProvider plantingUpdateProvider =
      PlantingUpdateProvider();
  List<Garden> gardens = [];

  Future<List<Garden>?> fetchGardensForFarmer(Farmer farmer) async {
    try {
      print('FETCHING GARDENS FOR::: ${farmer.name}');
      // Fetch gardens for the specified farmer from Airtable
      var response = await currentGardenBase.fetchRecordsWithFilter(
          'Gardens', 'AND({FarmerID} = "${farmer.id}-${farmer.name}")');

      // Parse the records into Garden objects
      List<Garden> fetchedGardens =
          response.map((record) => Garden.fromJson(record.fields)).toList();

      // Fetch planting updates for each garden
      for (var garden in fetchedGardens) {
        List<PlantingUpdate>? updates =
            await plantingUpdateProvider.fetchPlantingUpdates(garden.id);
        if (updates != null) {
          garden.updates.addAll(updates);
        }
      }

      // Save fetched gardens to local list and SharedPreferences
      gardens.addAll(fetchedGardens);
      await _saveGardensToSharedPreferences(fetchedGardens);

      return fetchedGardens;
    } on AirtableException catch (e) {
      print("Airtable Error: ${e.message}, Details: ${e.details}");
    } catch (e) {
      print("FETCH GARDENS ERROR: ${e.toString()}");
    }
    return null;
  }

  Future<Garden?> getGardenById(String id) async {
    return gardens.firstWhere(
      (garden) => garden.id == id,
    );
  }

  // Save gardens to SharedPreferences
  Future<void> _saveGardensToSharedPreferences(List<Garden> gardens) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> gardenJsonList =
        gardens.map((garden) => jsonEncode(garden.toJson())).toList();
    await prefs.setStringList('gardens', gardenJsonList);
  }

  // Load gardens from SharedPreferences
  Future<List<Garden>> loadGardensFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? gardenJsonList = prefs.getStringList('gardens');
    if (gardenJsonList != null) {
      return gardenJsonList
          .map((gardenJson) => Garden.fromJson(jsonDecode(gardenJson)))
          .toList();
    }
    return [];
  }
}
