import 'package:airtable_crud/airtable_plugin.dart';

import '../utilities/keys.dart';

String apiKey = airtableAccessToken;

String kUGOperationsBaseID = "aappcSe8EQxMbJSWfp";
String kParishesTable = "Geo_Parishes";

String kUGGardensBaseID = "appJBOIeM2ZA5nhnV";
String kUGCurrentGardensBaseID = "appoW7X8Lz3bIKpEE";
String kPGCsTable = "PGCs";
String kPGCReportTable = "PGC Report";
Map<String, dynamic> kReportTables = {
  "PGCReport": "PGC Report",
  "GardenCompliance": "Garden Compliance Reports",
};

AirtableCrud uGGardensBase = AirtableCrud(apiKey, kUGGardensBaseID);
AirtableCrud currentGardensBase = AirtableCrud(apiKey, kUGCurrentGardensBaseID);
AirtableCrud uGOperationsBase = AirtableCrud(apiKey, kUGOperationsBaseID);
