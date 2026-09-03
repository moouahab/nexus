import 'package:flutter/material.dart';

abstract final class NexusBrand {
  static const name = 'Nexus';

  static const red = Color(0xffff3137);
  static const redDeep = Color(0xffd50f18);
  static const black = Color(0xff0c0c0e);
  static const white = Color(0xfff5f5f6);
  static const gray = Color(0xff8f9098);

  static const logoSemanticLabel = 'Logo Nexus';

  static ColorScheme lightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: red,
      brightness: Brightness.light,
      primary: red,
      onPrimary: Colors.white,
      surface: white,
      onSurface: black,
    );
  }

  static ColorScheme darkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: red,
      brightness: Brightness.dark,
      primary: red,
      onPrimary: Colors.white,
      surface: black,
      onSurface: white,
    );
  }
}
