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
        'Farmers'
      ];

      List<AirtableRecord> data = await uGGardensBase
          .fetchRecordsWithFilter("Groups", filter, fields: fields);
      if (kDebugMode) {
        print(filter);
      }
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

      List<Map<String, dynamic>> groupRecords = [];
      for (var record in data) {
        if(record.fields['ID'] != null){
          String id = record.fields['ID'];
          String name = record.fields['Group Name'];
          String gardens = record.fields['Group Gardens'] ?? "";
          String season = record.fields['Season'];
          List farmers = record.fields['Farmers'] ?? [];
          farmers.remove(null);
          Map<String, dynamic> groupRecord = {
            "recordID": record.id,
            "ID": id,
            "Group Name": name,
            "Group Gardens": gardens,
            "Season": season,
            "Farmers": farmers.toSet().toList(),
          };
          if(!groupRecords.contains(groupRecord)){
            groupRecords.add(groupRecord);
          }
        }
      }

      List<Group> groups =
          groupRecords.map((record) => Group.fromAirtable(record)).toSet().toList();
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

  // Function to save groups data locally
  Future<Data> saveGroups(List<Group> groups, String parishId) async {
    try {
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
      final List<Group> storedGroups = storage.fetchEntityUnits(
        kGroupDataKey,
        parish,
      );
      if (kDebugMode) {
        print('Raw stored data: $storedGroups');
      }

      if (storedGroups.isEmpty) {
        if (kDebugMode) {
          print('No local groups found');
        }
        return Data<List<Group>>.failure("No Local Groups found");
      }

      if (kDebugMode) {
        print('Fetched ${storedGroups.length} local groups');
        print('First Group: ${storedGroups[0].name}');
      }
      return Data<List<Group>>.success(storedGroups);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local groups: $e');
      }
      return Data.failure('Error fetching local groups: $e');
    }
  }
}
