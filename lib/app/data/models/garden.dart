import 'package:kijani_pmc_app/app/data/models/planting_update.dart';

class Garden {
  final String id;
  final bool isBoundary;
  final String center;
  final String polygon;
  final String initialPlantingDate;
  final int received;
  final int planted;
  final int surviving;
  final int replaced;
  final List<PlantingUpdate> updates;

  Garden({
    required this.id,
    required this.isBoundary,
    required this.center,
    required this.polygon,
    required this.initialPlantingDate,
    this.received = 0,
    this.planted = 0,
    this.surviving = 0,
    this.replaced = 0,
    required this.updates,
  });

  factory Garden.fromJson(Map<String, dynamic> json) {
    print('PARSING GARDEN DATA::: $json');
    return Garden(
      id: json['ID'] ?? 'No ID',
      isBoundary: _getBoolFromJson(json, 'Boundary Planting'),
      center: _getStringFromJson(json, 'Center Point'),
      polygon: _getStringFromJson(json, 'Polygon GeoJSON'),
      initialPlantingDate: _getStringFromJson(json, 'Initial planting date'),
      received: json['Received Seedlings'] ?? 0,
      planted: json['Planted Trees'] ?? 0,
      surviving: json['Surviving Trees'] ?? 0,
      replaced: json['Replaced Trees'] ?? 0,
      updates: _getUpdatesFromJson(json, 'Updates'),
    );
  }

  // Helper method to safely extract string values
  static String _getStringFromJson(Map<String, dynamic> json, String key) {
    var value = json[key];
    if (value != null) {
      if (value is List && value.isNotEmpty) {
        return value[0].toString();
      } else if (value is String) {
        return value;
      }
    }
    return 'Not available';
  }

  // Helper method to safely extract boolean values
  static bool _getBoolFromJson(Map<String, dynamic> json, String key) {
    var value = json[key];
    if (value != null) {
      if (value is bool) {
        return value;
      } else if (value is String) {
        return value.toLowerCase() == 'yes' || value.toLowerCase() == 'true';
      }
    }
    return false;
  }

  // Helper method to extract a list of PlantingUpdate from JSON
  static List<PlantingUpdate> _getUpdatesFromJson(
      Map<String, dynamic> json, String key) {
    if (json.containsKey(key) && json[key] is List) {
      return (json[key] as List)
          .map((updateJson) => PlantingUpdate.fromJson(updateJson))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Boundary Planting': isBoundary ? 'Yes' : 'No',
      'Center Point': center,
      'Polygon GeoJSON': polygon,
      'Initial planting date': initialPlantingDate,
      'Received Seedlings': received,
      'Planted Trees': planted,
      'Surviving Trees': surviving,
      'Replaced Trees': replaced,
      'Updates': updates
          .map((update) => update.toJson())
          .toList(), // Convert updates to JSON
    };
  }
}
