import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:kijani_pmc_app/models/report.dart';
import 'package:kijani_pmc_app/models/return_data.dart';
import 'package:kijani_pmc_app/services/airtable_services.dart';
import 'package:kijani_pmc_app/services/aws.dart';
import 'package:kijani_pmc_app/services/http_airtable.dart';
import 'package:kijani_pmc_app/services/internet_check.dart';
import 'package:kijani_pmc_app/services/local_storage.dart';

class ReportRepository {
  // Dependencies
  final HttpAirtable airtableAccess = HttpAirtable();
  final LocalStorage myPrefs = LocalStorage();
  final AWSService awsService = AWSService();
  final InternetCheck internetCheck = InternetCheck();

  // Static list of activities
  static const List<String> activities = [
    "Plantation Growth Garden Visits",
    "Nursery Hub Support",
    "HQ Assignment",
    "Central Nursery Assignment",
    "Acting Capacity Role",
    "Other assignment",
  ];

  // Function to submit daily report
  Future<Data<AirtableRecord>> submitDailyReport(DailyReport data) async {
    if (kDebugMode) {
      print('Submitting daily report...');
    }
    // Check internet connection
    bool isConnected = await internetCheck.isAirtableConnected();
    if (!isConnected) {
      return Data.failure("No internet connection");
    }

    String photosString = "";

    if (data.images.isNotEmpty) {
      Data<List<String>> uploadedPhotos =
          await awsService.uploadPhotos(data.images);
      //convert list to string
      photosString = uploadedPhotos.data!.join(',');
      if (kDebugMode) {
        print('Uploaded photos: $photosString');
      }
      if (!uploadedPhotos.status) {
        if (kDebugMode) {
          print('Photo upload failed: ${uploadedPhotos.message}');
        }
      }
    }

    try {
      // Prepare data for Airtable
      Map<String, dynamic> dataToSubmit = {
        "Plantation Growth Coordinator": data.userID.trim(),
        "Parish Visited": data.parish.trim(),
        "Activities": data.activities,
        "Photo Urls": photosString,
        "Description": data.details,
        "Next days activities": data.nextActivities.join(", "),
      };
      // Submit to Airtable
      AirtableRecord record = await currentGardensBase.createRecord(
        kPGCReportTable,
        dataToSubmit,
      );
      return Data.success(record);
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print('Airtable Exception message: ${e.message}');
        print('Airtable Exception message Details: ${e.details}');
      }

      return Data.failure('Airtable error: ${e.message}');
    } catch (e) {
      return Data.failure('Unexpected error during submission: $e');
    }
  }
}
