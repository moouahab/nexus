# Projects Service

Projects Service is the central registry for Nexus workspaces. It owns project
lifecycle, metadata, archive state, and references to external domain resources.
It does not implement mission, lab, data, document, or history business logic.

## Model Shape

- `Project`: workspace registry entry and lifecycle state.
- `ProjectLink`: lightweight reference from a project to another service-owned
  resource.
- `ProjectArchiveEntry`: immutable archive/restore lifecycle record.
- `ProjectEvent`: timeline entry for registry-level activity.
- `ProjectParticipant`: Nexus members, client organization, and client
  referents attached to a project.

## Boundaries

- Missions, labs, datasets, documents, and history stay owned by their own
  services.
- Projects stores resource references through `service`, `kind`, and
  `externalId`.
- Project rules are centralized in `ProjectRegistryPolicy` with maps and sets so
  future use cases do not duplicate status/link branching logic.

## Endpoint Behavior

- `project.createProject`: creates a registry entry and writes a `created`
  timeline event.
- `project.listProjects`: lists projects, optionally filtered by status.
- `project.getProject` / `project.getProjectBySlug`: reads one project.
- `project.updateProjectProfile`: updates editable metadata and writes an
  `updated` event.
- `project.changeProjectStatus`: applies declared status transitions and writes
  a `statusChanged` event.
- `project.archiveProject`: moves a project to `archived`, creates an archive
  entry, and writes an `archived` event.
- `project.restoreProject`: restores an archived project to `active`, closes the
  latest archive entry, and writes a `restored` event.
- `project.linkResource`: attaches an external resource reference and writes a
  `linked` event.
- `project.detachLink`: marks a link as `detached` and writes an `unlinked`
  event.
- `project.assignProjectMember`: attaches the Nexus-side person doing the work.
- `project.setProjectClient`: attaches the client organization.
- `project.setClientReferent`: attaches the primary client referent.
- `project.listParticipants` / `project.removeParticipant`: read and soft-remove
  human/project relationships.
- `project.listLinks` / `project.listEvents`: read project references and
  timeline.
