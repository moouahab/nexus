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

enum ProjectLinkStatus implements _i1.SerializableModel {
  active,
  archived,
  detached;

  static ProjectLinkStatus fromJson(String name) {
    switch (name) {
      case 'active':
        return ProjectLinkStatus.active;
      case 'archived':
        return ProjectLinkStatus.archived;
      case 'detached':
        return ProjectLinkStatus.detached;
      default:
        return ProjectLinkStatus.active;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
