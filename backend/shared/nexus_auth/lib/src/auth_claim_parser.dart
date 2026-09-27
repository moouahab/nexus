import 'auth_claim_names.dart';
import 'nexus_auth_exception.dart';

DateTime dateTimeFromEpochSeconds(dynamic value) {
  return DateTime.fromMillisecondsSinceEpoch(
    (value as int) * 1000,
    isUtc: true,
  );
}

List<String> stringListClaim(Map<String, dynamic> claims, String name) {
  final value = claims[name];
  if (value is List) {
    return value.cast<String>();
  }
  if (value is String) {
    return value
        .split(' ')
        .map((scope) => scope.trim())
        .where((scope) => scope.isNotEmpty)
        .toList(growable: false);
  }
  throw NexusAuthException.invalidAccessToken('Invalid "$name" claim.');
}

List<String> audienceClaim(Map<String, dynamic> claims) {
  final value = claims[AuthClaimNames.audience];
  if (value is String) return [value];
  if (value is List) return value.cast<String>();
  throw const NexusAuthException.invalidAccessToken('Invalid audience claim.');
}

String singleAudienceClaim(Map<String, dynamic> claims) {
  final audiences = audienceClaim(claims);
  if (audiences.length != 1) {
    throw const NexusAuthException.invalidAccessToken(
      'Access token must contain exactly one audience.',
    );
  }
  return audiences.single;
}
