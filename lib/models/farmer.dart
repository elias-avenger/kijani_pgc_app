import 'dart:convert'; // Needed for JSON conversion

class Farmer {
  final String id;
  final String name;
  final String phone;
  int numGardens = 0;

  Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.numGardens,
  });

  factory Farmer.fromAirtable(Map<String, dynamic> data) {
    //final data = record;
    return Farmer(
      id: data['FarmerID'].split("-")[0] as String? ??
          '', // Add null coalescing
      name: data['FarmerID'].split("-")[1] as String? ?? '',
      phone: data['Farmer Phone Number'] as String? ?? '',
      numGardens: 0,
    );
  }

  factory Farmer.fromJson(Map<String, dynamic> data) {
    return Farmer(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      numGardens: data['numGardens'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'numGardens': numGardens,
    };
  }

  // Example usage:
  String toJsonString() => json.encode(toJson());
  static Farmer fromJsonString(String jsonString) =>
      Farmer.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
