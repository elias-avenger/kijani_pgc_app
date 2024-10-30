import 'package:airtable_crud/airtable_plugin.dart';
import 'package:kijani_pmc_app/global/enums/keys.dart';

String apikey = airtableAccessToken;

String nurserybaseId = 'app9yul6FMnVUm7L4';
String currentNurserybaseId = 'appApXI0jgwCRGrB0';
String gardenbaseId = 'appJBOIeM2ZA5nhnV';
String currentGardenbaseId = 'appoW7X8Lz3bIKpEE';

AirtableCrud nurseryBase = AirtableCrud(apikey, nurserybaseId);
AirtableCrud gardenBase = AirtableCrud(apikey, gardenbaseId);
AirtableCrud currentNurseryBase = AirtableCrud(apikey, currentNurserybaseId);
AirtableCrud currentGardenBase = AirtableCrud(apikey, currentGardenbaseId);
