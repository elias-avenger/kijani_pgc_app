import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdate {
  //function to check for updates
  Future<void> checkUpdate() async {
    InAppUpdate.checkForUpdate().then((info) async {
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        try {
          InAppUpdate.completeFlexibleUpdate;
        } catch (e) {
          if (kDebugMode) {
            print(e.toString());
          }
        }
      }
    }).catchError((e) {
      if (kDebugMode) {
        print(e.tostring());
      }
    });
  }
}
