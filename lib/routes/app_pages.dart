import 'package:get/get.dart';
import 'package:kijani_pgc_app/routes/app_bindings.dart';
import 'package:kijani_pgc_app/screens/auth/login_screen.dart';
import 'package:kijani_pgc_app/screens/farmer/farmer_screen.dart';
import 'package:kijani_pgc_app/screens/home/home_screen.dart';
import 'package:kijani_pgc_app/screens/parish/parish_screen.dart';
import 'package:kijani_pgc_app/screens/reports/daily_reporting.dart';
import 'package:kijani_pgc_app/screens/reports/garden_compliance.dart';
import 'package:kijani_pgc_app/screens/reports/group_training.dart';
import 'package:kijani_pgc_app/screens/syncing/unsynced_data_screen.dart';

import '../screens/garden/garden_screen.dart';
import '../screens/group/group_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final pages = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
      binding: UserBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: UserBinding(),
    ),
    GetPage(
      name: Routes.DAILYREPORT,
      page: () => const DailyReportScreen(),
    ),
    GetPage(
      name: Routes.UNSYCEDDATA,
      page: () => const UnsyncedDataScreen(),
    ),
    GetPage(
      name: Routes.PARISH,
      page: () => const ParishScreen(),
      binding: ParishBinding(),
    ),
    GetPage(
      name: Routes.GROUP,
      page: () => const GroupScreen(),
      binding: GroupBinding(),
    ),
    GetPage(
      name: Routes.GROUPTRAINING,
      page: () => const GroupTrainingReport(),
    ),
    GetPage(
      name: Routes.FARMER,
      page: () => const FarmerScreen(),
      binding: FarmerBinding(),
    ),
    GetPage(
      name: Routes.GARDEN,
      page: () => const GardenScreen(),
      binding: GardenBinding(),
    ),
    GetPage(
      name: Routes.GARDENCOMPLIANCEREPORT,
      page: () => const GardenComplianceForm(),
    ),
  ];
}
