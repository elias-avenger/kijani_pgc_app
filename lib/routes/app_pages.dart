import 'package:get/get.dart';
import 'package:kijani_pgc_app/routes/app_bindings.dart';
import 'package:kijani_pgc_app/screens/auth/login_screen.dart';
import 'package:kijani_pgc_app/screens/home/home_screen.dart';
import 'package:kijani_pgc_app/screens/reports/daily_reporting.dart';
import 'package:kijani_pgc_app/screens/syncing/unsynced_data_screen.dart';

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
