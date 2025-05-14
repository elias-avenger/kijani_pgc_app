import 'dart:convert'; // Needed for JSON conversion

import 'package:airtable_crud/airtable_plugin.dart';

class Parish {
  // final String recordID;
  final String id;
  // final String assignmentID;
  final String name;
  // final String pc;
  // final List<String> groupIDs;

  Parish({
    // required this.recordID,
    required this.id,
    // required this.assignmentID,
    required this.name,
    // required this.pc,
    // required this.groupIDs,
  });

  factory Parish.fromAirtable(AirtableRecord record) {
    final data = record.fields;
    return Parish(
      // recordID: record.id, // Add null safety
      id: data['Parish'] as String? ?? '', // Add null coalescing
      // assignmentID: data['ID'] as String? ?? '',
      name: data['Parish Name'] as String? ?? '',
      // pc: data['PC'] as String? ?? '',
      // groupIDs: (data['GroupIDs'] as String?)?.split(',') ?? [],
    );
  }

  factory Parish.fromJson(Map<String, dynamic> data) {
    return Parish(
      // recordID: data['recordID'] as String? ?? '', // Add null safety
      id: data['id'] as String? ?? '',
      // assignmentID: data['assignmentID'] as String? ?? '',
      name: data['name'] as String? ?? '',
      // pc: data['pc'] as String? ?? '',
      // groupIDs: data['groupIDs'] != null
      //     ? List<String>.from(data['groupIDs'] as List<dynamic>)
      //     : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'recordID': recordID,
      'id': id,
      // 'assignmentID': assignmentID,
      'name': name,
      // 'pc': pc,
      // 'groupIDs': groupIDs,
    };
  }

  // Example usage:
  String toJsonString() => json.encode(toJson());
  static Parish fromJsonString(String jsonString) =>
      Parish.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
