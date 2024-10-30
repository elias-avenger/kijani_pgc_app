import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/data/models/parish_model.dart';
import 'package:kijani_pmc_app/app/data/providers/parish_provider.dart';
import 'package:kijani_pmc_app/app/routes/routes.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';
import 'package:kijani_pmc_app/global/services/network_services.dart';
import 'package:kijani_pmc_app/global/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final LocalStorage storageService = LocalStorage();
  final ParishProvider parishProvider = ParishProvider();

  var isAuthenticated = false.obs;
  var userRole = ''.obs;
  var userData = <String, dynamic>{}.obs;
  var parishData = <Parish>[].obs;
  var isLoading = false.obs;
  var isUpdating = false.obs;
  var isButtonLoading = false.obs;

  Future<void> login(String email, String password) async {
    isButtonLoading.value = true; // Show "Checking user..."
    try {
      var bcFilter = 'AND({BC-Email}="$email", {Branch-code}="$password")';
      var melFilter = 'AND({MEL-Email}="$email", {Branch-code}="$password")';
      var pmcFilter = 'AND({PMC Email}="$email", {Branch-code}="$password")';

      // Attempt login for each role
      if (kDebugMode) {
        print('Attempting BC login');
      }
      var bc = await _attemptLogin(bcFilter, 'bc');
      if (bc != null) return;

      if (kDebugMode) {
        print('Attempting MEL login');
      }
      var mel = await _attemptLogin(melFilter, 'mel');
      if (mel != null) return;

      if (kDebugMode) {
        print('Attempting PMC login');
      }
      var pmc = await _attemptLogin(pmcFilter, 'pmc');
      if (pmc != null) return;

      // If no login was successful, show failure message
      Get.snackbar(
        'Login Failed',
        'Invalid email or code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isButtonLoading.value = false; // Hide "Checking user..."
    }
  }

  // Helper function to attempt login and handle the result
  Future<bool?> _attemptLogin(String filter, String role) async {
    if (kDebugMode) {
      print('Attempting login with filter: $filter');
    }
    var response = await nurseryBase.fetchRecordsWithFilter('parishes', filter,
        view: 'To BC App');
    if (kDebugMode) {
      print('Response: $response');
    }
    if (response.isNotEmpty) {
      isLoading.value = true; // Start loading when a match is found
      List<Parish> parishes =
          response.map((record) => Parish.fromJson(record.fields)).toList();
      await _handleSuccessfulLogin(
          role, Map<String, dynamic>.from(response.first.fields), parishes);
      isLoading.value = false; // Stop loading after successful login
      return true;
    }
    return null;
  }

  // Handle successful login, store user data, and parishes
  Future<void> _handleSuccessfulLogin(String role,
      Map<String, dynamic> userDataFromAirtable, List<Parish> parishes) async {
    userData.value = userDataFromAirtable;
    isAuthenticated.value = true;
    userRole.value = role;

    await storageService.storeData(key: 'user', data: userDataFromAirtable);
    await storageService.setBool('isAuthenticated', true);
    await storageService.setString('userRole', userRole.value);

    // Store fetched parishes into observable list
    parishData.value = parishes;

    // Fetch hierarchical data and save parishes to shared preferences
    await parishProvider.fetchParishes(parishes);
    await _saveParishesToSharedPreferences(parishes);

    Get.offAllNamed(_getRedirectRoute());
  }

  // Save parishes to shared preferences
  Future<void> _saveParishesToSharedPreferences(List<Parish> parishes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> parishJsonList = parishes.map((parish) {
      try {
        String jsonString = jsonEncode(parish.toJson());
        return jsonString;
      } catch (e) {
        return '{}'; // Default to empty if an error occurs
      }
    }).toList();
    await prefs.setStringList('parishes', parishJsonList);
  }

  // Load parishes from shared preferences
  Future<List<Parish>?> loadParishesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? parishJsonList = prefs.getStringList('parishes');
    if (parishJsonList != null) {
      return parishJsonList
          .map((parishJson) => Parish.fromJson(jsonDecode(parishJson)))
          .toList();
    }
    return null;
  }

  // Load authentication data from local storage on app startup
  Future<void> loadAuthData() async {
    try {
      isAuthenticated.value = await storageService.getBool('isAuthenticated');
      userRole.value = await storageService.getString('userRole');
      userData.value = await storageService.getData(key: 'user');

      if (isAuthenticated.value) {
        // First load cached parishes and redirect
        List<Parish>? loadedParishes =
            await loadParishesFromSharedPreferences();
        if (loadedParishes != null) {
          parishData.value = loadedParishes;
        }
        Get.offAllNamed(_getRedirectRoute());

        // Then refresh data
        //check if internet is conect
        if (await NetworkServices().checkAirtableConnection()) {
          String? email = userData['BC-Email'] ??
              userData['MEL-Email'] ??
              userData['PMC Email'];
          String? branchCode = userData['Branch-code'];
          if (email != null && branchCode != null) {
            isUpdating.value = true;
            try {
              await login(email, branchCode);
            } finally {
              isUpdating.value = false;
            }
          }
        }
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print("Error in loadAuthData: $e");
    }
  }

  // Logout to clear all storage and reset auth state
  Future<void> logout() async {
    if (isUpdating.value) {
      isUpdating.value = false;
    }
    isButtonLoading.value = false; // Reset button state
    await storageService.removeEverything();
    isAuthenticated.value = false;
    userRole.value = '';
    userData.clear();
    parishData.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('parishes');
    Get.offAllNamed('/login');
  }

  // Determine the route to redirect based on the user's role
  String _getRedirectRoute() {
    return Routes.dashboard;
  }
}
