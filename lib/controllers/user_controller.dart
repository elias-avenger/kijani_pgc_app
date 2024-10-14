import 'package:get/get.dart';
import 'package:kijani_pmc_app/models/branch.dart';
import 'package:kijani_pmc_app/services/http_airtable.dart';

import '../services/local_storage.dart';

class UserController extends GetxController {
  // final String email;
  // final String code;
  HttpAirtable useAirtable = HttpAirtable();

  String myBase = "app9yul6FMnVUm7L4";
  String myTable = "Parishes";

  LocalStorage myPrefs = LocalStorage();

  var branchData = <String, dynamic>{}.obs;
  //var userType = " -- ".obs;
  Future<String> authenticate({
    required String email,
    required String code,
  }) async {
    Map<String, dynamic> data = await checkUser(
      email: email,
      code: code,
      baseId: myBase,
      table: myTable,
    );
    if (data['msg'] == 'Found') {
      final userBranch = Branch.getData(data['data']);

      branchData = RxMap(data['data']);
      var stored = await myPrefs.storeData(key: "userData", data: data['data']);
      if (stored) {
        return "Success";
      } else {
        return "Not Stored";
      }
    } else if (data['msg'] == 'Not Found') {
      return data['msg'];
    } else {
      return "Failure";
    }
  }

  Future<Map<String, dynamic>> checkUser({
    required String email,
    required String code,
    required String baseId,
    required String table,
  }) async {
    //String view = 'To MEL App';
    String filter = 'AND({PMC Email}="$email", {Branch-code}="$code")';
    // HttpAirtable airtable = HttpAirtable(
    //     apiKey: airtableAccessToken, baseId: myBase, tableName: myTable);
    Map data = await useAirtable.fetchDataWithFilter(
      filter: filter,
      baseId: baseId,
      table: table,
    );
    Map<String, dynamic>? userData;
    List parishes = [];
    if (data['records'].isEmpty) {
      return {"msg": "Not Found"};
    } else {
      for (var record in data['records']) {
        //print("Record Fields: ${record['fields']['ID']}");
        parishes.add(record['fields']['ID']);
        userData = {
          'branch': record['fields']['Branch'],
          'coordinator': record['fields']['PMC'],
          'parishes': parishes,
        };
      }
      return {"msg": "Found", "data": userData ?? {}};
    }
  }

  Future<Map<String, dynamic>> getBranchData() async {
    Map<String, dynamic> storedData = await myPrefs.getData(key: 'userData');
    branchData = RxMap(storedData);
    return storedData;
  }

  Future<bool> logout() {
    return myPrefs.removeEverything();
  }
}
