import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:kijani_pmc_app/models/report.dart';
import 'package:kijani_pmc_app/services/airtable_services.dart';
import 'package:kijani_pmc_app/services/aws.dart';
import 'package:kijani_pmc_app/services/http_airtable.dart';
import 'package:kijani_pmc_app/services/internet_check.dart';
import 'package:kijani_pmc_app/services/local_storage.dart';

// Custom exceptions
class NoInternetException implements Exception {
  final String message;
  NoInternetException(this.message);
}

class PhotoUploadException implements Exception {
  final String message;
  PhotoUploadException(this.message);
}

class AirtableSubmissionException implements Exception {
  final String message;
  AirtableSubmissionException(this.message);
}

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
  Future<bool> submitDailyReport(DailyReport data) async {
    if (kDebugMode) {
      print('Submitting daily report...');
    }
    // Check internet connection
    bool isConnected = await internetCheck.isAirtableConnected();
    if (!isConnected) {
      throw NoInternetException('No internet connection available');
    }

    // Handle photos (can be empty)
    List<String> uploadedPhotos = [];
    if (data.images.isNotEmpty) {
      uploadedPhotos = await awsService.uploadPhotos(data.images);
      if (uploadedPhotos.isEmpty) {
        throw PhotoUploadException('Failed to upload any photos');
      }
    }

    // Convert uploaded photos URLs to a comma-separated string
    String photosString = uploadedPhotos.join(", ");
    if (kDebugMode) {
      print('Uploaded photos: $photosString');
    }

    try {
      // Prepare data for Airtable
      Map<String, dynamic> dataToSubmit = {
        "Plantation Growth Coordinators Name": data.userID,
        "Parish Visited": data.parish,
        "Activity carried out (multiple select)": data.activities,
        "3.   Provide more details about the activity and any general feedback":
            data.details,
        "Photo Urls": photosString,
        "5.  Next days activities": data.nextActivities,
      };

      // Submit to Airtable
      AirtableRecord record = await currentGardensBase.createRecord(
        kPGCReportTable,
        dataToSubmit,
      );

      // Verify successful submission
      if (record.id.isEmpty) {
        throw AirtableSubmissionException('Failed to create Airtable record');
      }

      if (kDebugMode) {
        print('Report submitted successfully with ID: ${record.id}');
      }
      return true;
    } on AirtableException catch (e) {
      throw AirtableSubmissionException('Airtable error: ${e.message}');
    } catch (e) {
      throw AirtableSubmissionException(
          'Unexpected error during submission: $e');
    }
  }
}
