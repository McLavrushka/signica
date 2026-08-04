import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:signica/app/router/app_router.gr.dart';

@lazySingleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: DocumentsRoute.page, initial: true),
  ];
}
