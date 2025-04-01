class User {
  final String id;
  final String parishes;
  final String name;
  final String email;
  final String branch;

  User({
    required this.name,
    required this.id,
    required this.parishes,
    required this.email,
    required this.branch,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['ID'] ?? "",
      name: json['ID'] != null
          ? json['ID'].split(" | ").last.split(" -- ").first
          : "",
      email: json['Email'] ?? "",
      branch: json['ID'] != null
          ? json['ID'].split(" | ").last.split(" -- ").last
          : "",
      parishes: json['Parishes IDs'] ?? "No assigned parishes",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Email': email,
      'Parishes IDs': parishes,
      'Branch': branch,
    };
  }
}
