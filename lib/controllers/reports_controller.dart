import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/services/aws.dart';
import 'package:kijani_pgc_app/services/http_airtable.dart';
import 'package:kijani_pgc_app/services/internet_check.dart';

import '../services/local_storage.dart';

class ReportsController extends GetxController {
  HttpAirtable airtableAccess = HttpAirtable();
  LocalStorage myPrefs = LocalStorage();
  AWSService awsAccess = AWSService();
  InternetCheck internetCheck = InternetCheck();
  var unSyncedReports = 0.obs;

  @override
  void onInit() {
    countUnSyncedReports();
    super.onInit();
  }

  Future<String> submitReport({
    required Map<String, dynamic> reportData,
  }) async {
    //prepare data to submit to airtable
    Map<String, dynamic> dataToSubmit = reportData;
    //upload images to aws
    if (reportData['Garden challenges photos'] != null) {
      Map<String, dynamic> photos = reportData['Garden challenges photos'];
      int numPhotos = photos.length;
      Map<String, dynamic> uploaded = await awsAccess.uploadPhotosMap(
          photosData: photos, numPhotos: numPhotos);
      if (uploaded['msg'] == "success") {
        //convert uploaded photos urls to a comma separated string
        Map<String, dynamic> photosUrls = uploaded['data'];
        String photosString = "";
        for (String url in photosUrls.keys) {
          photosString += url == photosUrls.keys.last
              ? photosUrls[url]
              : "${photosUrls[url]}, ";
        }
        dataToSubmit['Garden challenges photos'] = photosString;
      } else {
        return await storeFailedReport(data: reportData)
            ? "${uploaded['msg']}. Stored!"
            : "${uploaded['msg']}. Failed to store!";
      }
    }
    // submit data
    if (await internetCheck.isAirtableConnected() == "connected") {
      Map<String, dynamic> response = await airtableAccess.createRecord(
        data: dataToSubmit,
        baseId: 'appoW7X8Lz3bIKpEE',
        table: 'PMC Reports',
      );
      if (response.keys.first == 'success') {
        return response['success'];
      } else {
        if (kDebugMode) print("Data to Submit: $dataToSubmit");
        return await storeFailedReport(data: reportData)
            ? "${response['failed']}. Stored!"
            : "${response['failed']}. Failed to store!";
      }
    } else {
      return await storeFailedReport(data: reportData)
          ? "No internet. Stored!"
          : "No internet. Failed to store!";
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
    bool awsAccessMsg = await internetCheck.isAWSConnected();
    bool airtableAccessMsg = await internetCheck.isAirtableConnected();

    //show snackBar if not connected to internet
    if (awsAccessMsg != "connected" || airtableAccessMsg != "connected") {
      Get.snackbar(
        "Unable to Sync",
        "Please check your internet connection",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    while (awsAccessMsg == "connected" &&
        airtableAccessMsg == "connected" &&
        reportsData.isNotEmpty) {
      String firstKey = reportsData.keys.first;
      Map<String, dynamic> targetData = reportsData[firstKey];
      Map<String, dynamic> dataToSubmit = targetData;
      //upload images to aws
      if (targetData['Garden challenges photos'] != null) {
        Map<String, dynamic> photos = targetData['Garden challenges photos'];
        int numPhotos = photos.length;
        Map<String, dynamic> uploaded = await awsAccess.uploadPhotosMap(
            photosData: photos, numPhotos: numPhotos);
        if (uploaded['msg'] == "success") {
          //convert uploaded photos urls to a comma separated string
          Map<String, dynamic> photosUrls = uploaded['data'];
          String photosString = "";
          for (String url in photosUrls.keys) {
            photosString += url == photosUrls.keys.last
                ? photosUrls[url]
                : "${photosUrls[url]}, ";
          }
          dataToSubmit['Garden challenges photos'] = photosString;
        }

        // submit data
        Map<String, dynamic> response = await airtableAccess.createRecord(
          data: dataToSubmit,
          baseId: 'appoW7X8Lz3bIKpEE',
          table: 'PMC Reports',
        );
        if (response.keys.first == 'success') {
          String removed = await myPrefs.removeUnSyncedData(
            type: 'failedReports',
            key: firstKey,
          );
          if (kDebugMode) {
            print("Data removed: $removed");
          }
        }
      }
      reportsData = await myPrefs.getData(key: 'failedReports');
      awsAccessMsg = await internetCheck.isAWSConnected();
      airtableAccessMsg = await internetCheck.isAirtableConnected();
    }
    countUnSyncedReports();
  }
}
