// import http package
// import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/home/presentation/pages/home_page.dart';

abstract final class ApiConfig {
  static const identityUrl = 'http://127.0.0.1:8182';
}

abstract final class ApiAuthEndpoints {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const me = '/auth/me';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
}

// comment on peut definir les routes dans flutter

// final url = Uri.parse(
//   '${ApiConfig.identityUrl}${ApiAuthEndpoints.login}',
// );

// final client = http.Client(); -> creation d'un client HTTP pour effectuer
//                                  des requêtes vers l'API

// Exemple de fonction pour effectuer une requête POST vers l'endpoint de login
// Future<void> login() async {
//   final uri = Uri.parse(
//     '${ApiConfig.identityUrl}${ApiAuthEndpoints.login}',
//   );

//   await client.post(uri);
// }

abstract final class PageNavigation {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
}

abstract final class PageRouter {
  static final Map<String, WidgetBuilder> routes = {
    PageNavigation.login: (_) => const LoginPage(),
    PageNavigation.home: (_) => const MyHomePage(),
    // AppRoutes.register: (_) => const RegisterPage(),
  };
}

// Exemple d'utilisation des routes dans un MaterialApp
// MaterialApp(
//   initialRoute: PageNavigation.login,
//   routes: PageRouter.routes,
// );
