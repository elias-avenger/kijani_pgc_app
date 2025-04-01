import 'package:get/get.dart';
import 'package:kijani_pmc_app/routes/app_bindings.dart';
import 'package:kijani_pmc_app/screens/auth/login_screen.dart';
import 'package:kijani_pmc_app/screens/syncing/unsynced_data_screen.dart';
import 'package:kijani_pmc_app/screens/home/home_screen.dart';
import 'package:kijani_pmc_app/screens/reports/daily_reporting.dart';
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
      page: () => HomeScreen(),
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
  ];
}
