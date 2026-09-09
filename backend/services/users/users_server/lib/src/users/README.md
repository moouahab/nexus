# Users Service

`users_server` owns functional NEXUS human profiles.

It owns:

- user profiles linked to Identity by `identityId`;
- profile display data;
- profile preferences and descriptive metadata;
- the preferred party UUID as an external reference when needed.

It does not own authentication or business parties. Identity remains
responsible for login, sessions, tokens, password, email verification, and
OAuth. Parties owns companies, associations, consultant practices, and
memberships.

## Current Model Shape

- `UserProfile`: one functional profile for a connected technical identity.

`primaryPartyId` is an external UUID owned by the parties service. Users stores
that preference but does not validate or mutate party data directly.
