import 'package:flutter/foundation.dart';
import 'package:kijani_pgc_app/models/photo.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/services/internet_check.dart';
import 'package:s3_storage/io.dart';
import 'package:s3_storage/s3_storage.dart';

import '../utilities/keys.dart';

class AWSService {
  String kAWSUrl =
      'https://${DateTime.now().year}-app-uploads.s3.amazonaws.com/';

  Future<Data> uploadToS3(String imgPath, String imgName) async {
    //Print.text("Storage Uploading: ${file.path}");
    S3Storage s3 = S3Storage(
      endPoint: 's3.amazonaws.com',
      accessKey: awsAccessKey,
      secretKey: awsSecretKey,
      signingType: SigningType.V4,
      region: "us-east-1",
    );
    try {
      String filename = imgName;
      String eTag = await s3.fPutObject(
        '${DateTime.now().year}-app-uploads',
        filename,
        imgPath,
      );
      if (kDebugMode) {
        print(eTag);
      }
      return Data.success("IMAGE UPLOADED");
    } catch (e) {
      return Data.failure("IMAGE UPLOAD FAILED: $e");
    }
  }

  Future<Data<List<String>>> uploadPhotos(List<Photo> photos) async {
    // List to store URLs of successfully uploaded photos
    List<String> uploadedUrls = [];

    // Check internet connection
    bool isAwsConnected = await InternetCheck().isAWSConnected();
    if (!isAwsConnected) {
      if (kDebugMode) {
        print('No internet connection - no photos uploaded');
      }
      return Data.failure("No internet Connection");
    }

    // Create upload futures
    List<Future<void>> uploadFutures = [];

    for (Photo photo in photos) {
      String photoName = photo.name.isNotEmpty
          ? "${photo.name.split(".").first}-pgc-report"
          : "${photo.name.split(".").first}-pgc-report";

      uploadFutures.add(
        uploadToS3(photo.path, photoName).then((result) {
          if (result.status) {
            // If upload is successful, add the URL to the list
            uploadedUrls.add(kAWSUrl + photoName);
          }
        }),
      );
    }

    // Wait for all uploads to complete
    await Future.wait(uploadFutures);

    if (kDebugMode) {
      print('Uploaded ${uploadedUrls.length} photos: $uploadedUrls');
    }

    return Data.success(uploadedUrls);
  }

  Future<Map<String, dynamic>> uploadPhotosMap({
    required Map<String, dynamic> photosData,
    required int numPhotos,
  }) async {
    Map<String, dynamic> response = {};
    Map<String, dynamic> photosUrls = {};
    bool connMsg = await InternetCheck().isAWSConnected();
    if (connMsg) {
      int imagesUploaded = 0;
      for (String image in photosData.keys) {
        String imgPath = photosData[image]['imagePath'];
        String imgName = photosData[image]['imageName'];
        var s3Response = await uploadToS3(imgPath, imgName);
        if (s3Response == 'IMAGE UPLOADED') {
          imagesUploaded++;
          photosUrls[image] = kAWSUrl + imgName;
        } else {
          response['msg'] = "Failed to upload all photos!";
          break;
        }
      }
      if (imagesUploaded == numPhotos) {
        response['msg'] = 'success';
        response['data'] = photosUrls;
      } else {
        response['msg'] =
            "IMAGES UPLOAD FAILED:\n images -- $numPhotos\n uploaded -- $imagesUploaded";
      }
    } else {
      response['msg'] = 'No internet';
    }
    if (kDebugMode) {
      print(response);
    }
    return response;
  }
}
