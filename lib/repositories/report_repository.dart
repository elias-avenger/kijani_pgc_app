import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
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
    required String reportKey,
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
      Data<String> saveResult = await saveReport(data, reportKey);
      return saveResult.status
          ? Data<AirtableRecord>.failure("No internet, report saved locally")
          : Data<AirtableRecord>.failure(
              "No internet and failed to save locally");
    }

    if (photoFields.isNotEmpty) {
      for (final photoField in photoFields) {
        final uploadedPhotos = await awsService.uploadPhotos(data[photoField]);
        if (!uploadedPhotos.status) {
          if (kDebugMode) {
            print('Photo upload failed: ${uploadedPhotos.message}');
          }
          final Data<String> saveResult = await saveReport(data, reportKey);
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
        kReportTables[reportKey],
        data,
      );
      return Data<AirtableRecord>.success(record);
    } on AirtableException catch (e) {
      if (kDebugMode) {
        print('Airtable Exception: ${e.message}, Details: ${e.details}');
      }
      final Data<String> saveResult = await saveReport(data, reportKey);
      return saveResult.status
          ? Data<AirtableRecord>.failure(
              "Airtable error, report saved locally: ${e.message}")
          : Data<AirtableRecord>.failure(
              "Airtable error and failed to save locally: ${e.message}");
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      final Data<String> saveResult = await saveReport(data, reportKey);
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
      if (kDebugMode) {
        print('Saving report locally with key: $key');
      }
      // Fetching available reports
      final storedReports = await fetchLocalReports(reportKey: key);
      if (!storedReports.status) {
        return Data<String>.failure(storedReports.toString());
      }
      List<Map<String, dynamic>> storedReportsList = storedReports.data ?? [];
      // Add a new report to the available ones
      storedReportsList.add(report);
      // Save the updated list
      await myPrefs.saveEntityUnits(
        kUnSyncedReportsKey,
        key,
        storedReportsList,
      );

      if (kDebugMode) {
        print('Report saved locally: $report');
      }
      return Data<String>.success(key);
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
      List<Map<String, dynamic>> storedData;
      Data<List<Map<String, dynamic>>> localDailyReports =
          await fetchLocalReports(reportKey: 'PGCReport');
      localDailyReports.status
          ? storedData = localDailyReports.data ?? []
          : storedData = [];
      // Fetch all local reports
      // final storedData = myPrefs.fetchAllEntities(
      //   kUnSyncedReportsKey,
      //   (data) => DailyReport.fromJson(data),
      // );

      if (storedData.isEmpty) {
        if (kDebugMode) {
          print('No local reports to sync');
        }
        return Data<List<AirtableRecord>>.success(<AirtableRecord>[]);
      }

      final reports = storedData.toList();
      if (kDebugMode) {
        print('Found ${reports.length} local reports to sync');
      }

      final List<AirtableRecord> syncedRecords = <AirtableRecord>[];
      final List<Map<String, dynamic>> failedReports = <Map<String, dynamic>>[];

      // Sync each report
      for (final report in reports) {
        String reportKey = 'PGCRepots';
        try {
          // Submit to Airtable
          final AirtableRecord record = await currentGardensBase.createRecord(
            kReportTables[reportKey],
            report,
          );
          syncedRecords.add(record);
          // Remove successfully synced report
          final deleted =
              await myPrefs.deleteEntity(kUnSyncedReportsKey, reportKey);
          if (deleted) {
            if (kDebugMode) {
              print('Synced and removed report: $reportKey');
            }
          } else {
            if (kDebugMode) {
              print('Failed to delete synced report: $reportKey');
            }
          }
          // return Data<AirtableRecord>.success(record);
        } on AirtableException catch (e) {
          if (kDebugMode) {
            print('Airtable Exception: ${e.message}, Details: ${e.details}');
          }
          failedReports.add(report);
          if (kDebugMode) {
            print('Failed to sync report ($reportKey): {result.message}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Unexpected error: $e');
          }
          failedReports.add(report);
          if (kDebugMode) {
            print('Failed to sync report ($reportKey): {result.message}');
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
  Future<Data<List<Map<String, dynamic>>>> fetchLocalReports(
      {required String reportKey}) async {
    try {
      final storedData =
          myPrefs.fetchEntityUnits(kUnSyncedReportsKey, reportKey);
      if (storedData == null || storedData.isEmpty) {
        if (kDebugMode) {
          print('No local reports found');
        }
        return Data<List<Map<String, dynamic>>>.success(
            []); // Return empty list instead of failure
      }

      if (kDebugMode) {
        print('Fetched ${storedData.length} local reports');
      }
      return Data<List<Map<String, dynamic>>>.success(storedData);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local reports: $e');
      }
      return Data<List<Map<String, dynamic>>>.failure(
          "Failed to fetch local reports: $e");
    }
  }
}
