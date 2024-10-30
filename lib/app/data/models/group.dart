import 'package:kijani_pmc_app/app/data/models/farmer.dart';

class Group {
  final String id;
  final String name;
  final String coordinates;
  final int potted;
  final int pricked;
  final int sorted;
  final int distributed;
  final String lastVisit;
  final int numVisits;
  final List<Farmer> farmers;

  Group({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.potted,
    required this.pricked,
    required this.sorted,
    required this.distributed,
    required this.lastVisit,
    required this.numVisits,
    required this.farmers,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing Group: $json');
      return Group(
        id: json['ID'] ?? json['id'],
        name: _getStringFromJson(json, 'Group Name'), // Adjust key if necessary
        coordinates: _getStringFromJson(json, 'Coordinates'),
        potted: _getIntFromJson(json, 'Total Potted 2024'),
        pricked: _getIntFromJson(json, 'Total Pricked 2024'),
        sorted: _getIntFromJson(json, 'Total Sorted 2024'),
        distributed: _getIntFromJson(json, 'Total Distributed 2024'),
        lastVisit: _getStringFromJson(json, 'Last Visted 2024'),
        numVisits: _getIntFromJson(json, 'Num_Visits 2024'),
        farmers: (json['farmers'] as List<dynamic>?)
                ?.map((farmerJson) => Farmer.fromJson(farmerJson))
                .toList() ??
            [],
      );
    } catch (e) {
      print('Error parsing Group JSON: $json, Error: $e');
      return Group(
          id: 'error',
          name: 'Parsing error',
          coordinates: '',
          potted: 0,
          pricked: 0,
          sorted: 0,
          distributed: 0,
          lastVisit: '',
          numVisits: 0,
          farmers: []);
    }
  }

  static String _getStringFromJson(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) {
      var value = json[key];
      if (value is String) return value;
      if (value is List && value.isNotEmpty) return value[0].toString();
      print('Unexpected value type for key "$key": $value');
    }
    return 'Not available';
  }

  static int _getIntFromJson(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) {
      var value = json[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is List && value.isNotEmpty) {
        return int.tryParse(value[0].toString()) ?? 0;
      }
      print('Unexpected value type for key "$key": $value');
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Group Name': name,
      'Coordinates': coordinates,
      'Total Potted 2024': potted,
      'Total Pricked 2024': pricked,
      'Total Sorted 2024': sorted,
      'Total Distributed 2024': distributed,
      'Last Visted 2024': lastVisit,
      'Num_Visits 2024': numVisits,
      'farmers': farmers
          .map((farmer) => farmer.toJson())
          .toList(), // Correctly serialize nested objects
    };
  }
}
