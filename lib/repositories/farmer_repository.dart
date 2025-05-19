import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';

import '../models/farmer.dart';
import '../models/return_data.dart';
import '../services/airtable_services.dart';
import '../services/getx_storage.dart';

class GroupRepository {
  final StorageService storage = StorageService();

  // Function to fetch farmers from Airtable
  Future<Data<List<Farmer>>> fetchFarmers(String groupId) async {
    try {
      String filter = '{GroupID} = "${groupId.trim()}"';

      List<String> fields = <String>[
        'FarmerID',
        'Farmer Phone Number',
      ];

      List<AirtableRecord> data = await uGGardensBase
          .fetchRecordsWithFilter("Gardens", filter, fields: fields);
      if (kDebugMode) {
        print(filter);
      }
      if (data.isEmpty) {
        if (kDebugMode) {
          print('No records found for the provided group');
        }
        return Data<List<Farmer>>.failure(
            "No records found for the provided group");
      }

      if (kDebugMode) {
        print('Fetched ${data.length} records from Airtable');
      }
      Map<String, dynamic> farmerRecords = {};
      for (var record in data) {
        if (kDebugMode) {
          print("Farmer: ${record.fields['FarmerID']}");
        }
        farmerRecords[record.fields['FarmerID']] = record;
      }

      List<AirtableRecord> farmerData = [];
      if (farmerRecords.isNotEmpty) {
        for (var id in farmerRecords.keys) {
          farmerData.add(farmerRecords[id]);
        }
      }

      List<Farmer> farmers =
          farmerData.map((record) => Farmer.fromAirtable(record)).toList();
      return Data<List<Farmer>>.success(farmers);
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print("Airtable Exception: ${e.message}");
      }
      return Data<List<Farmer>>.failure("Airtable Error: ${e.message}");
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return Data<List<Farmer>>.failure(
          "An error occurred while fetching farmers");
    }
  }

  // Function to save farmers data locally
  Future<Data> saveFarmers(List<Farmer> farmers, String groupId) async {
    try {
      await storage.saveEntityUnits(
        kGroupDataKey,
        groupId, // Unique ID for the group
        farmers, // The entity object (not used directly, but for clarity)
      );
      // Verify storage
      Data<List<Farmer>> storedFarmers =
          await fetchLocalFarmers(group: groupId);
      if (kDebugMode) {
        print('Stored ${storedFarmers.data?.length ?? 0} farmers');
      }
      return Data.success(storedFarmers);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving farmers: $e');
      }
      return Data.failure("Failed to save farmers locally");
    }
  }

  // Function to fetch groups data locally
  Future<Data<List<Farmer>>> fetchLocalFarmers({required String group}) async {
    try {
      final List<Farmer> storedFarmers = storage.fetchEntityUnits(
        kFarmerDataKey,
        group,
      );
      if (kDebugMode) {
        print('Raw stored data: $storedFarmers');
      }

      if (storedFarmers.isEmpty) {
        if (kDebugMode) {
          print('No local farmers found');
        }
        return Data<List<Farmer>>.failure("No Local farmers found");
      }

      if (kDebugMode) {
        print('Fetched ${storedFarmers.length} local farmers');
      }
      return Data<List<Farmer>>.success(storedFarmers);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local farmers: $e');
      }
      return Data.failure('Error fetching local farmers: $e');
    }
  }
}
