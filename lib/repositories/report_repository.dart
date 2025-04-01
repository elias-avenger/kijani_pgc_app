import 'package:image_picker/image_picker.dart';

class ReportRepository {
  static const List<String> activities = <String>[
    "Plantation Growth Garden Visits",
    "Nursery Hub Support",
    "HQ Assignment",
    "Central Nursery Assignment",
    "Acting Capacity Role",
    "Other assignment",
  ];

  //function to submit daily report
  Future<bool> submitDailyReport(Map<String, dynamic> data) async {
    // Simulate a network call
    await Future.delayed(const Duration(seconds: 5));
    print(data);
    return true;
  }
}
