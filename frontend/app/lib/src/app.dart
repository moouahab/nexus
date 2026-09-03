import 'package:flutter/material.dart';

import 'core/brand/brand.dart';
import 'core/config/router/routers.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: NexusBrand.name,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: NexusBrand.lightColorScheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: NexusBrand.darkColorScheme(),
        useMaterial3: true,
      ),
      initialRoute: PageNavigation.login,
      routes: PageRouter.routes,
    );
  }
}
