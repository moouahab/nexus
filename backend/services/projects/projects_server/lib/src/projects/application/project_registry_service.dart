import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../domain/project_registry_policy.dart';

part 'project_registry_support.part.dart';
part 'project_catalog_service.part.dart';
part 'project_lifecycle_service.part.dart';
part 'project_participant_service.part.dart';
part 'project_link_service.part.dart';
part 'project_access_service.part.dart';

class ProjectRegistryService extends _ProjectAccessService {
  const ProjectRegistryService({super.policy});
}
