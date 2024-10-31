//use dart.io to check for internet connection
import 'dart:io';

class NetworkServices {
  Future<bool> checkAirtableConnection() async {
    try {
      final result = await InternetAddress.lookup('airtable.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<bool> checkAwsConnection() async {
    bool isConnected = false;
    // Simple check to see if we have internet
    try {
      final result = await InternetAddress.lookup('aws.amazon.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
    }
    return isConnected;
  }
}
