import 'package:flutter/material.dart';

import '../nexus_assets.dart';

class NexusBackground extends StatelessWidget {
  const NexusBackground({
    super.key,
    required this.child,
    this.variant = NexusBackgroundVariant.page,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final NexusBackgroundVariant variant;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness == Brightness.dark
        ? NexusAssetBrightness.dark
        : NexusAssetBrightness.light;

    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            NexusAssets.background(variant: variant, brightness: brightness),
          ),
          fit: fit,
          alignment: alignment,
        ),
      ),
      child: child,
    );
  }
}
