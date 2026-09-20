import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/brand/brand.dart';
import '../../../../core/config/router/routers.dart';
import '../../data/auth_api.dart';
import '../../data/google_oauth_service.dart';

part 'login/login_brand_panel.dart';
part 'login/login_center_divider.dart';
part 'login/login_form.dart';
part 'login/login_form_controls.dart';
part 'login/login_layouts.dart';
part 'login/login_topographic_lines.dart';
part 'register/register_form.dart';
part 'register/register_layouts.dart';
part 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApi = AuthApi();
  final _googleOAuthService = GoogleOAuthService();
  var _rememberMe = false;
  var _obscurePassword = true;
  var _isSubmitting = false;
  var _isGoogleSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    unawaited(_googleOAuthService.warmUp().catchError((_) {}));
  }

  @override
  void dispose() {
    _authApi.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await _authApi.login(
        username: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(PageNavigation.home);
    } on AuthApiException catch (exception) {
      if (!mounted) return;
      setState(() => _submitError = exception.message);
    } on FormatException {
      if (!mounted) return;
      setState(() => _submitError = 'Réponse serveur invalide.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitError = 'Connexion impossible. Réessayez.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _startGoogleLogin() async {
    if (_isSubmitting || _isGoogleSubmitting) {
      return;
    }

    setState(() {
      _isGoogleSubmitting = true;
      _submitError = null;
    });

    try {
      debugPrint('[OAuth] Google flow started');
      final authorization = await _googleOAuthService.requestAuthorization();
      debugPrint('[OAuth] Sending token to backend');
      await _authApi.oauthLogin(
        provider: 'google',
        code: authorization.code,
        redirectUri: authorization.redirectUri,
        codeVerifier: authorization.codeVerifier,
      );
      debugPrint('[OAuth] Backend authentication successful');
      debugPrint('[OAuth] Local session saved');

      if (!mounted) return;
      debugPrint('[OAuth] Google flow completed');
      Navigator.of(context).pushReplacementNamed(PageNavigation.home);
    } on AuthApiException catch (exception) {
      if (!mounted) return;
      setState(() => _submitError = exception.message);
    } on FormatException {
      if (!mounted) return;
      setState(() => _submitError = 'Réponse serveur invalide.');
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _submitError = _googleOAuthService.messageForError(error));
    } finally {
      if (mounted) {
        setState(() => _isGoogleSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 1440;
    final isTablet = size.width >= 600 && !isDesktop;
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
                      isSubmitting: _isSubmitting,
                      isGoogleSubmitting: _isGoogleSubmitting,
                      submitError: _submitError,
                      onRememberChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      onTogglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onSubmit: _submit,
                      onGoogleLogin: _startGoogleLogin,
                      onRegister: () {
                        Navigator.of(
                          context,
                        ).pushNamed(PageNavigation.register);
                      },
                    )
                  : isTabletLandscape
                  ? _TabletLandscapeLoginLayout(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      rememberMe: _rememberMe,
                      obscurePassword: _obscurePassword,
                      isSubmitting: _isSubmitting,
                      isGoogleSubmitting: _isGoogleSubmitting,
                      submitError: _submitError,
                      onRememberChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      onTogglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onSubmit: _submit,
                      onGoogleLogin: _startGoogleLogin,
                      onRegister: () {
                        Navigator.of(
                          context,
                        ).pushNamed(PageNavigation.register);
                      },
                    )
                  : isTabletPortrait
                  ? _TabletPortraitLoginLayout(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      rememberMe: _rememberMe,
                      obscurePassword: _obscurePassword,
                      isSubmitting: _isSubmitting,
                      isGoogleSubmitting: _isGoogleSubmitting,
                      submitError: _submitError,
                      onRememberChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      onTogglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onSubmit: _submit,
                      onGoogleLogin: _startGoogleLogin,
                      onRegister: () {
                        Navigator.of(
                          context,
                        ).pushNamed(PageNavigation.register);
                      },
                    )
                  : _CompactLoginLayout(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      rememberMe: _rememberMe,
                      obscurePassword: _obscurePassword,
                      isSubmitting: _isSubmitting,
                      isGoogleSubmitting: _isGoogleSubmitting,
                      submitError: _submitError,
                      onRememberChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      onTogglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onSubmit: _submit,
                      onGoogleLogin: _startGoogleLogin,
                      onRegister: () {
                        Navigator.of(
                          context,
                        ).pushNamed(PageNavigation.register);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
