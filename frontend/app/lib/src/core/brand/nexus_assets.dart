enum NexusLogoTone { color, black, white, red }

enum NexusBackgroundVariant { hero, page, clean }

enum NexusAssetBrightness { light, dark }

abstract final class NexusAssets {
  static const _logoKit = 'assets/image/logo_kit';
  static const _background = 'assets/image/background';
  static const _authPreview = 'assets/image/auth_preview';
  static const _masterSvg = '$_logoKit/01_MASTER_SVG';
  static const _pngTransparent = '$_logoKit/02_PNG_TRANSPARENT';
  static const _uiIcons = '$_logoKit/04_UI_ICONS';
  static const _backgroundWebp = '$_background/04_WEBP_EXPORTS';
  static const _authPreviewWebp = '$_authPreview/04_EXPORTS_WEBP';
  static const _appReadyLogo = '$_logoKit/03_APP_READY';

  static const appIconDark = '$_uiIcons/nexus_app_icon_dark_1024.png';
  static const appIconLight = '$_uiIcons/nexus_app_icon_light_1024.png';

  static const symbol16 = '$_uiIcons/nexus_symbol_16.png';
  static const symbol32 = '$_uiIcons/nexus_symbol_32.png';
  static const symbol48 = '$_uiIcons/nexus_symbol_48.png';
  static const symbol64 = '$_uiIcons/nexus_symbol_64.png';
  static const symbol128 = '$_uiIcons/nexus_symbol_128.png';
  static const symbol256 = '$_uiIcons/nexus_symbol_256.png';
  static const symbol512 = '$_uiIcons/nexus_symbol_512.png';
  static const symbol1024 = '$_uiIcons/nexus_symbol_1024.png';
  static const symbol2048 = '$_uiIcons/nexus_symbol_2048.png';

  static const symbolColor = '$_pngTransparent/nexus_symbol_color_4096.png';
  static const symbolBlack = '$_pngTransparent/nexus_symbol_black_4096.png';
  static const symbolWhite = '$_pngTransparent/nexus_symbol_white_4096.png';

  static const lockupColor = '$_pngTransparent/nexus_lockup_color_4096.png';
  static const lockupBlack = '$_pngTransparent/nexus_lockup_black_4096.png';
  static const lockupWhite = '$_pngTransparent/nexus_lockup_white_4096.png';
  static const brandLockupLight = '$_appReadyLogo/nexus_lockup_brand_light.png';
  static const brandLockupDark = '$_appReadyLogo/nexus_lockup_brand_dark.png';
  static const brandLockupLightSvg =
      '$_appReadyLogo/nexus_lockup_brand_light.svg';
  static const brandLockupDarkSvg =
      '$_appReadyLogo/nexus_lockup_brand_dark.svg';

  static const symbolColorSvg = '$_masterSvg/nexus_symbol_color.svg';
  static const symbolBlackSvg = '$_masterSvg/nexus_symbol_black.svg';
  static const symbolWhiteSvg = '$_masterSvg/nexus_symbol_white.svg';
  static const symbolRedSvg = '$_masterSvg/nexus_symbol_red.svg';

  static const wordmarkColorSvg = '$_masterSvg/nexus_wordmark_color.svg';
  static const wordmarkBlackSvg = '$_masterSvg/nexus_wordmark_black.svg';
  static const wordmarkWhiteSvg = '$_masterSvg/nexus_wordmark_white.svg';
  static const wordmarkRedSvg = '$_masterSvg/nexus_wordmark_red.svg';

  static const lockupColorSvg = '$_masterSvg/nexus_lockup_color.svg';
  static const lockupBlackSvg = '$_masterSvg/nexus_lockup_black.svg';
  static const lockupWhiteSvg = '$_masterSvg/nexus_lockup_white.svg';
  static const lockupRedSvg = '$_masterSvg/nexus_lockup_red.svg';

  static const bgHeroLight = '$_backgroundWebp/nexus_bg_hero_light.webp';
  static const bgHeroDark = '$_backgroundWebp/nexus_bg_hero_dark.webp';
  static const bgPageLight = '$_backgroundWebp/nexus_bg_page_light.webp';
  static const bgPageDark = '$_backgroundWebp/nexus_bg_page_dark.webp';
  static const bgCleanLight = '$_backgroundWebp/nexus_bg_clean_light.webp';
  static const bgCleanDark = '$_backgroundWebp/nexus_bg_clean_dark.webp';

  static const authBackgroundLight =
      '$_authPreviewWebp/nexus_background_light.webp';
  static const authBackgroundDark =
      '$_authPreviewWebp/nexus_background_dark.webp';
  static const authLoginDesktopLight =
      '$_authPreviewWebp/nexus_login_desktop_light.webp';
  static const authLoginDesktopDark =
      '$_authPreviewWebp/nexus_login_desktop_dark.webp';
  static const authLoginTabletLandscapeLight =
      '$_authPreviewWebp/nexus_login_tablet_landscape_light.webp';
  static const authLoginTabletLandscapeDark =
      '$_authPreviewWebp/nexus_login_tablet_landscape_dark.webp';
  static const authLoginTabletPortraitLight =
      '$_authPreviewWebp/nexus_login_tablet_portrait_light.webp';
  static const authLoginTabletPortraitDark =
      '$_authPreviewWebp/nexus_login_tablet_portrait_dark.webp';
  static const authLoginMobileLight =
      '$_authPreviewWebp/nexus_login_mobile_light.webp';
  static const authLoginMobileDark =
      '$_authPreviewWebp/nexus_login_mobile_dark.webp';

  static String symbol({NexusLogoTone tone = NexusLogoTone.color}) {
    return switch (tone) {
      NexusLogoTone.color || NexusLogoTone.red => symbolColor,
      NexusLogoTone.black => symbolBlack,
      NexusLogoTone.white => symbolWhite,
    };
  }

  static String lockup({NexusLogoTone tone = NexusLogoTone.color}) {
    return switch (tone) {
      NexusLogoTone.color || NexusLogoTone.red => lockupColor,
      NexusLogoTone.black => lockupBlack,
      NexusLogoTone.white => lockupWhite,
    };
  }

  static String background({
    NexusBackgroundVariant variant = NexusBackgroundVariant.page,
    NexusAssetBrightness brightness = NexusAssetBrightness.light,
  }) {
    return switch ((variant, brightness)) {
      (NexusBackgroundVariant.hero, NexusAssetBrightness.light) => bgHeroLight,
      (NexusBackgroundVariant.hero, NexusAssetBrightness.dark) => bgHeroDark,
      (NexusBackgroundVariant.page, NexusAssetBrightness.light) => bgPageLight,
      (NexusBackgroundVariant.page, NexusAssetBrightness.dark) => bgPageDark,
      (NexusBackgroundVariant.clean, NexusAssetBrightness.light) =>
        bgCleanLight,
      (NexusBackgroundVariant.clean, NexusAssetBrightness.dark) => bgCleanDark,
    };
  }

  static String authPreview({
    required NexusAssetBrightness brightness,
    required double shortestSide,
    required double longestSide,
  }) {
    final isPortrait = longestSide > shortestSide;

    if (shortestSide < 600) {
      return brightness == NexusAssetBrightness.dark
          ? authLoginMobileDark
          : authLoginMobileLight;
    }

    if (shortestSide < 1024) {
      if (isPortrait) {
        return brightness == NexusAssetBrightness.dark
            ? authLoginTabletPortraitDark
            : authLoginTabletPortraitLight;
      }

      return brightness == NexusAssetBrightness.dark
          ? authLoginTabletLandscapeDark
          : authLoginTabletLandscapeLight;
    }

    return brightness == NexusAssetBrightness.dark
        ? authLoginDesktopDark
        : authLoginDesktopLight;
  }
}
