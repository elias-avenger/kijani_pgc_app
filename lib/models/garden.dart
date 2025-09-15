import 'dart:convert'; // Needed for JSON conversion

import 'package:airtable_crud/airtable_plugin.dart';

class Garden {
  final String recordID;
  final String id;
  final String centerPoint;
  final String polygon;
  final int treesPlanted;
  final int treesSurviving;

  Garden({
    required this.recordID,
    required this.id,
    required this.centerPoint,
    required this.polygon,
    required this.treesPlanted,
    required this.treesSurviving,
  });

  factory Garden.fromAirtable(AirtableRecord record) {
    final data = record.fields;
    return Garden(
      recordID: record.id, // Add null safety
      id: data['ID'] as String? ?? '', // Add null coalescing
      centerPoint: data['Center Point'].toString() as String? ?? '',
      polygon: data['Polygon GeoJSON'].toString() as String? ?? '',
      treesPlanted: data['Total Trees Planted'] as int,
      treesSurviving: data['Total Trees Surviving'] as int,
    );
  }

  factory Garden.fromJson(Map<String, dynamic> data) {
    return Garden(
      recordID: data['recordID'], // Add null safety
      id: data['ID'] as String? ?? '', // Add null coalescing
      centerPoint: data['Center Point'] as String? ?? '',
      polygon: data['Polygon GeoJSON'] as String? ?? '',
      treesPlanted: data['Total Trees Planted'] as int,
      treesSurviving: data['Total Trees Surviving'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordID': recordID,
      'ID': id,
      'Center Point': centerPoint,
      'Polygon GeoJSON': polygon,
      'Total Trees Planted': treesPlanted,
      'Total Trees Surviving': treesSurviving,
    };
  }

  // Example usage:
  String toJsonString() => json.encode(toJson());
  static Garden fromJsonString(String jsonString) =>
      Garden.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
