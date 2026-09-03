part of '../login_page.dart';

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

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
          _LabeledLineField(
            controller: emailController,
            label: 'IDENTIFIANT',
            hintText: 'Adresse e-mail',
            icon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) {
                return 'Email requis';
              }
              if (!email.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 52),
          _LabeledLineField(
            controller: passwordController,
            label: 'MOT DE PASSE',
            hintText: 'Votre mot de passe',
            icon: Icons.lock_outline,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            suffixIcon: IconButton(
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
          const SizedBox(height: 32),
          _RememberAndHelpRow(value: rememberMe, onChanged: onRememberChanged),
          const SizedBox(height: 42),
          _LineButton(
            text: 'SE CONNECTER',
            color: NexusBrand.red,
            icon: Icons.arrow_forward,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 44),
          _Separator(label: 'OU', color: secondaryText),
          const SizedBox(height: 26),
          _LineButton(
            text: 'Continuer avec Google',
            color: primaryText,
            leading: Text(
              'G',
              style: TextStyle(
                color: primaryText,
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
            icon: Icons.arrow_forward,
            onPressed: () {},
          ),
          const SizedBox(height: 46),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pas encore de compte ?',
                  style: TextStyle(color: secondaryText, fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Créer un compte'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
