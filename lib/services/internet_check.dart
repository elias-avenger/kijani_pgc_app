import 'dart:io';

class InternetCheck {
  Future getAirtableConMessage() async {
    // Simple check to see if we have internet
    try {
      final result = await InternetAddress.lookup('airtable.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return 'connected';
      }
    } on SocketException catch (_) {
      return 'not connected';
    }
  }

  Future getAWSConMessage() async {
    // Simple check to see if we have internet
    try {
      final result = await InternetAddress.lookup('aws.amazon.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return 'connected';
      }
    } on SocketException catch (_) {
      return 'not connected';
    }
  }
}
