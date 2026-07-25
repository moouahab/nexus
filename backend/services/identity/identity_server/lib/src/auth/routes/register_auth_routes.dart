import 'package:serverpod/serverpod.dart';

import 'auth_login_route.dart';
import 'auth_logout_route.dart';
import 'auth_refresh_route.dart';
import 'auth_register_route.dart';

class AuthRouteDefinition {
  const AuthRouteDefinition({
    required this.path,
    required this.route,
  });

  final String path;
  final Route route;
}

void registerAuthRoutes(Serverpod pod) {
  final routes = [
    AuthRouteDefinition(
      path: '/auth/register',
      route: AuthRegisterRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/login',
      route: AuthLoginRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/refresh',
      route: AuthRefreshRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/logout',
      route: AuthLogoutRoute(),
    ),
  ];

  for (final definition in routes) {
    pod.webServer.addRoute(definition.route, definition.path);
  }
}
