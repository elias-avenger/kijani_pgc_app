import '../utilities/keys.dart';
import 'package:airtable_crud/airtable_plugin.dart';

String apiKey = airtableAccessToken;

String kUGGardensBaseID = "appJBOIeM2ZA5nhnV";
String kPGCsTable = "PGCs";

AirtableCrud uGGardens = AirtableCrud(apiKey, kUGGardensBaseID);
