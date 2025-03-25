class ParishModel {
  final String id;
  final String name;
  final String branch;
  final String coordinator;

  ParishModel({
    required this.id,
    required this.name,
    required this.branch,
    required this.coordinator,
  });

  factory ParishModel.fromJson(Map<String, dynamic> json) {
    return ParishModel(
      id: json['id'],
      name: json['name'],
      branch: json['branch'],
      coordinator: json['coordinator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'branch': branch,
      'coordinator': coordinator,
    };
  }
}
