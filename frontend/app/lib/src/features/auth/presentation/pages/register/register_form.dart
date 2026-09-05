part of '../login_page.dart';

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.confirmPasswordFieldKey,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isSubmitting,
    required this.submitError,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
    required this.onLogin,
    this.compactSpacing = false,
    this.showHeading = true,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormFieldState<String>> confirmPasswordFieldKey;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isSubmitting;
  final String? submitError;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final Future<void> Function() onSubmit;
  final VoidCallback onLogin;
  final bool compactSpacing;
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? NexusBrand.white : NexusBrand.black;
    final secondaryText = isDark ? Colors.white70 : const Color(0xff5f6570);

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeading) ...[
            _SectionHeading(color: primaryText, title: 'INSCRIPTION'),
            const SizedBox(height: 18),
            Text(
              'Créez votre accès Nexus',
              style: TextStyle(
                color: secondaryText,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: compactSpacing ? 42 : 58),
          ],
          _LabeledLineField(
            controller: usernameController,
            label: 'USERNAME',
            hintText: 'Nom d’utilisateur',
            icon: Icons.person_outline,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            validator: (value) {
              if ((value?.trim() ?? '').isEmpty) {
                return 'Username requis';
              }
              return null;
            },
          ),
          SizedBox(height: compactSpacing ? 34 : 42),
          _LabeledLineField(
            controller: emailController,
            label: 'E-MAIL',
            hintText: 'Adresse e-mail',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return null;
              if (!email.contains('@')) return 'E-mail invalide';
              return null;
            },
          ),
          SizedBox(height: compactSpacing ? 34 : 42),
          _LabeledLineField(
            fieldKey: const ValueKey('register-password-field'),
            controller: passwordController,
            label: 'MOT DE PASSE',
            hintText: 'Votre mot de passe',
            icon: Icons.lock_outline,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            suffixIcon: IconButton(
              key: const ValueKey('register-password-visibility-button'),
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
            onChanged: (_) {
              if (confirmPasswordController.text.isNotEmpty) {
                confirmPasswordFieldKey.currentState?.validate();
              }
            },
            validator: (value) {
              if ((value ?? '').isEmpty) {
                return 'Mot de passe requis';
              }
              return null;
            },
          ),
          SizedBox(height: compactSpacing ? 34 : 42),
          _LabeledLineField(
            fieldKey: const ValueKey('register-confirm-password-field'),
            formFieldKey: confirmPasswordFieldKey,
            controller: confirmPasswordController,
            label: 'CONFIRMATION',
            hintText: 'Confirmez le mot de passe',
            icon: Icons.lock_reset_outlined,
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            suffixIcon: IconButton(
              key: const ValueKey(
                'register-confirm-password-visibility-button',
              ),
              onPressed: onToggleConfirmPassword,
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              tooltip: obscureConfirmPassword
                  ? 'Afficher la confirmation'
                  : 'Masquer la confirmation',
            ),
            onFieldSubmitted: (_) => onSubmit(),
            validator: (value) {
              if ((value ?? '').isEmpty) {
                return 'Confirmation requise';
              }
              if (value != passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
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
          SizedBox(height: compactSpacing ? 30 : 40),
          _LineButton(
            text: isSubmitting ? 'CRÉATION...' : 'CRÉER LE COMPTE',
            color: NexusBrand.red,
            icon: Icons.arrow_forward,
            onPressed: isSubmitting ? null : onSubmit,
          ),
          SizedBox(height: compactSpacing ? 28 : 42),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                'Déjà un compte ?',
                style: TextStyle(color: secondaryText, fontSize: 16),
              ),
              TextButton(onPressed: onLogin, child: const Text('Se connecter')),
            ],
          ),
        ],
      ),
    );
  }
}
