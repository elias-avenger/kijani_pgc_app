import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';

import '../models/garden.dart';
import '../models/return_data.dart';
import '../services/airtable_services.dart';
import '../services/getx_storage.dart';

class GardenRepository {
  final StorageService storage = StorageService();

  // Function to fetch groups from Airtable
  Future<Data<List<Garden>>> fetchGardens(String farmerId) async {
    try {
      String filter = 'AND(Farmer, F_ID = "${farmerId.trim()}")';

      List<String> fields = <String>[
        'ID',
        'Center Point',
        'Polygon GeoJSON',
        'Total Trees Planted',
        'Total Trees Surviving',
        'Garden Photos',
        'Species',
        'Planted by species',
        'Surviving by species',
        'Season',
        'Initial planting date',
      ];

      List<AirtableRecord> data = await uGGardensBase
          .fetchRecordsWithFilter("Gardens", filter, fields: fields);
      if (kDebugMode) {
        print(filter);
      }
      if (data.isEmpty) {
        if (kDebugMode) {
          print('No records found for the provided farmer');
        }
        return Data<List<Garden>>.failure(
            "No records found for the provided farmer");
      }

      if (kDebugMode) {
        print('Fetched ${data.length} records from Airtable');
      }

      List<Garden> gardens =
          data.map((record) => Garden.fromAirtable(record)).toList();
      return Data<List<Garden>>.success(gardens);
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print("Airtable Exception: ${e.message} || ${e.details}");
      }
      return Data<List<Garden>>.failure("Airtable Error: ${e.message}");
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return Data<List<Garden>>.failure(
          "An error occurred while fetching gardens");
    }
  }

  Future<Data<List<Garden>>> fetchGardenData(String gardenId) async {
    return Data<List<Garden>>.success([]);
  }

  // Function to save groups data locally
  Future<Data> saveGardens(List<Garden> gardens, String farmerId) async {
    try {
      await storage.saveEntityUnits(
        kGardenDataKey,
        farmerId, // Unique ID for the group
        gardens, // The entity object (not used directly, but for clarity)
      );
      // Verify storage
      Data<List<Garden>> storedGardens =
          await fetchLocalGardens(farmer: farmerId);
      if (kDebugMode) {
        print('Stored ${storedGardens.data?.length ?? 0} gardens');
      }
      return Data.success(storedGardens);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving gardens: $e');
      }
      return Data.failure("Failed to save gardens locally");
    }
  }

  Future<Data> saveGardenData(List<Garden> gardens, String gardenId) async {
    return Data.success([]);
  }

  // Function to fetch groups data locally
  Future<Data<List<Garden>>> fetchLocalGardens({required String farmer}) async {
    try {
      var storedGardens = await storage.fetchEntityUnits(
        kGardenDataKey,
        farmer,
      );
      if (kDebugMode) {
        print('Raw stored data: $storedGardens');
      }

      if (storedGardens.isEmpty) {
        if (kDebugMode) {
          print('No local gardens found');
        }
        return Data<List<Garden>>.failure("No Local Gardens found");
      }

      List<Garden> gardens = [];
      if (gardens.runtimeType == storedGardens.runtimeType) {
        gardens = storedGardens;
      } else {
        List gardensData = storedGardens;
        gardens = gardensData.map((garden) => Garden.fromJson(garden)).toList();
      }

      if (kDebugMode) {
        print('Fetched ${gardens.length} local gardens');
      }
      return Data<List<Garden>>.success(gardens);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local gardens: $e');
      }
      return Data.failure('Error fetching local gardens: $e');
    }
  }

  Future<Data<List<Garden>>> fetchLocalGardenData(
      {required String garden}) async {
    return Data<List<Garden>>.success([]);
  }
}
