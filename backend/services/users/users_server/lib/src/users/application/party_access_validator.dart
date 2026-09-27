import 'package:serverpod/serverpod.dart';

abstract interface class PartyAccessValidator {
  Future<bool> canUseParty({
    required UuidValue partyId,
    required String? bearerToken,
  });
}

final class UnavailablePartyAccessValidator implements PartyAccessValidator {
  const UnavailablePartyAccessValidator();

  @override
  Future<bool> canUseParty({
    required UuidValue partyId,
    required String? bearerToken,
  }) async => false;
}
