import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pmc_app/models/report.dart';
import 'package:kijani_pmc_app/services/airtable_services.dart';
import 'package:kijani_pmc_app/services/aws.dart';
import 'package:kijani_pmc_app/services/http_airtable.dart';
import 'package:kijani_pmc_app/services/internet_check.dart';
import 'package:kijani_pmc_app/services/local_storage.dart';

class ReportRepository {
  // Dependencies
  final HttpAirtable airtableAccess = HttpAirtable();
  final LocalStorage myPrefs = LocalStorage();
  final AWSService awsAccess = AWSService();
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

  // Submit a report to Airtable or store locally if failed
  Future<bool> submitDailyReport(DailyReport data) async {
    // Handle photo uploads if present
    if (data.images.isNotEmpty) {
      final uploadResult = await _uploadPhotos(data.images);
      if (uploadResult['msg'] != 'success') {
        await _handleFailedSubmission(data, uploadResult['msg']);
      }
    }

    // Check internet and submit or store
    if (await internetCheck.isAirtableConnected()) {
      try {
        AirtableRecord response = await currentGardensBase.createRecord(
          kPGCReportTable,
          data.toJson(),
        );
        if (kDebugMode) {
          print(response.fields);
        }
        return true;
      } on AirtableException catch (e) {
        if (kDebugMode) {
          print("ERROR CREATING REPORT IN AIRTABLE: $e");
        }
        return false;
      } catch (e) {
        if (kDebugMode) {
          print("ERROR CREATING REPORT INTO AIRTABLE: $e");
        }
        return false;
      }
    } else {
      return false;
    }
  }

  // Store a failed report locally
  Future<bool> storeFailedReport({required DailyReport data}) async {
    final storedReports = await myPrefs.getData(key: 'failedReports');
    final nextIndex = storedReports.isEmpty
        ? 1
        : int.parse(storedReports.keys.last.split('-').last) + 1;
    storedReports['report-$nextIndex'] = data;
    return myPrefs.storeData(key: 'failedReports', data: storedReports);
  }

  // Count unsynced reports
  Future<void> countUnSyncedReports() async {
    final reportsData = await myPrefs.getData(key: 'failedReports');
    unSyncedReports.value = reportsData.length;
  }

  // Sync unsynced reports with Airtable
  Future<void> uploadUnSyncedReports() async {
    final awsAccessMsg = await internetCheck.isAWSConnected();
    final airtableAccessMsg = await internetCheck.isAirtableConnected();

    if (!awsAccessMsg || !airtableAccessMsg) {
      _showConnectionError();
      return;
    }

    var reportsData = await myPrefs.getData(key: 'failedReports');
    while (reportsData.isNotEmpty &&
        await internetCheck.isAWSConnected() &&
        await internetCheck.isAirtableConnected()) {
      final firstKey = reportsData.keys.first;
      final targetData = Map<String, dynamic>.from(reportsData[firstKey]);
      final dataToSubmit = await _prepareDataForSync(targetData);

      final response = await airtableAccess.createRecord(
        data: dataToSubmit,
        baseId: 'appoW7X8Lz3bIKpEE',
        table: 'PMC Reports',
      );

      if (response.keys.first == 'success') {
        await myPrefs.removeUnSyncedData(type: 'failedReports', key: firstKey);
        if (kDebugMode) print("Data removed: $firstKey");
      }

      reportsData = await myPrefs.getData(key: 'failedReports');
    }
    await countUnSyncedReports();
  }

  Future<Map<String, dynamic>> _uploadPhotos(List<XFile> photosData) async {
    Map<String, dynamic> photos = {};

    for (var photo in photosData) {
      String photoName = photo.name.isNotEmpty
          ? "${photo.name}-pgc-report"
          : DateTime.now().millisecondsSinceEpoch.toString();
      photos[photoName] = photo.path;
    }
    return await awsAccess.uploadPhotosMap(
      photosData: photos,
      numPhotos: photosData.length,
    );
  }

  // Helper: Convert uploaded photo URLs to a comma-separated string
  String _convertPhotosToString(Map<String, dynamic> photosUrls) {
    return photosUrls.values.join(", ");
  }

  // Helper: Handle failed submission by storing locally
  Future<String> _handleFailedSubmission(
      DailyReport data, String errorMsg) async {
    final stored = await storeFailedReport(data: data.toJson());
    return stored ? "$errorMsg. Stored!" : "$errorMsg. Failed to store!";
  }

  // Helper: Prepare data for syncing (handles photo uploads)
  Future<Map<String, dynamic>> _prepareDataForSync(
      Map<String, dynamic> targetData) async {
    final dataToSubmit = Map<String, dynamic>.from(targetData);
    if (targetData['Garden challenges photos'] != null) {
      final uploadResult =
          await _uploadPhotos(targetData['Garden challenges photos']);
      if (uploadResult['msg'] == 'success') {
        dataToSubmit['Garden challenges photos'] =
            _convertPhotosToString(uploadResult['data']);
      }
    }
    return dataToSubmit;
  }

  // Helper: Show connection error snackbar
  void _showConnectionError() {
    Get.snackbar(
      "Unable to Sync",
      "Please check your internet connection",
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }
}
