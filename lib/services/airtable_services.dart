import 'package:airtable_crud/airtable_plugin.dart';

import '../utilities/keys.dart';

String apiKey = airtableAccessToken;

String kUGOperationsBaseID = "aappcSe8EQxMbJSWfp";
String kParishesTable = "Geo_Parishes";

String kUGGardensBaseID = "appJBOIeM2ZA5nhnV";
String kUGCurrentGardensBaseID = "appoW7X8Lz3bIKpEE";
String kUG202122GardensBaseID = "app3MYFgL6Pc9VFD0";
String kUG2023GardensBaseID = "appxIhZvX0PiLAMxw";
String kUG2024GardensBaseID = "apppOoRqEza4MN8b2";
String kPGCsTable = "PGCs";
// String kPGCReportTable = "PGC Report";
// String kSurvivingTreesTable = "Surviving Trees";

String currentSeason = "2025-S1";

Map<String, dynamic> kReportTables = {
  "PGCReport": "PGC Report",
  "GardenCompliance": "Garden Compliance Reports",
  "FarmerTraining": "Farmer training reports",
  "SurvivingTrees": "Surviving Trees",
};

AirtableCrud uGGardensBase = AirtableCrud(apiKey, kUGGardensBaseID);
AirtableCrud currentGardensBase = AirtableCrud(apiKey, kUGCurrentGardensBaseID);
AirtableCrud uGOperationsBase = AirtableCrud(apiKey, kUGOperationsBaseID);
AirtableCrud uG202122GardensBase = AirtableCrud(apiKey, kUG202122GardensBaseID);
AirtableCrud uG2023GardensBase = AirtableCrud(apiKey, kUG2023GardensBaseID);
AirtableCrud uG2024GardensBase = AirtableCrud(apiKey, kUG2024GardensBaseID);

Map<String, dynamic> kUpdatesBases = {
  "2021-S1": uG202122GardensBase,
  "2022-S1": uG202122GardensBase,
  "2023-S1": uG2023GardensBase,
  "2024-S1": uG2024GardensBase,
  "current": currentGardensBase,
};
