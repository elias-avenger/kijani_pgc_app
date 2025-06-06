import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:kijani_pmc_app/models/report.dart';
import 'package:kijani_pmc_app/models/return_data.dart';
import 'package:kijani_pmc_app/services/airtable_services.dart';
import 'package:kijani_pmc_app/services/aws.dart';
import 'package:kijani_pmc_app/services/getx_storage.dart';
import 'package:kijani_pmc_app/services/http_airtable.dart';
import 'package:kijani_pmc_app/services/internet_check.dart';

class ReportRepository {
  // Dependencies
  final HttpAirtable airtableAccess = HttpAirtable();
  final StorageService myPrefs = StorageService();
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

  /// Submits a daily report to Airtable, saving locally if submission fails.
  Future<Data<AirtableRecord>> submitDailyReport(DailyReport data) async {
    // Check internet connection
    bool isConnected = await internetCheck.isAirtableConnected();
    if (kDebugMode) {
      print('Internet connection status: $isConnected');
    }

    if (!isConnected) {
      if (kDebugMode) {
        print('No internet, saving report locally');
      }
      Data<String> saveResult = await saveReport(data);
      return saveResult.status
          ? Data.failure("No internet, report saved locally")
          : Data.failure("No internet and failed to save locally");
    }

    String photosString = "";
    if (data.images.isNotEmpty) {
      final uploadedPhotos = await awsService.uploadPhotos(data.images);
      if (!uploadedPhotos.status) {
        if (kDebugMode) {
          print('Photo upload failed: ${uploadedPhotos.message}');
        }
        final saveResult = await saveReport(data);
        return saveResult.status
            ? Data.failure("Photo upload failed, report saved locally")
            : Data.failure("Photo upload failed and failed to save locally");
      }
      photosString = uploadedPhotos.data!.join(',');
    }

    try {
      // Prepare data for Airtable
      final dataToSubmit = {
        "Plantation Growth Coordinator": data.userID.trim(),
        "Parish Visited": data.parish.trim(),
        "Activities": data.activities,
        "Photo Urls": photosString,
        "Description": data.details,
        "Next days activities": data.nextActivities.join(", "),
        "Created Date": data.date,
      };

      // Submit to Airtable
      final record = await currentGardensBase.createRecord(
        kPGCReportTable,
        dataToSubmit,
      );
      return Data.success(record);
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print('Airtable Exception: ${e.message}, Details: ${e.details}');
      }
      final saveResult = await saveReport(data);
      return saveResult.status
          ? Data.failure("Airtable error, report saved locally: ${e.message}")
          : Data.failure(
              "Airtable error and failed to save locally: ${e.message}");
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      final saveResult = await saveReport(data);
      return saveResult.status
          ? Data.failure("Submission error, report saved locally: $e")
          : Data.failure("Submission error and failed to save locally: $e");
    }
  }

  /// Saves a report locally using StorageService.
  Future<Data<String>> saveReport(DailyReport report) async {
    try {
      // Generate a unique key using timestamp to avoid collisions
      final uniqueKey =
          '${report.date}_${report.userID}_${DateTime.now().millisecondsSinceEpoch}';
      if (kDebugMode) {
        print('Saving report locally with key: $uniqueKey');
      }

      await myPrefs.saveEntity(
        kUnsyncedReportsKey,
        uniqueKey,
        report,
        report.toJson,
      );

      if (kDebugMode) {
        print('Report saved locally: ${report.toJson()}');
      }
      return Data.success(uniqueKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving report locally: $e');
      }
      return Data.failure('Failed to save report locally: $e');
    }
  }

  /// Syncs locally stored reports with Airtable.
  Future<Data<List<AirtableRecord>>> syncReports() async {
    try {
      // Check internet connection
      bool isConnected = await internetCheck.isAirtableConnected();
      if (!isConnected) {
        if (kDebugMode) {
          print('No internet for sync');
        }
        return Data.failure('No internet connection for syncing reports');
      }

      // Fetch all local reports
      final storedData = myPrefs.fetchAllEntities(
        kUnsyncedReportsKey,
        (data) => DailyReport.fromJson(data),
      );

      if (storedData.isEmpty) {
        if (kDebugMode) {
          print('No local reports to sync');
        }
        return Data.success([]);
      }

      final reports = storedData.values.toList().cast<DailyReport>();
      if (kDebugMode) {
        print('Found ${reports.length} local reports to sync');
      }

      final syncedRecords = <AirtableRecord>[];
      final failedReports = <String, DailyReport>{};

      // Sync each report
      for (final entry in storedData.entries) {
        final key = entry.key;
        final report = entry.value as DailyReport;
        final result = await submitDailyReport(report);
        if (result.status) {
          syncedRecords.add(result.data!);
          // Remove successfully synced report
          final deleted = await myPrefs.deleteEntity(kUnsyncedReportsKey, key);
          if (deleted) {
            if (kDebugMode) {
              print('Synced and removed report: $key');
            }
          } else {
            if (kDebugMode) {
              print('Failed to delete synced report: $key');
            }
          }
        } else {
          failedReports[key] = report;
          if (kDebugMode) {
            print('Failed to sync report ($key): ${result.message}');
          }
        }
      }

      if (failedReports.isNotEmpty) {
        return Data.success(syncedRecords);
      }
      return Data.success(syncedRecords);
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing reports: $e');
      }
      return Data.failure('Failed to sync reports: $e');
    }
  }

  //function to fetch locally saved reports
  Future<Data<List<DailyReport>>> fetchLocalReports() async {
    try {
      final storedData = myPrefs.fetchAllEntities(
        kUnsyncedReportsKey,
        (data) => DailyReport.fromJson(data),
      );

      if (storedData.isEmpty) {
        if (kDebugMode) {
          print('No local reports found');
        }
        return Data.success([]); // Return empty list instead of failure
      }

      final reports = storedData.values.toList().cast<DailyReport>();
      if (kDebugMode) {
        print('Fetched ${reports.length} local reports');
      }
      return Data.success(reports);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local reports: $e');
      }
      return Data.failure("Failed to fetch local reports: $e");
    }
  }
}
