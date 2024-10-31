import 'package:flutter/foundation.dart';
import 'package:kijani_pmc_app/global/enums/keys.dart';
import 'package:kijani_pmc_app/global/services/network_services.dart';
import 'package:s3_storage/io.dart';
import 'package:s3_storage/s3_storage.dart';

class AWSService {
  final kAWSUrl =
      'https://${DateTime.now().year}-app-uploads.s3.amazonaws.com/';
  Future<String> uploadToS3(String imgPath, String imgName) async {
    //Print.text("Storage Uploading: ${file.path}");
    final s3 = S3Storage(
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
      return 'IMAGE UPLOADED';
    } catch (e) {
      return Future.value("ERROR UPLOADING IMAGE: $e");
    }
  }

  Future<Map<String, dynamic>> uploadPhotosMap({
    required Map<String, dynamic> photosData,
    required int numPhotos,
  }) async {
    Map<String, dynamic> response = {};
    Map<String, dynamic> photosUrls = {};
    bool isConnected = await NetworkServices().checkAwsConnection();
    if (isConnected) {
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
