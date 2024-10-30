import 'package:kijani_pmc_app/app/data/models/garden.dart';

class Farmer {
  final String id;
  final String name;
  final String gender;
  final String phone;
  final bool onBoarded;
  final bool contract;
  final List<Garden> gardens;

  Farmer({
    required this.id,
    required this.name,
    required this.gender,
    required this.phone,
    required this.onBoarded,
    required this.contract,
    required this.gardens,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    print('PARSING Farmer:: $json');
    return Farmer(
      id: json['ID'] ?? 'No ID',
      name: _getName(json),
      gender: _getStringFromJson(json, 'Gender'),
      phone: _getStringFromJson(json, 'Phone Number'),
      onBoarded: json['Fully onboarded?'] == true ? true : false,
      contract: json['Contract signed?'] == true ? true : false,
      gardens: _getGardensFromJson(json),
    );
  }

  // Helper method to safely construct name
  static String _getName(Map<String, dynamic> json) {
    if (json.containsKey('First Name') && json.containsKey('Last Name')) {
      var firstName = json['First Name'] ?? '';
      var lastName = json['Last Name'] ?? '';
      return (firstName + ' ' + lastName).trim();
    } else if (json.containsKey('Name')) {
      return json['Name'] ?? 'Not available';
    }
    return 'Not available';
  }

  // Helper method to safely extract string values
  static String _getStringFromJson(Map<String, dynamic> json, String key) {
    var value = json[key];
    if (value != null && value is String) {
      return value;
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

  // Helper method to extract gardens from JSON
  static List<Garden> _getGardensFromJson(Map<String, dynamic> json) {
    if (json.containsKey('Gardens') && json['Gardens'] is List) {
      var gardens = json['Gardens'] as List;
      if (gardens.isNotEmpty && gardens.first is! String) {
        return gardens
            .map((gardenJson) =>
                Garden.fromJson(gardenJson as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  bool isNotListOfStrings(dynamic data) {
    // Check if the data is a List and all elements are Strings
    if (data is List) {
      return data.any((element) => element is! String);
    }
    // If not a list, return true
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Name':
          name, // Changed to 'Name' to reflect combined first and last names
      'Gender': gender,
      'Phone Number': phone,
      'Fully onboarded?': onBoarded,
      'Contract signed?': contract,
      'Gardens': gardens
          .map((garden) => garden.toJson())
          .toList(), // Properly serialize gardens
    };
  }
}
