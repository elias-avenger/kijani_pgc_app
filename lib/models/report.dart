import 'package:kijani_pgc_app/models/photo.dart';

class DailyReport {
  final String userID;
  final String parish;
  final List<String> activities;
  final String details;
  final List<Photo> images; // Made final for consistency
  final List<String> nextActivities;
  final String date;

  DailyReport({
    required this.userID,
    required this.parish,
    required this.activities,
    required this.details,
    required this.images,
    required this.nextActivities,
    required this.date,
  });

  /// Creates a [DailyReport] instance from a JSON map with safe type handling.
  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      userID: json['userID'] as String? ?? 'Unknown User',
      parish: json['parish'] as String? ?? 'Unknown Parish',
      activities: json['activities'] != null
          ? (json['activities'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
          : [],
      details: json['details'] as String? ?? 'No details provided',
      images: json['images'] != null
          ? (json['images'] as List<dynamic>)
              .map((e) => Photo.fromPath(e.toString()))
              .toList()
          : [],
      nextActivities: json['nextActivities'] != null
          ? (json['nextActivities'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
          : [],
      date: json['date'] as String? ?? DateTime.now().toString(),
    );
  }

  /// Converts the [DailyReport] instance back to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'parish': parish,
      'activities': activities,
      'details': details,
      'images': images.map((photo) => photo.path).toList(),
      'nextActivities': nextActivities,
      'date': date,
    };
  }
}
