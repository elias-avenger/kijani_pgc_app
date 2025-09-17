import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';

import '../models/farmer.dart';
import '../models/return_data.dart';
import '../services/airtable_services.dart';
import '../services/getx_storage.dart';

class FarmerRepository {
  final StorageService storage = StorageService();

  // Function to fetch farmers from Airtable
  Future<Data<List<Farmer>>> fetchFarmers(String groupId) async {
    try {
      String filter = 'AND(Farmer, GroupID = "${groupId.trim()}")';

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
        print('Fetched: ${data.length}');
      }
      Map<String, dynamic> farmerRecords = {};
      for (var record in data) {
        if (record.fields['FarmerID'] != null) {
          String id = record.fields['FarmerID'];
          String phone = record.fields['Farmer Phone Number'][0] ?? "";
          Map<String, dynamic> farmerRecord = {
            "FarmerID": id,
            "Farmer Phone Number": phone
          };
          if (!farmerRecords.containsKey(id)) {
            farmerRecords.addAll({id: farmerRecord});
            if (kDebugMode) {
              print('Farmer Record: $farmerRecord');
            }
          }
        }
      }

      if (kDebugMode) {
        print("Records: $farmerRecords");
      }

      List<Map<String, dynamic>> farmerData = [];
      if (farmerRecords.isNotEmpty) {
        for (var id in farmerRecords.keys) {
          if (!farmerData.contains(farmerRecords[id])) {
            farmerData.add(farmerRecords[id]);
          }
        }
        if (kDebugMode) {
          print('Group farmers: $farmerData');
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
        kFarmerDataKey,
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

  // Function to save farmers data locally
  Future<Data> updateFarmerData(Farmer farmer, String groupId) async {
    try {
      List<Farmer> farmers = await storage.fetchEntityUnits(
        kFarmerDataKey,
        groupId, // Unique ID for the group
      );
      for (Farmer farmerData in farmers) {
        if (farmerData.id == farmer.id) {
          farmers[farmers.indexOf(farmerData)] = farmer;
          break;
        }
      }
      await storage.saveEntityUnits(kFarmerDataKey, groupId, farmers);
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
      var storedFarmers = await storage.fetchEntityUnits(
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
      List<Farmer> farmers = [];
      if (farmers.runtimeType == storedFarmers.runtimeType) {
        farmers = storedFarmers;
      } else {
        List farmersData = storedFarmers;
        farmers = farmersData.map((farmer) => Farmer.fromJson(farmer)).toList();
      }

      if (kDebugMode) {
        print('Fetched ${farmers.length} local farmers');
      }
      return Data<List<Farmer>>.success(farmers);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local farmers: $e');
      }
      return Data.failure('Error fetching local farmers: $e');
    }
  }

  Future<int> getNumFarmerGardens(String farmerId) async {
    if (kDebugMode) {
      print("Farmer ID: $farmerId, Num Gardens: ?");
    }
    var farmerGardens = storage.fetchEntityUnits(
      kGardenDataKey,
      farmerId,
    );
    return farmerGardens == null ? 0 : farmerGardens.length;
  }
}
