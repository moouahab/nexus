import 'package:flutter/material.dart';

import '../nexus_assets.dart';
import '../nexus_brand.dart';

class NexusLogo extends StatelessWidget {
  const NexusLogo({
    super.key,
    this.tone = NexusLogoTone.color,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticLabel = NexusBrand.logoSemanticLabel,
  });

  final NexusLogoTone tone;
  final double? height;
  final double? width;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      NexusAssets.lockup(tone: tone),
      height: height,
      width: width,
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticLabel,
      filterQuality: FilterQuality.high,
    );
  }
}

class NexusSymbol extends StatelessWidget {
  const NexusSymbol({
    super.key,
    this.tone = NexusLogoTone.color,
    this.size,
    this.fit = BoxFit.contain,
    this.semanticLabel = NexusBrand.logoSemanticLabel,
  });

  final NexusLogoTone tone;
  final double? size;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      NexusAssets.symbol(tone: tone),
      height: size,
      width: size,
      fit: fit,
      semanticLabel: semanticLabel,
      filterQuality: FilterQuality.high,
    );
  }
}

class NexusAppIcon extends StatelessWidget {
  const NexusAppIcon({
    super.key,
    this.size = 48,
    this.brightness,
    this.semanticLabel = NexusBrand.logoSemanticLabel,
  });

  final double size;
  final Brightness? brightness;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final resolvedBrightness = brightness ?? Theme.of(context).brightness;

    return Image.asset(
      resolvedBrightness == Brightness.dark
          ? NexusAssets.appIconDark
          : NexusAssets.appIconLight,
      height: size,
      width: size,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel,
      filterQuality: FilterQuality.high,
    );
  }
}
