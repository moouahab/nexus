import 'dart:io';

import '../application/party_access_validator.dart';
import 'http_party_access_validator.dart';

final class PartyAccessValidatorFactory {
  const PartyAccessValidatorFactory._();

  static PartyAccessValidator fromEnvironment([
    Map<String, String>? environment,
  ]) {
    final env = environment ?? Platform.environment;
    final rawUrl = env['PARTIES_BASE_URL'];
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return const UnavailablePartyAccessValidator();
    }
    return HttpPartyAccessValidator(baseUri: Uri.parse(rawUrl));
  }
}
