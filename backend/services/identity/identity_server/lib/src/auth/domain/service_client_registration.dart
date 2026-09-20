class ServiceClientRegistration {
  const ServiceClientRegistration({
    required this.serviceName,
    required this.secret,
    required this.allowedAudiences,
    required this.allowedScopes,
  });

  factory ServiceClientRegistration.fromJson(
    String serviceName,
    Map<String, dynamic> json,
  ) {
    return ServiceClientRegistration(
      serviceName: _requiredTokenValue(serviceName, 'serviceName'),
      secret: _requiredSecret(json['secret']),
      allowedAudiences: _stringSet(json['audiences'], 'audiences'),
      allowedScopes: _stringSet(json['scopes'], 'scopes'),
    );
  }

  final String serviceName;
  final String secret;
  final Set<String> allowedAudiences;
  final Set<String> allowedScopes;

  bool allowsAudience(String audience) => allowedAudiences.contains(audience);

  bool allowsScopes(Iterable<String> scopes) {
    return scopes.every(allowedScopes.contains);
  }

  static String _requiredSecret(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Service client secret is required.');
    }
    return value;
  }

  static Set<String> _stringSet(dynamic value, String name) {
    final rawValues = switch (value) {
      String text => text.split(RegExp(r'\s+')),
      List list => list.cast<String>(),
      _ => throw FormatException('Service client "$name" must be configured.'),
    };
    final normalized = rawValues
        .map((item) => _requiredTokenValue(item, name))
        .toSet();
    if (normalized.isEmpty) {
      throw FormatException('Service client "$name" must not be empty.');
    }
    return normalized;
  }

  static String _requiredTokenValue(String value, String name) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.contains(RegExp(r'\s'))) {
      throw FormatException('Invalid service client "$name" value.');
    }
    return normalized;
  }
}
