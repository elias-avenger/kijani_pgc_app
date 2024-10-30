import 'package:kijani_pmc_app/app/data/models/group.dart';

class Parish {
  final String id;
  final String parishId;
  final String name;
  final List<Group> groups;
  final String pcID;
  final String pcName;
  final String pcEmail;
  final String status;

  Parish({
    required this.id,
    required this.parishId,
    required this.name,
    required this.groups,
    required this.pcID,
    required this.pcName,
    required this.pcEmail,
    required this.status,
  });

  factory Parish.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing Parish: $json'); // Log raw JSON data
      return Parish(
        id: json['ID'] ?? 'no ID',
        parishId: json['Parish'] ?? json['parishId'],
        name: json['Parish Name'] ?? json['name'],
        groups: (json['groups'] as List<dynamic>?)
                ?.map((groupJson) => Group.fromJson(groupJson))
                .toList() ??
            [],
        pcID: json['PC'] ?? json['pcID'],
        pcName: json['PC-Name'] ?? json['pcName'],
        pcEmail: json['PC-Email'] ?? json['pcEmail'],
        status: json['Status'] ?? json['status'],
      );
    } catch (e) {
      print('Error parsing Parish JSON: $json, Error: $e');
      throw e;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parishId': parishId,
      'name': name,
      'groups': groups
          .map((group) => group.toJson())
          .toList(), // Correctly serialize nested objects
      'pcID': pcID,
      'pcName': pcName,
      'pcEmail': pcEmail,
      'status': status,
    };
  }
}
