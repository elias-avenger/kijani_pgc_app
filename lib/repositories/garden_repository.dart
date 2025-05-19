import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';

import '../models/garden.dart';
import '../models/return_data.dart';
import '../services/airtable_services.dart';
import '../services/getx_storage.dart';

class GroupRepository {
  final StorageService storage = StorageService();

  // Function to fetch groups from Airtable
  Future<Data<List<Garden>>> fetchGroups(String farmerId) async {
    try {
      String filter = '{F_ID} = "${farmerId.trim()}"';

      List<String> fields = <String>[
        'ID',
        'Center Point',
        'Polygon GeoJSON',
        'Total Trees Planted',
        'Total Trees Surviving',
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
        print("Airtable Exception: ${e.message}");
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

  // Function to save groups data locally
  Future<Data> saveGroups(List<Garden> gardens, String farmerId) async {
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

  // Function to fetch groups data locally
  Future<Data<List<Garden>>> fetchLocalGardens({required String farmer}) async {
    try {
      final List<Garden> storedGardens = storage.fetchEntityUnits(
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

      if (kDebugMode) {
        print('Fetched ${storedGardens.length} local gardens');
      }
      return Data<List<Garden>>.success(storedGardens);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local gardens: $e');
      }
      return Data.failure('Error fetching local gardens: $e');
    }
  }
}
