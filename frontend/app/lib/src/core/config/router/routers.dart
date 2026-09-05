import 'package:flutter/material.dart';

import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/home/presentation/pages/home_page.dart';

abstract final class PageNavigation {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
}

abstract final class PageRouter {
  static final Map<String, WidgetBuilder> routes = {
    PageNavigation.login: (_) => const LoginPage(),
    PageNavigation.register: (_) => const RegisterPage(),
    PageNavigation.home: (_) => const MyHomePage(),
  };
}

// Exemple d'utilisation des routes dans un MaterialApp
// MaterialApp(
//   initialRoute: PageNavigation.login,
//   routes: PageRouter.routes,
// );
