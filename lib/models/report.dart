import 'package:kijani_pmc_app/models/photo.dart';

class DailyReport {
  final String userID;
  final String parish;
  final List<String> activities;
  final String details;
  List<Photo> images;
  final List<String> nextActivities;

  DailyReport({
    required this.userID,
    required this.parish,
    required this.activities,
    required this.details,
    required this.images,
    required this.nextActivities,
  });

  // Factory constructor to create an instance from JSON
  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      userID: json['pgc'] as String,
      parish: json['parish'] as String,
      activities: List<String>.from(json['activities'] as List),
      details: json['details'] as String,
      images: (json['images'] as List)
          .map<Photo>((image) => Photo.fromPath(image as String))
          .toList(),
      nextActivities: json['nextActivities'] as List<String>,
    );
  }

  // Method to convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'pgc': userID,
      'parish': parish,
      'activities': activities,
      'details': details,
      'images': images.map((photo) => photo.path).toList(), // List<String>
      'nextActivities': nextActivities,
    };
  }
}
