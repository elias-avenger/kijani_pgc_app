import '../utilities/keys.dart';
import 'package:airtable_crud/airtable_plugin.dart';

String apiKey = airtableAccessToken;

String kUGOperationsBaseID = "aappcSe8EQxMbJSWfp";
String kParishesTable = "Geo_Parishes";

String kUGGardensBaseID = "appJBOIeM2ZA5nhnV";
String kUGCurrentGardensBaseID = "appoW7X8Lz3bIKpEE";
String kPGCsTable = "PGCs";
String kPGCReportTable =
    "PGC Report App Test"; //TOD: change the table name to the correct one

AirtableCrud uGGardensBase = AirtableCrud(apiKey, kUGGardensBaseID);
AirtableCrud currentGardensBase = AirtableCrud(apiKey, kUGCurrentGardensBaseID);
AirtableCrud uGOperationsBase = AirtableCrud(apiKey, kUGOperationsBaseID);
