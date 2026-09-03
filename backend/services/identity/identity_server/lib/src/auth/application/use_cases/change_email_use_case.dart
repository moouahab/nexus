import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/auth_session_repository.dart';
import '../interfaces/email_policy.dart';
import '../interfaces/identity_provider_repository.dart';
import '../interfaces/identity_repository.dart';
import '../services/email_verification_service.dart';

class ChangeEmailUseCase {
  const ChangeEmailUseCase({
    required IdentityRepository identityRepository,
    required IdentityProviderRepository identityProviderRepository,
    required AuthSessionRepository authSessionRepository,
    required EmailPolicy emailPolicy,
    required EmailVerificationService emailVerificationService,
  }) : _identityRepository = identityRepository,
       _identityProviderRepository = identityProviderRepository,
       _authSessionRepository = authSessionRepository,
       _emailPolicy = emailPolicy,
       _emailVerificationService = emailVerificationService;

  final IdentityRepository _identityRepository;
  final IdentityProviderRepository _identityProviderRepository;
  final AuthSessionRepository _authSessionRepository;
  final EmailPolicy _emailPolicy;
  final EmailVerificationService _emailVerificationService;

  Future<protocol.Identity> execute(
    Session session, {
    required UuidValue identityId,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    _emailPolicy.validate(normalizedEmail);

    final identity = await _identityRepository.findById(session, identityId);
    if (identity == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.identityNotFound,
      );
    }
    if (identity.status != protocol.IdentityStatus.active) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.identityNotActive,
      );
    }

    final existingIdentity = await _identityRepository.findByEmail(
      session,
      normalizedEmail,
    );
    if (existingIdentity != null && existingIdentity.id != identityId) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.emailAlreadyExists,
      );
    }

    final updatedIdentity = await _identityRepository.updateEmail(
      session,
      id: identityId,
      email: normalizedEmail,
      emailVerified: false,
    );
    if (updatedIdentity == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.identityNotFound,
      );
    }

    await _identityProviderRepository.updateEmailForIdentity(
      session,
      identityId: identityId,
      email: normalizedEmail,
      emailVerified: false,
    );
    await _emailVerificationService.start(session, identity: updatedIdentity);
    await _authSessionRepository.revokeAllForIdentity(session, identityId);

    return updatedIdentity;
  }
}
