part of '../login_page.dart';

class _LabeledLineField extends StatelessWidget {
  const _LabeledLineField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? NexusBrand.white : NexusBrand.black;
    final hintColor = isDark ? Colors.white60 : const Color(0xff6f7682);
    final lineColor = isDark ? Colors.white38 : Colors.black45;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          obscureText: obscureText,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: TextStyle(color: textColor, fontSize: 18),
          cursorColor: NexusBrand.red,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: hintColor, fontSize: 18),
            prefixIcon: Icon(icon, color: textColor, size: 28),
            suffixIcon: suffixIcon,
            suffixIconColor: textColor,
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: lineColor),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lineColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: NexusBrand.red),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: NexusBrand.red),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: NexusBrand.red),
            ),
            contentPadding: const EdgeInsets.only(bottom: 14),
          ),
        ),
      ],
    );
  }
}

class _RememberAndHelpRow extends StatelessWidget {
  const _RememberAndHelpRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : const Color(0xff4f5661);

    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          side: BorderSide(color: textColor),
          activeColor: NexusBrand.red,
          visualDensity: VisualDensity.compact,
        ),
        Text(
          'Se souvenir de moi',
          style: TextStyle(color: textColor, fontSize: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Mot de passe oublié ?',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LineButton extends StatelessWidget {
  const _LineButton({
    required this.text,
    required this.color,
    required this.icon,
    required this.onPressed,
    this.leading,
  });

  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final isPrimary = text == 'SE CONNECTER';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: color),
          bottom: BorderSide(color: color),
        ),
      ),
      child: SizedBox(
        height: isPrimary ? 68 : 62,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: color,
            padding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(),
          ),
          child: Row(
            children: [
              SizedBox(width: 52, child: Center(child: leading)),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontFamily: isPrimary ? 'monospace' : null,
                    fontSize: isPrimary ? 20 : 16,
                    fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: 52, child: Icon(icon, color: color, size: 30)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}
