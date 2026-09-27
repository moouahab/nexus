class GoogleOAuthAuthorization {
  const GoogleOAuthAuthorization({
    required this.code,
    this.redirectUri,
    this.codeVerifier,
  });

  final String code;
  final String? redirectUri;
  final String? codeVerifier;
}
