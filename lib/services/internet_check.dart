import 'dart:io';

class InternetCheck {
  Future<bool> isAirtableConnected() async {
    try {
      final result = await InternetAddress.lookup('airtable.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<bool> isAWSConnected() async {
    try {
      final result = await InternetAddress.lookup('aws.amazon.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
