part of '../login_page.dart';

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.isGoogleSubmitting,
    required this.submitError,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onGoogleLogin,
    required this.onRegister,
    this.compactSpacing = false,
    this.showHeading = true,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final bool isSubmitting;
  final bool isGoogleSubmitting;
  final String? submitError;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;
  final Future<void> Function() onGoogleLogin;
  final VoidCallback onRegister;
  final bool compactSpacing;
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? NexusBrand.white : NexusBrand.black;
    final secondaryText = isDark ? Colors.white70 : const Color(0xff5f6570);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeading) ...[
            _SectionHeading(color: primaryText),
            const SizedBox(height: 18),
            Text(
              'Accédez à votre espace Nexus',
              style: TextStyle(
                color: secondaryText,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: compactSpacing ? 50 : 72),
          ],
          _LabeledLineField(
            controller: emailController,
            label: 'IDENTIFIANT',
            hintText: 'E-mail ou nom d’utilisateur',
            icon: Icons.person_outline,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            validator: (value) {
              final username = value?.trim() ?? '';
              if (username.isEmpty) {
                return 'Identifiant requis';
              }
              return null;
            },
          ),
          SizedBox(height: compactSpacing ? 38 : 52),
          _LabeledLineField(
            fieldKey: const ValueKey('login-password-field'),
            controller: passwordController,
            label: 'MOT DE PASSE',
            hintText: 'Votre mot de passe',
            icon: Icons.lock_outline,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            suffixIcon: IconButton(
              key: const ValueKey('login-password-visibility-button'),
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              tooltip: obscurePassword
                  ? 'Afficher le mot de passe'
                  : 'Masquer le mot de passe',
            ),
            onFieldSubmitted: (_) => onSubmit(),
            validator: (value) {
              if ((value ?? '').isEmpty) {
                return 'Mot de passe requis';
              }
              return null;
            },
          ),
          SizedBox(height: compactSpacing ? 22 : 32),
          _RememberAndHelpRow(value: rememberMe, onChanged: onRememberChanged),
          if (submitError != null) ...[
            SizedBox(height: compactSpacing ? 18 : 24),
            Text(
              submitError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: NexusBrand.red,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          SizedBox(height: compactSpacing ? 28 : 42),
          _LineButton(
            text: isSubmitting ? 'CONNEXION...' : 'SE CONNECTER',
            color: NexusBrand.red,
            icon: Icons.arrow_forward,
            onPressed: isSubmitting ? null : onSubmit,
          ),
          SizedBox(height: compactSpacing ? 30 : 44),
          _Separator(label: 'OU', color: secondaryText),
          SizedBox(height: compactSpacing ? 18 : 26),
          _LineButton(
            text: isGoogleSubmitting
                ? 'Connexion Google...'
                : 'Continuer avec Google',
            color: primaryText,
            leading: Text(
              'G',
              style: TextStyle(
                color: primaryText,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            icon: Icons.arrow_forward,
            onPressed: isSubmitting || isGoogleSubmitting
                ? null
                : onGoogleLogin,
          ),
          SizedBox(height: compactSpacing ? 24 : 46),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                'Pas encore de compte ?',
                style: TextStyle(color: secondaryText, fontSize: 16),
              ),
              TextButton(
                onPressed: onRegister,
                child: const Text('Créer un compte'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
