import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:kijani_pgc_app/models/report.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/services/airtable_services.dart';
import 'package:kijani_pgc_app/services/aws.dart';
import 'package:kijani_pgc_app/services/getx_storage.dart';
import 'package:kijani_pgc_app/services/http_airtable.dart';
import 'package:kijani_pgc_app/services/internet_check.dart';

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
    "Other activities",
  ];

  Future<Data<AirtableRecord>> submitReport({
    required Map<String, dynamic> data,
    required String tableName,
    required List<String> photoFields,
  }) async {
    // Check internet connection
    bool isConnected = await internetCheck.isAirtableConnected();
    if (kDebugMode) {
      print('Internet connection status: $isConnected');
    }

    if (!isConnected) {
      if (kDebugMode) {
        print('No internet, saving report locally');
      }
      Data<String> saveResult = await saveReport(data, tableName);
      return saveResult.status
          ? Data<AirtableRecord>.failure("No internet, report saved locally")
          : Data<AirtableRecord>.failure(
              "No internet and failed to save locally");
    }

    String photosString = "";
    if (photoFields.isNotEmpty) {
      for (final photoField in photoFields) {
        final uploadedPhotos = await awsService.uploadPhotos(data[photoField]);
        if (!uploadedPhotos.status) {
          if (kDebugMode) {
            print('Photo upload failed: ${uploadedPhotos.message}');
          }
          final Data<String> saveResult = await saveReport(data, tableName);
          return saveResult.status
              ? Data<AirtableRecord>.failure(
                  "Photo upload failed, report saved locally")
              : Data<AirtableRecord>.failure(
                  "Photo upload failed and failed to save locally");
        }
        // Add photo URLs to the data
        data[photoField] = uploadedPhotos.data!.join(',');
      }
    }

    try {
      // Submit to Airtable
      final AirtableRecord record = await currentGardensBase.createRecord(
        tableName,
        data,
      );
      return Data<AirtableRecord>.success(record);
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print('Airtable Exception: ${e.message}, Details: ${e.details}');
      }
      final Data<String> saveResult = await saveReport(data, tableName);
      return saveResult.status
          ? Data<AirtableRecord>.failure(
              "Airtable error, report saved locally: ${e.message}")
          : Data<AirtableRecord>.failure(
              "Airtable error and failed to save locally: ${e.message}");
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      final Data<String> saveResult = await saveReport(data, tableName);
      return saveResult.status
          ? Data<AirtableRecord>.failure(
              "Submission error, report saved locally: $e")
          : Data<AirtableRecord>.failure(
              "Submission error and failed to save locally: $e");
    }
  }

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
      Data<String> saveResult = await saveDailyReport(data);
      return saveResult.status
          ? Data<AirtableRecord>.failure("No internet, report saved locally")
          : Data<AirtableRecord>.failure(
              "No internet and failed to save locally");
    }

    String photosString = "";
    if (data.images.isNotEmpty) {
      final uploadedPhotos = await awsService.uploadPhotos(data.images);
      if (!uploadedPhotos.status) {
        if (kDebugMode) {
          print('Photo upload failed: ${uploadedPhotos.message}');
        }
        final Data<String> saveResult = await saveDailyReport(data);
        return saveResult.status
            ? Data<AirtableRecord>.failure(
                "Photo upload failed, report saved locally")
            : Data<AirtableRecord>.failure(
                "Photo upload failed and failed to save locally");
      }
      photosString = uploadedPhotos.data!.join(',');
    }

    try {
      // Prepare data for Airtable
      final dataToSubmit = data.toJson();
      dataToSubmit['Photo Urls'] = photosString;

      // Submit to Airtable
      final AirtableRecord record = await currentGardensBase.createRecord(
        kPGCReportTable,
        dataToSubmit,
      );
      return Data<AirtableRecord>.success(record);
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print('Airtable Exception: ${e.message}, Details: ${e.details}');
      }
      final Data<String> saveResult = await saveDailyReport(data);
      return saveResult.status
          ? Data<AirtableRecord>.failure(
              "Airtable error, report saved locally: ${e.message}")
          : Data<AirtableRecord>.failure(
              "Airtable error and failed to save locally: ${e.message}");
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      final Data<String> saveResult = await saveDailyReport(data);
      return saveResult.status
          ? Data<AirtableRecord>.failure(
              "Submission error, report saved locally: $e")
          : Data<AirtableRecord>.failure(
              "Submission error and failed to save locally: $e");
    }
  }

  /// Saves a report locally using StorageService.
  Future<Data<String>> saveReport(
      Map<String, dynamic> report, String key) async {
    try {
      // Generate a unique key using timestamp to avoid collisions
      final String uniqueKey = key;
      if (kDebugMode) {
        print('Saving report locally with key: $uniqueKey');
      }
      await myPrefs.saveEntityUnits(
        kUnSyncedReportsKey,
        uniqueKey,
        report,
      );

      if (kDebugMode) {
        print('Report saved locally: $report');
      }
      return Data<String>.success(uniqueKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving report locally: $e');
      }
      return Data<String>.failure('Failed to save report locally: $e');
    }
  }

  /// Saves a report locally using StorageService.
  Future<Data<String>> saveDailyReport(DailyReport report) async {
    try {
      // Generate a unique key using timestamp to avoid collisions
      final String uniqueKey =
          '${report.date}_${report.userID}_${DateTime.now().millisecondsSinceEpoch}';
      if (kDebugMode) {
        print('Saving report locally with key: $uniqueKey');
      }

      await myPrefs.saveEntity(
        kUnSyncedReportsKey,
        uniqueKey,
        report,
        report.toJson,
      );

      if (kDebugMode) {
        print('Report saved locally: ${report.toJson()}');
      }
      return Data<String>.success(uniqueKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving report locally: $e');
      }
      return Data<String>.failure('Failed to save report locally: $e');
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
        return Data<List<AirtableRecord>>.failure(
            'No internet connection for syncing reports');
      }

      // Fetch all local reports
      final storedData = myPrefs.fetchAllEntities(
        kUnSyncedReportsKey,
        (data) => DailyReport.fromJson(data),
      );

      if (storedData.isEmpty) {
        if (kDebugMode) {
          print('No local reports to sync');
        }
        return Data<List<AirtableRecord>>.success(<AirtableRecord>[]);
      }

      final reports = storedData.values.toList().cast<DailyReport>();
      if (kDebugMode) {
        print('Found ${reports.length} local reports to sync');
      }

      final List<AirtableRecord> syncedRecords = <AirtableRecord>[];
      final Map<String, DailyReport> failedReports = <String, DailyReport>{};

      // Sync each report
      for (final entry in storedData.entries) {
        final String key = entry.key;
        final DailyReport report = entry.value as DailyReport;
        final Data<AirtableRecord> result = await submitDailyReport(report);
        if (result.status) {
          syncedRecords.add(result.data!);
          // Remove successfully synced report
          final deleted = await myPrefs.deleteEntity(kUnSyncedReportsKey, key);
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
        return Data<List<AirtableRecord>>.success(syncedRecords);
      }
      return Data<List<AirtableRecord>>.success(syncedRecords);
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing reports: $e');
      }
      return Data<List<AirtableRecord>>.failure('Failed to sync reports: $e');
    }
  }

  //function to fetch locally saved reports
  Future<Data<List<DailyReport>>> fetchLocalReports() async {
    try {
      final storedData = myPrefs.fetchAllEntities(
        kUnSyncedReportsKey,
        (data) => DailyReport.fromJson(data),
      );

      if (storedData.isEmpty) {
        if (kDebugMode) {
          print('No local reports found');
        }
        return Data<List<DailyReport>>.success(
            <DailyReport>[]); // Return empty list instead of failure
      }

      final List<DailyReport> reports =
          storedData.values.toList().cast<DailyReport>();
      if (kDebugMode) {
        print('Fetched ${reports.length} local reports');
      }
      return Data<List<DailyReport>>.success(reports);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local reports: $e');
      }
      return Data<List<DailyReport>>.failure(
          "Failed to fetch local reports: $e");
    }
  }
}
