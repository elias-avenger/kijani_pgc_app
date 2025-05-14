import 'dart:convert'; // Needed for JSON conversion

import 'package:airtable_crud/airtable_plugin.dart';

class Group {
  final String recordID;
  final String id;
  final String name;
  final String season;
  final List<String> gardenIDs;

  Group({
    required this.recordID,
    required this.id,
    required this.season,
    required this.name,
    required this.gardenIDs,
  });

  factory Group.fromAirtable(AirtableRecord record) {
    final data = record.fields;
    return Group(
      recordID: record.id, // Add null safety
      id: data['ID'] as String? ?? '', // Add null coalescing
      name: data['Group Name'] as String? ?? '',
      season: data['Season'] as String? ?? '',
      gardenIDs: (data['Group Gardens'] as String?)?.split(',') ?? [],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordID': recordID,
      'ID': id,
      'Group Name': name,
      'Season': season,
      'Group Gardens': gardenIDs,
    };
  }

  // Example usage:
  String toJsonString() => json.encode(toJson());
  static Group fromJsonString(String jsonString) =>
      Group.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
