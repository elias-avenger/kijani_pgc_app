import 'dart:convert'; // Needed for JSON conversion

import 'package:airtable_crud/airtable_plugin.dart';

class Group {
  final String recordID;
  final String id;
  final String name;
  final String season;
  final List<String> gardenIDs;
  final List farmerIDs;

  Group({
    required this.recordID,
    required this.id,
    required this.season,
    required this.name,
    required this.gardenIDs,
    required this.farmerIDs,
  });

  factory Group.fromAirtable(AirtableRecord record) {
    final data = record.fields;
    return Group(
      recordID: record.id, // Add null safety
      id: data['ID'] as String? ?? '', // Add null coalescing
      name: data['Group Name'] as String? ?? '',
      season: data['Season'] as String? ?? '',
      gardenIDs: (data['Group Gardens'] as String?)?.split(',') ?? [],
      farmerIDs: data['Farmers'] as List? ?? [],
    );
  }

  factory Group.fromJson(Map<String, dynamic> data) {
    return Group(
      recordID: data['recordID'] as String? ?? '', // Add null safety
      id: data['ID'] as String? ?? '',
      name: data['Group Name'] as String? ?? '',
      season: data['Season'] as String? ?? '',
      gardenIDs: data['Group Gardens'] != null
          ? List<String>.from(data['Group Gardens'] as List<dynamic>)
          : [],
      farmerIDs: data['Farmers'] != null
          ? List<String>.from(data['Farmers'] as List<dynamic>)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordID': recordID,
      'ID': id,
      'Group Name': name,
      'Season': season,
      'Group Gardens': gardenIDs,
      'Farmers': farmerIDs,
    };
  }

  // Example usage:
  String toJsonString() => json.encode(toJson());
  static Group fromJsonString(String jsonString) =>
      Group.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
