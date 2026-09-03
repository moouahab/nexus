import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/brand/brand.dart';
import '../../../../core/config/router/routers.dart';

part 'login/login_brand_panel.dart';
part 'login/login_center_divider.dart';
part 'login/login_form.dart';
part 'login/login_form_controls.dart';
part 'login/login_layouts.dart';
part 'login/login_topographic_lines.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _rememberMe = false;
  var _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(PageNavigation.home);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 1440;
    final shortestSide = math.min(size.width, size.height);
    final aspectRatio = size.width / size.height;
    final isNarrowPortrait = size.height > size.width && aspectRatio < 0.62;
    final isTablet = shortestSide >= 600 && !isNarrowPortrait;
    final isTabletLandscape = isTablet && size.width > size.height;
    final isTabletPortrait = isTablet && size.height >= size.width;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              isDark
                  ? NexusAssets.authBackgroundDark
                  : NexusAssets.authBackgroundLight,
            ),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _TopographicLinesPainter(isDark: isDark),
                ),
              ),
            ),
            SafeArea(
              child: isDesktop
                  ? _DesktopLoginLayout(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      rememberMe: _rememberMe,
                      obscurePassword: _obscurePassword,
                      onRememberChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      onTogglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onSubmit: _submit,
                    )
                  : isTabletLandscape
                  ? _TabletLandscapeLoginLayout(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      rememberMe: _rememberMe,
                      obscurePassword: _obscurePassword,
                      onRememberChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      onTogglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onSubmit: _submit,
                    )
                  : isTabletPortrait
                  ? _TabletPortraitLoginLayout(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      rememberMe: _rememberMe,
                      obscurePassword: _obscurePassword,
                      onRememberChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      onTogglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onSubmit: _submit,
                    )
                  : _CompactLoginLayout(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      rememberMe: _rememberMe,
                      obscurePassword: _obscurePassword,
                      onRememberChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      onTogglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onSubmit: _submit,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
