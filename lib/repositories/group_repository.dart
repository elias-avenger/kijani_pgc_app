import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:kijani_pgc_app/models/group.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/services/airtable_services.dart';
import 'package:kijani_pgc_app/services/getx_storage.dart';

class GroupRepository {
  final StorageService storage = StorageService();

  // Function to fetch groups from Airtable
  Future<Data<List<Group>>> fetchGroups(String parishId) async {
    try {
      String filter = '{ParishID} = "${parishId.trim()}"';

      List<String> fields = <String>[
        'ID',
        'Group Name',
        'Group Gardens',
        'Season',
      ];

      List<AirtableRecord> data = await uGGardensBase
          .fetchRecordsWithFilter("Groups", filter, fields: fields);

      if (data.isEmpty) {
        if (kDebugMode) {
          print('No records found for the provided parish');
        }
        return Data<List<Group>>.failure(
            "No records found for the provided parish");
      }

      if (kDebugMode) {
        print('Fetched ${data.length} records from Airtable');
      }

      List<Group> groups =
          data.map((record) => Group.fromAirtable(record)).toList();
      return Data<List<Group>>.success(groups);
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print("Airtable Exception: ${e.message}");
      }
      return Data<List<Group>>.failure("Airtable Error: ${e.message}");
    } catch (e) {
      if (kDebugMode) {
        print("Exception: $e");
      }
      return Data<List<Group>>.failure(
          "An error occurred while fetching groups");
    }
  }

  // Future<Data<List<Group>>> fetchGroups(List<String> groupIDs) async {
  //   if (kDebugMode) {
  //     print('Fetching groups with IDs: ${groupIDs.length}');
  //   }
  //   List<String> repeatedIDs = <String>[];
  //   //find repeated ids
  //   for (String id in groupIDs) {
  //     if (groupIDs.where((element) => element == id).length > 1) {
  //       repeatedIDs.add(id);
  //     }
  //   }
  //
  //   if (kDebugMode) {
  //     print(repeatedIDs);
  //   }
  //   try {
  //     if (groupIDs.isEmpty) {
  //       if (kDebugMode) {
  //         print('No group IDs provided, returning empty list');
  //       }
  //       return Data<List<Group>>.failure("No group IDs provided");
  //     }
  //     String filter =
  //         'OR(${groupIDs.map<String>((code) => '{ParishID} = "${code.trim()}"').join(', ')})';
  //
  //     List<String> fields = <String>[
  //       'ID',
  //       'Group Name',
  //       'Group Gardens',
  //       'Season',
  //     ];
  //
  //     List<AirtableRecord> data = await uGGardensBase
  //         .fetchRecordsWithFilter("Groups", filter, fields: fields);
  //
  //     if (data.isEmpty) {
  //       if (kDebugMode) {
  //         print('No records found for the provided groups');
  //       }
  //       return Data<List<Group>>.failure(
  //           "No records found for the provided groups");
  //     }
  //
  //     if (kDebugMode) {
  //       print('Fetched ${data.length} records from Airtable');
  //     }
  //
  //     List<Group> groups =
  //         data.map((record) => Group.fromAirtable(record)).toList();
  //     return Data<List<Group>>.success(groups);
  //   } on AirtableException catch (e) {
  //     if (kDebugMode) {
  //       print("Airtable Exception: ${e.message}");
  //     }
  //     return Data<List<Group>>.failure("Airtable Error: ${e.message}");
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Exception: $e");
  //     }
  //     return Data<List<Group>>.failure(
  //         "An error occurred while fetching parishes");
  //   }
  // }

  // Function to save groups data locally
  Future<Data> saveGroups(List<Group> groups, String parishId) async {
    try {
      // for (var group in groups) {
      //   if (kDebugMode) {
      //     print('Saving Group: ${group.name}, ID: ${group.id}');
      //   }
      //   await storage.saveEntity(
      //       kGroupDataKey,
      //       group.id, // Unique ID for the group
      //       group, // The entity object (not used directly, but for clarity)
      //       group.toJson // The JSON conversion function
      //       );
      // }
      await storage.saveEntityUnits(
        kGroupDataKey,
        parishId, // Unique ID for the group
        groups, // The entity object (not used directly, but for clarity)
      );
      // Verify storage
      Data<List<Group>> storedGroups = await fetchLocalGroups(parish: parishId);
      if (kDebugMode) {
        print('Stored ${storedGroups.data?.length ?? 0} groups');
      }
      return Data.success(storedGroups);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving groups: $e');
      }
      return Data.failure("Failed to save groups locally");
    }
  }

  // Function to fetch groups data locally
  Future<Data<List<Group>>> fetchLocalGroups({required String parish}) async {
    try {
      final Map<String, dynamic> storedData = storage.fetchEntityUnits(
        kGroupDataKey,
        parish,
      );
      if (kDebugMode) {
        print('Raw stored data: $storedData');
      }

      if (storedData.isEmpty) {
        if (kDebugMode) {
          print('No local groups found');
        }
        return Data<List<Group>>.failure("No Local Parishes found");
      }

      // Convert Map values to List
      final List<Group> groups = storedData.values.toList().cast<Group>();
      if (kDebugMode) {
        print('Fetched ${groups.length} local groups');
      }
      return Data<List<Group>>.success(groups);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local groups: $e');
      }
      return Data.failure('Error fetching local groups: $e');
    }
  }
}
