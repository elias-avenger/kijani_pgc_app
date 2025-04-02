import '../utilities/keys.dart';
import 'package:airtable_crud/airtable_plugin.dart';

String apiKey = airtableAccessToken;

String kUGGardensBaseID = "appJBOIeM2ZA5nhnV";
String kUGCurrentGardensBaseID = "appoW7X8Lz3bIKpEE";
String kPGCsTable = "PGCs";
String kPGCReportTable = "PGC Report";

AirtableCrud uGGardensBase = AirtableCrud(apiKey, kUGGardensBaseID);
AirtableCrud currentGardensBase = AirtableCrud(apiKey, kUGGardensBaseID);
