import 'dart:convert'; // Needed for JSON conversion

import 'package:airtable_crud/airtable_plugin.dart';

class Farmer {
  final String id;
  final String name;
  final String phone;

  Farmer({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory Farmer.fromAirtable(AirtableRecord record) {
    final data = record.fields;
    return Farmer(
      id: data['FarmerID'].split("-")[0] as String? ??
          '', // Add null coalescing
      name: data['FarmerID'].split("-")[1] as String? ?? '',
      phone: data['Farmer Phone Number'] as String? ?? '',
    );
  }

  factory Farmer.fromJson(Map<String, dynamic> data) {
    return Farmer(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  // Example usage:
  String toJsonString() => json.encode(toJson());
  static Farmer fromJsonString(String jsonString) =>
      Farmer.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
