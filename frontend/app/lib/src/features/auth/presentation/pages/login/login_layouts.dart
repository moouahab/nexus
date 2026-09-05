part of '../login_page.dart';

class _DesktopLoginLayout extends StatelessWidget {
  const _DesktopLoginLayout({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.submitError,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final bool isSubmitting;
  final String? submitError;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 50, child: _BrandPanel(compact: false)),
        const _CenterDivider(),
        Expanded(
          flex: 50,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 56),
                child: _ScaleToFit(
                  width: 660,
                  height: 850,
                  alignment: const Alignment(-1, -0.22),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 56, right: 40),
                    child: _LoginForm(
                      formKey: formKey,
                      emailController: emailController,
                      passwordController: passwordController,
                      rememberMe: rememberMe,
                      obscurePassword: obscurePassword,
                      isSubmitting: isSubmitting,
                      submitError: submitError,
                      onRememberChanged: onRememberChanged,
                      onTogglePassword: onTogglePassword,
                      onSubmit: onSubmit,
                      onRegister: onRegister,
                      showHeading: true,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CompactLoginLayout extends StatelessWidget {
  const _CompactLoginLayout({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.submitError,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final bool isSubmitting;
  final String? submitError;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: _ScaleToFit(
            width: 430,
            height: 1120,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const _BrandPanel(compact: true),
                const SizedBox(height: 28),
                SizedBox(
                  width: 430,
                  child: _LoginForm(
                    formKey: formKey,
                    emailController: emailController,
                    passwordController: passwordController,
                    rememberMe: rememberMe,
                    obscurePassword: obscurePassword,
                    isSubmitting: isSubmitting,
                    submitError: submitError,
                    onRememberChanged: onRememberChanged,
                    onTogglePassword: onTogglePassword,
                    onSubmit: onSubmit,
                    onRegister: onRegister,
                    compactSpacing: true,
                    showHeading: false,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabletPortraitLoginLayout extends StatelessWidget {
  const _TabletPortraitLoginLayout({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.submitError,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final bool isSubmitting;
  final String? submitError;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 56),
          child: _ScaleToFit(
            width: 600,
            height: 1220,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const _BrandPanel(compact: true),
                const SizedBox(height: 54),
                SizedBox(
                  width: 600,
                  child: _LoginForm(
                    formKey: formKey,
                    emailController: emailController,
                    passwordController: passwordController,
                    rememberMe: rememberMe,
                    obscurePassword: obscurePassword,
                    isSubmitting: isSubmitting,
                    submitError: submitError,
                    onRememberChanged: onRememberChanged,
                    onTogglePassword: onTogglePassword,
                    onSubmit: onSubmit,
                    onRegister: onRegister,
                    showHeading: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabletLandscapeLoginLayout extends StatelessWidget {
  const _TabletLandscapeLoginLayout({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.submitError,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final bool isSubmitting;
  final String? submitError;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 46,
          child: _ScaleToFit(
            width: 560,
            height: 430,
            child: _BrandPanel(compact: true),
          ),
        ),
        const _CenterDivider(),
        Expanded(
          flex: 54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: _ScaleToFit(
              width: 560,
              height: 920,
              alignment: Alignment.centerLeft,
              child: _LoginForm(
                formKey: formKey,
                emailController: emailController,
                passwordController: passwordController,
                rememberMe: rememberMe,
                obscurePassword: obscurePassword,
                isSubmitting: isSubmitting,
                submitError: submitError,
                onRememberChanged: onRememberChanged,
                onTogglePassword: onTogglePassword,
                onSubmit: onSubmit,
                onRegister: onRegister,
                showHeading: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScaleToFit extends StatelessWidget {
  const _ScaleToFit({
    required this.width,
    required this.height,
    required this.child,
    this.alignment = Alignment.center,
  });

  final double width;
  final double height;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.min(
          1.0,
          math.min(
            constraints.maxWidth / width,
            constraints.maxHeight / height,
          ),
        );

        return Align(
          alignment: alignment,
          child: SizedBox(
            width: width * scale,
            height: height * scale,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              child: SizedBox(width: width, height: height, child: child),
            ),
          ),
        );
      },
    );
  }
}
