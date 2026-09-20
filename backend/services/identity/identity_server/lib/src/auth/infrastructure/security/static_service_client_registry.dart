import 'dart:convert';

import '../../application/interfaces/service_client_registry.dart';
import '../../domain/service_client_registration.dart';

class StaticServiceClientRegistry implements ServiceClientRegistry {
  StaticServiceClientRegistry(Iterable<ServiceClientRegistration> clients)
    : _clients = {
        for (final client in clients) client.serviceName: client,
      };

  factory StaticServiceClientRegistry.fromJson(String jsonText) {
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map) {
      throw const FormatException(
        'Service clients registry must be an object.',
      );
    }

    return StaticServiceClientRegistry(
      decoded.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;
        if (key is! String || value is! Map) {
          throw const FormatException('Invalid service client registry entry.');
        }
        return ServiceClientRegistration.fromJson(
          key,
          value.cast<String, dynamic>(),
        );
      }),
    );
  }

  final Map<String, ServiceClientRegistration> _clients;

  @override
  ServiceClientRegistration? findByServiceName(String serviceName) {
    return _clients[serviceName.trim()];
  }
}
