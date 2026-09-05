part of 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authApi = AuthApi();
  var _obscurePassword = true;
  var _obscureConfirmPassword = true;
  var _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _authApi.close();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await _authApi.register(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        email: _emailController.text.trim(),
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
      setState(() => _submitError = 'Inscription impossible. Réessayez.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
                  ? _DesktopRegisterLayout(form: _form(compactSpacing: true))
                  : isTabletLandscape
                  ? _TabletLandscapeRegisterLayout(
                      form: _form(showHeading: true),
                    )
                  : isTabletPortrait
                  ? _TabletPortraitRegisterLayout(
                      form: _form(showHeading: true),
                    )
                  : _CompactRegisterLayout(
                      form: _form(compactSpacing: true, showHeading: false),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form({bool compactSpacing = false, bool showHeading = true}) {
    return _RegisterForm(
      formKey: _formKey,
      usernameController: _usernameController,
      emailController: _emailController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      confirmPasswordFieldKey: _confirmPasswordFieldKey,
      obscurePassword: _obscurePassword,
      obscureConfirmPassword: _obscureConfirmPassword,
      isSubmitting: _isSubmitting,
      submitError: _submitError,
      compactSpacing: compactSpacing,
      showHeading: showHeading,
      onTogglePassword: () {
        setState(() => _obscurePassword = !_obscurePassword);
      },
      onToggleConfirmPassword: () {
        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
      },
      onSubmit: _submit,
      onLogin: () {
        Navigator.of(context).pop();
      },
    );
  }
}
