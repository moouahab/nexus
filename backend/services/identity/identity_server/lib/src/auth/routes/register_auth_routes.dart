import 'package:serverpod/serverpod.dart';

import 'auth_change_email_route.dart';
import 'auth_change_password_route.dart';
import 'auth_finish_password_reset_route.dart';
import 'auth_login_route.dart';
import 'auth_logout_route.dart';
import 'auth_me_route.dart';
import 'auth_oauth_login_route.dart';
import 'auth_resend_email_verification_route.dart';
import 'auth_refresh_route.dart';
import 'auth_register_route.dart';
import 'auth_start_password_reset_route.dart';
import 'auth_verify_email_route.dart';

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
      path: '/auth/oauth/login',
      route: AuthOAuthLoginRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/refresh',
      route: AuthRefreshRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/logout',
      route: AuthLogoutRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/me',
      route: AuthMeRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/email/verify',
      route: AuthVerifyEmailRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/email/resend-verification',
      route: AuthResendEmailVerificationRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/password/reset/start',
      route: AuthStartPasswordResetRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/password/reset/finish',
      route: AuthFinishPasswordResetRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/password/change',
      route: AuthChangePasswordRoute(),
    ),
    AuthRouteDefinition(
      path: '/auth/email/change',
      route: AuthChangeEmailRoute(),
    ),
  ];

  for (final definition in routes) {
    pod.webServer.addRoute(definition.route, definition.path);
  }
}
