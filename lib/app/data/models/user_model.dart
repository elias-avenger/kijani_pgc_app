import 'package:kijani_pmc_app/global/enums/user_roles.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRoles role;
  final String branch;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.branch,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      branch: json['branch'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'branch': branch,
    };
  }
}
