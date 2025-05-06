import 'package:kijani_pgc_app/models/photo.dart';

class DailyReport {
  final String userID;
  final String parish;
  final List<String> activities;
  final String details;
  final List<Photo> images; // Made final for consistency
  final String nextActivities;
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
      userID: json['PGC'] as String? ?? 'Unknown User',
      parish: json['Parish'] as String? ?? 'Unknown Parish',
      activities: json['Activities'] != null
          ? (json['Activities'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
          : [],
      details: json['Activity details'] as String? ?? 'No details provided',
      images: json['Photo Urls'] != null
          ? (json['Photo Urls'] as List<dynamic>)
              .map((e) => Photo.fromPath(e.toString()))
              .toList()
          : [],
      nextActivities: json['Next activities'] as String? ?? 'No activities',
      date: json['Date'] as String? ?? DateTime.now().toString(),
    );
  }

  /// Converts the [DailyReport] instance back to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'PGC': userID,
      'Parish': parish,
      'Activities': activities,
      'Activity details': details,
      'Photo Urls': images.map((photo) => photo.path).toList(),
      'Next activities': nextActivities,
      'Date': date,
    };
  }
}
