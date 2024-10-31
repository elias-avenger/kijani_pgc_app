import 'package:get/get.dart';

class UserdataProvider extends GetxController {
  var reports = 0.obs;

  //function to save reports
  Future<void> saveReports(List<dynamic> reports) async {
    print(reports);
  }
}
