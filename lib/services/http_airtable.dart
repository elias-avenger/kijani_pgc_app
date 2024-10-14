import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utilities/keys.dart';

class HttpAirtable {
  String apiKey = airtableAccessToken;

  // Future<List<dynamic>?> fetchData({
  //   required String baseId,
  //   required String table,
  // }) async {
  //   List<dynamic> data = [];
  //   String url = 'https://api.airtable.com/v0/$baseId/$table';
  //   Map<String, String> headers = {
  //     'Authorization': 'Bearer $apiKey',
  //   };
  //   try {
  //     String offset = '';
  //     do {
  //       final response =
  //           await http.get(Uri.parse('$url?offset=$offset'), headers: headers);
  //       if (response.statusCode != 200) {
  //         return null;
  //         // throw Exception(
  //         //     'Failed to fetch data from Airtable: ${response.statusCode} ${response.reasonPhrase}');
  //       } else {
  //         Map<String, dynamic> responseData = json.decode(response.body);
  //         data.addAll(responseData['records']);
  //         offset =
  //             responseData.containsKey('offset') ? responseData['offset'] : '';
  //       }
  //     } while (offset.isNotEmpty);
  //   } catch (error) {
  //     //print('ERROR GOT: $error');
  //     return null;
  //   }
  //   //print("Data: $data");
  //   return data;
  // }

  Future<Map> fetchDataWithFilter({
    required String filter,
    required String baseId,
    required String table,
  }) async {
    final encodedFilter = Uri.encodeComponent(filter);
    final url = Uri.parse(
      'https://api.airtable.com/v0/$baseId/$table?filterByFormula=$encodedFilter',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map data = json.decode(response.body);
        if (kDebugMode) {
          print('FROM AIRTABLE: $data');
        }
        return data;
      } else {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      throw Exception('Failed to load data: $e');
    }
  }

  Future<Map<String, dynamic>> createRecord({
    required Map<String, dynamic> data,
    required String baseId,
    required String table,
  }) async {
    final encodedTable = Uri.encodeComponent(table);

    final url = Uri.parse(
      'https://api.airtable.com/v0/$baseId/$encodedTable',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'fields': data}),
      );

      if (response.statusCode == 200) {
        return {'success': 'Data submitted successfully'};
      } else {
        return {'failure': 'Failed to submit data: ${response.reasonPhrase}'};
      }
    } catch (e) {
      return {'failure': 'Error: $e'};
    }
  }
}
