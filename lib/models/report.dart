import 'package:kijani_pgc_app/models/photo.dart';

class DailyReport {
  final String userID;
  final String parish;
  final List<String> activities;
  final String? otherActivities;
  final String details;
  final List<Photo> images;
  final String nextActivities;
  final String? otherNextActivities;
  final String date;

  DailyReport({
    required this.userID,
    required this.parish,
    required this.activities,
    this.otherActivities,
    required this.details,
    required this.images,
    required this.nextActivities,
    this.otherNextActivities,
    required this.date,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      userID: json['PGC'] as String? ?? 'Unknown User',
      parish: json['Parish'] as String? ?? 'Unknown Parish',
      activities: (json['Activities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      otherActivities: json['Other activities'] as String?,
      details: json['Activity details'] as String? ?? 'No details provided',
      images: (json['Photo Urls'] as List<dynamic>?)
              ?.map((e) => Photo.fromPath(e.toString()))
              .toList() ??
          [],
      nextActivities: json['Next activities'] as String? ?? 'No activities',
      otherNextActivities: json['Other next activities'] as String?,
      date: json['Date'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PGC': userID,
      'Parish': parish,
      'Activities': activities,
      if (otherActivities != null && otherActivities!.isNotEmpty)
        'Other activities': otherActivities,
      'Activity details': details,
      'Photo Urls': images.map((photo) => photo.path).toList(),
      'Next activities': nextActivities,
      if (otherNextActivities != null && otherNextActivities!.isNotEmpty)
        'Other next activities': otherNextActivities,
      'Date': date,
    };
  }
}
