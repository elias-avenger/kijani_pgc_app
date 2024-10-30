import 'dart:convert';
import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:kijani_pmc_app/app/data/models/farmer.dart';
import 'package:kijani_pmc_app/app/data/models/garden.dart';
import 'package:kijani_pmc_app/app/data/models/group.dart';
import 'package:kijani_pmc_app/app/data/providers/garden_provider.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerProvider extends GetxController {
  final GardenProvider gardenProvider = GardenProvider();
  List<Farmer> farmers = [];

  Future<List<Farmer>?> fetchFarmersForGroup(Group group) async {
    if (kDebugMode) {
      print('Fetching farmers for group ${group.name}');
    }
    try {
      var response = await gardenBase.fetchRecordsWithFilter(
          'Farmers', 'AND({Registered From} = "${group.id}")',
          view: 'To app');
      response.forEach((farmer) {
        print('FARMER DETAILS::: ${farmer.fields}');
      });
      List<Farmer> fetchedFarmers =
          response.map((record) => Farmer.fromJson(record.fields)).toList();

      // Fetch gardens for each farmer
      for (var farmer in fetchedFarmers) {
        print('FETCHING GARDEN FOR====== ${farmer.name}');
        List<Garden>? gardens =
            await gardenProvider.fetchGardensForFarmer(farmer);
        gardens?.forEach((garden) {
          print(
              'FETCHED GARDEN FOR FARMER @@@ ${farmer.name} ====== ${garden.id}');
        });
        if (gardens != null) {
          farmer.gardens.addAll(gardens);
        }
      }

      // Save fetched farmers to local list and SharedPreferences
      farmers.addAll(fetchedFarmers);
      await _saveFarmersToSharedPreferences(fetchedFarmers);

      return fetchedFarmers;
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print(e.message + e.details!);
      }
    } catch (e) {
      if (kDebugMode) {
        print("ERROR FETCHING FARMERS: ${e.toString()}");
        throw Exception(e.toString());
      }
    }
    return null;
  }

  Future<Farmer?> getFarmerById(String id) async {
    return farmers.firstWhere((farmer) => farmer.id == id);
  }

  // Save farmers to SharedPreferences
  Future<void> _saveFarmersToSharedPreferences(List<Farmer> farmers) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> farmerJsonList =
        farmers.map((farmer) => jsonEncode(farmer.toJson())).toList();
    await prefs.setStringList('farmers', farmerJsonList);

    if (kDebugMode) {
      print("Farmers saved to SharedPreferences:");
    }
  }

  // Load farmers from SharedPreferences
  Future<List<Farmer>> loadFarmersFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? farmerJsonList = prefs.getStringList('farmers');
    if (farmerJsonList != null) {
      return farmerJsonList
          .map((farmerJson) => Farmer.fromJson(jsonDecode(farmerJson)))
          .toList();
    }
    return [];
  }
}
