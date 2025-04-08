import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:kijani_pmc_app/models/parish.dart';
import 'package:kijani_pmc_app/services/airtable_services.dart';
import 'package:kijani_pmc_app/services/getx_storage.dart';

class ParishRepository {
  final StorageService myPrefs = StorageService();

  // Function to fetch parishes from Airtable
  Future<List<Parish>> fetchParishes(List<String> parishCodes) async {
    try {
      if (parishCodes.isEmpty) {
        print('No parish codes provided, returning empty list');
        return [];
      }
      String filter =
          'OR(${parishCodes.map((code) => '{Parish} = "${code.trim()}"').join(', ')})';

      List<String> fields = ['ID', 'Parish', 'Parish Name', 'GroupIDs', 'PC'];

      List<AirtableRecord> data = await uGGardensBase
          .fetchRecordsWithFilter("Parishes", filter, fields: fields);

      if (data.isEmpty) {
        print('No records found for the provided parish codes');
        return [];
      }

      List<Parish> parishes =
          data.map((record) => Parish.fromAirtable(record)).toList();
      return parishes;
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print("Airtable Exception: ${e.message}");
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return [];
    }
  }

  // Function to save parishes data locally
  Future<bool> saveParishes(List<Parish> parishes) async {
    try {
      for (var parish in parishes) {
        if (kDebugMode) {
          print('Saving Parish: ${parish.name}, ID: ${parish.id}');
        }
        await myPrefs.saveEntity(
            kParishDataKey,
            parish.id, // Unique ID for the parish
            parish, // The entity object (not used directly, but for clarity)
            parish.toJson // The JSON conversion function
            );
      }

      // Verify storage
      final storedParishes = await fetchLocalParishes();
      if (kDebugMode) {
        print('Stored ${storedParishes?.length ?? 0} parishes');
      }
      return storedParishes != null && storedParishes.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving parishes: $e');
      }
      return false;
    }
  }

  // Function to fetch parishes data locally
  Future<List<Parish>?> fetchLocalParishes() async {
    try {
      final storedData = myPrefs.fetchAllEntities(
        kParishDataKey,
        (data) => Parish.fromJson(data),
      );
      if (kDebugMode) {
        print('Raw stored data: $storedData');
      }

      if (storedData.isEmpty) {
        if (kDebugMode) {
          print('No local parishes found');
        }
        return [];
      }

      // Convert Map values to List
      final parishes = storedData.values.toList().cast<Parish>();
      if (kDebugMode) {
        print('Fetched ${parishes.length} local parishes');
      }
      return parishes;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local parishes: $e');
      }
      return null; // Or return [] if you prefer
    }
  }
}
