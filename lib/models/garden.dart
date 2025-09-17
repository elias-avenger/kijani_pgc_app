import 'dart:convert'; // Needed for JSON conversion

import 'package:airtable_crud/airtable_plugin.dart';

class Garden {
  final String recordID;
  final String id;
  final String centerPoint;
  final String polygon;
  final int treesPlanted;
  final int treesSurviving;
  final List gardenPhotos;
  final List speciesData;

  Garden({
    required this.recordID,
    required this.id,
    required this.centerPoint,
    required this.polygon,
    required this.treesPlanted,
    required this.treesSurviving,
    required this.gardenPhotos,
    required this.speciesData,
  });

  factory Garden.fromAirtable(AirtableRecord record) {
    final data = record.fields;
    // Getting and converting photos data
    String photos = data['Garden Photos'].toString();
    List<String> gPhotos = photos.split(',');

    // Getting and converting species data
    String species = data['Species'] as String;
    List<String> speciesList = species.split(', ');

    // Getting and converting planted and surviving data
    String planted = data['Planted by species'] as String;
    List<int> plantedBySpecies = planted.split(', ').map(int.parse).toList();

    // Getting and converting planted and surviving data
    String surviving = data['Surviving by species'] as String;
    List<int> survivingBySpecies =
        surviving.split(', ').map(int.parse).toList();

    // Combining the data into a list of maps
    List updatesData = [];
    for (int i = 0; i < speciesList.length; i++) {
      Map<String, dynamic> speciesData = {
        'species': speciesList[i],
        'planted': plantedBySpecies[i],
        'surviving': survivingBySpecies[i],
      };
      updatesData.add(speciesData);
    }

    return Garden(
      recordID: record.id, // Add null safety
      id: data['ID'] as String? ?? '', // Add null coalescing
      centerPoint: data['Center Point'].toString() as String? ?? '',
      polygon: data['Polygon GeoJSON'].toString() as String? ?? '',
      treesPlanted: data['Total Trees Planted'] as int,
      treesSurviving: data['Total Trees Surviving'] as int,
      gardenPhotos: gPhotos as List? ?? [],
      speciesData: updatesData as List? ?? [],
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
      gardenPhotos: data['Garden Photos'] as List,
      speciesData: data['Species Data'] as List? ?? [],
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
      'Garden Photos': gardenPhotos,
      'Species Data': speciesData,
    };
  }

  // Example usage:
  String toJsonString() => json.encode(toJson());
  static Garden fromJsonString(String jsonString) =>
      Garden.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
