import '../../domain/service_client_registration.dart';

abstract interface class ServiceClientRegistry {
  ServiceClientRegistration? findByServiceName(String serviceName);
}
