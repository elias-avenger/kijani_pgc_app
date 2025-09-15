import 'dart:convert'; // Needed for JSON conversion

import 'package:airtable_crud/airtable_plugin.dart';

class Parish {
  final String id;
  final String name;
  int numGroups = 0;

  Parish({
    required this.id,
    required this.name,
    required this.numGroups,
  });

  factory Parish.fromAirtable(AirtableRecord record) {
    final data = record.fields;
    return Parish(
      id: data['Parish'] as String? ?? '', // Add null coalescing
      name: data['Parish Name'] as String? ?? '',
      numGroups: data['Number of Groups'] as int? ?? 0,
    );
  }

  factory Parish.fromJson(Map<String, dynamic> data) {
    return Parish(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      numGroups: data['numGroups'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'numGroups': numGroups,
    };
  }

  // Example usage:
  String toJsonString() => json.encode(toJson());
  static Parish fromJsonString(String jsonString) =>
      Parish.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
