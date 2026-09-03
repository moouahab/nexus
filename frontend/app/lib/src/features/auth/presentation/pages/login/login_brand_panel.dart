part of '../login_page.dart';

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: NexusBrand.logoSemanticLabel,
              image: true,
              child: SvgPicture.asset(
                isDark
                    ? NexusAssets.brandLockupDarkSvg
                    : NexusAssets.brandLockupLightSvg,
                height: compact ? 320 : 500,
                width: compact ? 560 : 600,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
            Transform.translate(
              offset: Offset(0, compact ? -38 : -60),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'CONTRÔLER.  AUTOMATISER.  '),
                    TextSpan(
                      text: 'PROTÉGER.',
                      style: const TextStyle(color: NexusBrand.red),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? NexusBrand.white : NexusBrand.black,
                  fontFamily: 'monospace',
                  fontSize: compact ? 17 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
