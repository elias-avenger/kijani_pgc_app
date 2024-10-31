import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/modules/pmc/controllers/pmc_controller.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';
import 'package:kijani_pmc_app/global/services/aws_service.dart';
import 'package:kijani_pmc_app/global/services/network_services.dart';
import 'package:kijani_pmc_app/global/services/storage_service.dart';

class ReportsController extends GetxController {
  final PmcController pmcController = Get.put(PmcController());
  final LocalStorage myPrefs = LocalStorage();
  final AWSService awsAccess = AWSService();
  final NetworkServices internetCheck = NetworkServices();
  var unSyncedReports = 0.obs;

  @override
  void onInit() {
    countUnSyncedReports();
    super.onInit();
  }

  Future<void> submitReport({
    required Map<String, dynamic> reportData,
  }) async {
    Map<String, dynamic> dataToSubmit = Map.from(reportData);

    // Upload images to AWS
    if (reportData['Garden challenges photos'] != null) {
      Map<String, dynamic> photos = reportData['Garden challenges photos'];
      int numPhotos = photos.length;
      Map<String, dynamic> uploaded = await awsAccess.uploadPhotosMap(
        photosData: photos,
        numPhotos: numPhotos,
      );

      if (uploaded['msg'] == "success") {
        Map<String, dynamic> photosUrls = uploaded['data'];
        String photosString = photosUrls.values.join(', ');
        dataToSubmit['Garden challenges photos'] = photosString;
      } else {
        bool isFailedStored = await storeFailedReport(data: reportData);
        isFailedStored
            ? Get.snackbar('Stored Locally', 'Report stored locally')
            : Get.snackbar('Failed', 'Failed to store locally');
        return;
      }
    }

    // Submit data to Airtable
    if (await internetCheck.checkAirtableConnection()) {
      try {
        AirtableRecord response = await currentGardenBase.createRecord(
          'PMC Reports',
          dataToSubmit,
        );
        if (response.id != null) {
          await pmcController.fetchReports();
          Get.back();
          Get.snackbar(
            'Success',
            'Report submitted successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }
      } on AirtableException catch (e) {
        if (kDebugMode) print("Data to Submit: $dataToSubmit");
        bool isStoredLocally = await storeFailedReport(data: reportData);
        if (isStoredLocally) {
          Get.back();
          Get.snackbar('Stored Locally', 'Report stored locally');
        } else {
          Get.snackbar('Failed', 'Failed to store locally');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to submit report');
      }
    } else {
      Get.snackbar('Error', 'No internet connection');
      bool isStoredLocally = await storeFailedReport(data: reportData);
      if (isStoredLocally) {
        Get.back();
        Get.snackbar('Stored Locally', 'Report stored locally');
      } else {
        Get.snackbar('Failed', 'Failed to store locally');
      }
    }
  }

  Future<bool> storeFailedReport({required data}) async {
    Map<String, dynamic> storedReports =
        await myPrefs.getData(key: 'failedReports');
    int num = 0;
    if (storedReports.isNotEmpty) {
      num = int.parse(storedReports.keys.last.split('-').last);
    }
    storedReports['report-${num + 1}'] = data;
    return myPrefs.storeData(key: 'failedReports', data: storedReports);
  }

  void countUnSyncedReports() async {
    Map<String, dynamic> reportsData =
        await myPrefs.getData(key: 'failedReports');
    unSyncedReports.value = reportsData.length;
  }

  Future<void> uploadUnSyncedReports() async {
    Map<String, dynamic> reportsData =
        await myPrefs.getData(key: 'failedReports');
    bool awsAccessMsg = await internetCheck.checkAwsConnection();
    bool airtableAccessMsg = await internetCheck.checkAirtableConnection();

    if (!awsAccessMsg || !airtableAccessMsg) {
      Get.snackbar(
        "Unable to Sync",
        "Please check your internet connection",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    while (awsAccessMsg && airtableAccessMsg && reportsData.isNotEmpty) {
      String firstKey = reportsData.keys.first;
      Map<String, dynamic> targetData = reportsData[firstKey];
      Map<String, dynamic> dataToSubmit = Map.from(targetData);

      // Upload images to AWS
      if (targetData['Garden challenges photos'] != null) {
        Map<String, dynamic> photos = targetData['Garden challenges photos'];
        int numPhotos = photos.length;
        Map<String, dynamic> uploaded = await awsAccess.uploadPhotosMap(
          photosData: photos,
          numPhotos: numPhotos,
        );
        if (uploaded['msg'] == "success") {
          Map<String, dynamic> photosUrls = uploaded['data'];
          String photosString = photosUrls.values.join(', ');
          dataToSubmit['Garden challenges photos'] = photosString;
        }

        // Submit data to Airtable
        try {
          AirtableRecord response = await currentGardenBase.createRecord(
            'PMC Reports',
            dataToSubmit,
          );
          if (response.id != null) {
            await myPrefs.removeUnSyncedData(
              type: 'failedReports',
              key: firstKey,
            );
          }
        } on AirtableException catch (e) {
          Get.snackbar('Error', 'Failed to submit report');
        } catch (e) {
          Get.snackbar('Error', 'Failed to submit report');
        }
      }
      reportsData = await myPrefs.getData(key: 'failedReports');
      awsAccessMsg = await internetCheck.checkAwsConnection();
      airtableAccessMsg = await internetCheck.checkAirtableConnection();
    }
    countUnSyncedReports();
  }
}
