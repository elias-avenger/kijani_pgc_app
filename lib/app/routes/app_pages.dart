import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/middleware/auth_guard.dart';
import 'package:kijani_pmc_app/app/middleware/role_guard.dart';
import 'package:kijani_pmc_app/app/modules/Farmer/views/index.dart';
import 'package:kijani_pmc_app/app/modules/auth/bindings/auth_bindings.dart';
import 'package:kijani_pmc_app/app/modules/auth/views/login_view.dart';
import 'package:kijani_pmc_app/app/modules/bc/bindings/bc_bindngs.dart';
import 'package:kijani_pmc_app/app/modules/bc/views/report.dart';
import 'package:kijani_pmc_app/app/modules/dashboard/views/index.dart';
import 'package:kijani_pmc_app/app/modules/garden/views/index.dart';
import 'package:kijani_pmc_app/app/modules/group/bindings/group_binding.dart';
import 'package:kijani_pmc_app/app/modules/group/views/index.dart';
import 'package:kijani_pmc_app/app/modules/mel/bindings/bc_bindngs.dart';
import 'package:kijani_pmc_app/app/modules/mel/bindings/form_binding.dart';
import 'package:kijani_pmc_app/app/modules/mel/views/report.dart';
import 'package:kijani_pmc_app/app/modules/parish/bindings/parish_bindings.dart';
import 'package:kijani_pmc_app/app/modules/parish/views/index.dart';
import 'package:kijani_pmc_app/app/modules/parish/views/report.dart';
import 'package:kijani_pmc_app/app/modules/pmc/bindings/bc_bindngs.dart';
import 'package:kijani_pmc_app/app/modules/pmc/views/report.dart';
import 'package:kijani_pmc_app/app/routes/routes.dart';

class AppPages {
  static const INITIAL = Routes.dashboard;

  static final pages = [
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
      binding: AuthBinding(), // Injects the AuthController
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const Dashboard(),
      binding: AuthBinding(),
      middlewares: [AuthMiddleware()],
    ),
    // Role-based access to dashboards
    GetPage(
      name: Routes.bcDashboard,
      page: () => const Dashboard(),
      binding: BcBinding(),
      middlewares: [RoleGuard('bc')], // Only allow BC access
    ),
    GetPage(
      name: Routes.pmcDashboard,
      page: () => const Dashboard(),
      binding: PmcBinding(),
      middlewares: [RoleGuard('pmc')], // Only allow PMC access
    ),
    GetPage(
      name: Routes.melDashboard,
      page: () => const Dashboard(),
      binding: MelBinding(),
      middlewares: [RoleGuard('mel')], // Only allow MEL access
    ),
    GetPage(
        name: Routes.parish,
        page: () => const ParishDetailScreen(),
        binding: ParishBinding(),
        middlewares: [AuthMiddleware()]),

    GetPage(
      name: Routes.group,
      page: () => const GroupDetailScreen(),
      binding: GroupBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.farmer,
      page: () => const FarmerDetailScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.garden,
      page: () => const GardenDetailScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.pmcReport,
      page: () => const PmcReportScreen(),
      binding: PmcBinding(),
      middlewares: [RoleGuard('pmc')],
    ),
    GetPage(
      name: Routes.bcReport,
      page: () => const BCReportFormScreen(),
      binding: BcBinding(),
      middlewares: [RoleGuard('bc')],
    ),
    GetPage(
      name: Routes.melReport,
      page: () => const MELReportFormScreen(),
      binding: MelReportBinding(),
      middlewares: [RoleGuard('mel')],
    ),
    GetPage(
      name: Routes.parishReport,
      page: () => const ParishReportFormScreen(),
      binding: ParishBinding(),
      middlewares: [RoleGuard('bc')],
    )
  ];
}
