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
import 'package:serverpod/serverpod.dart' as _i1;

enum ProjectEventKind implements _i1.SerializableModel {
  created,
  updated,
  statusChanged,
  linked,
  unlinked,
  participantAdded,
  participantUpdated,
  participantRemoved,
  archived,
  restored,
  note;

  static ProjectEventKind fromJson(String name) {
    switch (name) {
      case 'created':
        return ProjectEventKind.created;
      case 'updated':
        return ProjectEventKind.updated;
      case 'statusChanged':
        return ProjectEventKind.statusChanged;
      case 'linked':
        return ProjectEventKind.linked;
      case 'unlinked':
        return ProjectEventKind.unlinked;
      case 'participantAdded':
        return ProjectEventKind.participantAdded;
      case 'participantUpdated':
        return ProjectEventKind.participantUpdated;
      case 'participantRemoved':
        return ProjectEventKind.participantRemoved;
      case 'archived':
        return ProjectEventKind.archived;
      case 'restored':
        return ProjectEventKind.restored;
      case 'note':
        return ProjectEventKind.note;
      default:
        return ProjectEventKind.note;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
