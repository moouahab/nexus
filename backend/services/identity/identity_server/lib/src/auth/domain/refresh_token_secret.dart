class RefreshTokenSecret {
  const RefreshTokenSecret({
    required this.raw,
    required this.hash,
  });

  final String raw;
  final String hash;
}
