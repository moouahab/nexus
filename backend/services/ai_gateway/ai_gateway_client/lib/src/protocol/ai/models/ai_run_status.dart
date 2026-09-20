/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

enum AiRunStatus implements _i1.SerializableModel {
  queued,
  planning,
  collectingEvidence,
  drafting,
  verifying,
  criticizing,
  revising,
  validating,
  running,
  completed,
  needsInformation,
  needsHumanApproval,
  rejected,
  failed,
  cancelled,
  unsupported;

  static AiRunStatus fromJson(String name) {
    switch (name) {
      case 'queued':
        return AiRunStatus.queued;
      case 'planning':
        return AiRunStatus.planning;
      case 'collectingEvidence':
        return AiRunStatus.collectingEvidence;
      case 'drafting':
        return AiRunStatus.drafting;
      case 'verifying':
        return AiRunStatus.verifying;
      case 'criticizing':
        return AiRunStatus.criticizing;
      case 'revising':
        return AiRunStatus.revising;
      case 'validating':
        return AiRunStatus.validating;
      case 'running':
        return AiRunStatus.running;
      case 'completed':
        return AiRunStatus.completed;
      case 'needsInformation':
        return AiRunStatus.needsInformation;
      case 'needsHumanApproval':
        return AiRunStatus.needsHumanApproval;
      case 'rejected':
        return AiRunStatus.rejected;
      case 'failed':
        return AiRunStatus.failed;
      case 'cancelled':
        return AiRunStatus.cancelled;
      case 'unsupported':
        return AiRunStatus.unsupported;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "AiRunStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
