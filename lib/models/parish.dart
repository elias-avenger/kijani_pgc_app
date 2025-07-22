import 'dart:convert'; // Needed for JSON conversion

import 'package:airtable_crud/airtable_plugin.dart';

class Parish {
  final String id;
  final String name;

  Parish({
    required this.id,
    required this.name,
  });

  factory Parish.fromAirtable(AirtableRecord record) {
    final data = record.fields;
    return Parish(
      id: data['Parish'] as String? ?? '', // Add null coalescing
      name: data['Parish Name'] as String? ?? '',
    );
  }

  factory Parish.fromJson(Map<String, dynamic> data) {
    return Parish(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Example usage:
  String toJsonString() => json.encode(toJson());
  static Parish fromJsonString(String jsonString) =>
      Parish.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
