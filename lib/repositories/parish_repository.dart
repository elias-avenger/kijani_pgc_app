import 'package:flutter/foundation.dart';
import 'package:kijani_pgc_app/models/parish.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/services/getx_storage.dart';

class ParishRepository {
  final StorageService storage = StorageService();

  Future<Data<List<Parish>>> setParishes(List<String> parishIds) async {
    if (parishIds.isNotEmpty) {
      List<Parish> parishes = [];
      for (String parishId in parishIds) {
        parishes.add(
          Parish(
            id: parishId.split(' | ')[0],
            name: parishId.split(' | ')[1],
          ),
        );
      }
      return Data<List<Parish>>.success(parishes);
    } else {
      return Data<List<Parish>>.failure("No parish Ids provided");
    }
  }

  // // Function to fetch parishes from Airtable
  // Future<Data<List<Parish>>> fetchParishes(List<String> parishCodes) async {
  //   if (kDebugMode) {
  //     print('Fetching parishes with codes: ${parishCodes.length}');
  //   }
  //   List<String> repeatedCodes = <String>[];
  //   //find repeated codes
  //   for (String code in parishCodes) {
  //     if (parishCodes.where((element) => element == code).length > 1) {
  //       repeatedCodes.add(code);
  //     }
  //   }
  //
  //   print(repeatedCodes);
  //   try {
  //     if (parishCodes.isEmpty) {
  //       print('No parish codes provided, returning empty list');
  //       return Data<List<Parish>>.failure("No parish codes provided");
  //     }
  //     String filter = 'AND('
  //         'OR(${parishCodes.map<String>((code) => '{Parish} = "${code.trim()}"').join(', ')}), '
  //         '{Status} = "Active"'
  //         ')';
  //
  //     List<String> fields = <String>[
  //       'ID',
  //       'Parish',
  //       'Parish Name',
  //       'GroupIDs',
  //       'PC'
  //     ];
  //
  //     List<AirtableRecord> data = await uGGardensBase
  //         .fetchRecordsWithFilter("Parishes", filter, fields: fields);
  //
  //     if (data.isEmpty) {
  //       print('No records found for the provided parish codes');
  //       return Data<List<Parish>>.failure(
  //           "No records found for the provided parish codes");
  //     }
  //
  //     if (kDebugMode) {
  //       print('Fetched ${data.length} records from Airtable');
  //     }
  //
  //     List<Parish> parishes =
  //         data.map((record) => Parish.fromAirtable(record)).toList();
  //     return Data<List<Parish>>.success(parishes);
  //   } on AirtableException catch (e) {
  //     if (kDebugMode) {
  //       print("Airtable Exception: ${e.message}");
  //     }
  //     return Data<List<Parish>>.failure("Airtable Error: ${e.message}");
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Exception: $e");
  //     }
  //     return Data<List<Parish>>.failure(
  //         "An error occurred while fetching parishes");
  //   }
  // }

  // Function to save parishes data locally
  Future<Data> saveParishes(List<Parish> parishes) async {
    try {
      for (var parish in parishes) {
        if (kDebugMode) {
          print('Saving Parish: ${parish.name}, ID: ${parish.id}');
        }
        await storage.saveEntity(
            kParishDataKey,
            parish.id, // Unique ID for the parish
            parish, // The entity object (not used directly, but for clarity)
            parish.toJson // The JSON conversion function
            );
      }

      // Verify storage
      Data<List<Parish>> storedParishes = await fetchLocalParishes();
      if (kDebugMode) {
        print('Stored ${storedParishes.data?.length ?? 0} parishes');
      }
      return Data.success(storedParishes);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving parishes: $e');
      }
      return Data.failure("Failed to save parishes locally");
    }
  }

  // Function to fetch parishes data locally
  Future<Data<List<Parish>>> fetchLocalParishes() async {
    try {
      final Map<String, dynamic> storedData = storage.fetchAllEntities(
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
        return Data<List<Parish>>.failure("No Local Parishes found");
      }

      // Convert Map values to List
      final List<Parish> parishes = storedData.values.toList().cast<Parish>();
      if (kDebugMode) {
        print('Fetched ${parishes.length} local parishes');
      }
      return Data<List<Parish>>.success(parishes);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local parishes: $e');
      }
      return Data.failure('Error fetching local parishes: $e');
    }
  }
}
