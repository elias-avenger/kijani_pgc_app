import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future<bool> storeData({
    required String key,
    required Map<String, dynamic> data,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var stored = await prefs.setString(key, jsonEncode(data));
    return stored;
  }

  Future<Map<String, dynamic>> getData({required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userDateString = prefs.getString(key);
    Map<String, dynamic> data =
        userDateString != null ? Map.from(jsonDecode(userDateString)) : {};
    return data;
  }

  Future<String> removeUnSyncedData({
    required String type,
    required String key,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = await getData(key: type);
    var removed = await data.remove(key);
    if (removed != null) {
      data.isNotEmpty
          ? await prefs.setString(type, jsonEncode(data))
          : prefs.remove(type);
      return 'removed';
    } else {
      return "failed";
    }
  }

  Future<bool> removeEverything() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
//set bool

  Future<bool> setBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  Future<bool> getBool(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }
  //set string

  Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }
  //get string

  Future<String> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  Future<bool> removeItem(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
