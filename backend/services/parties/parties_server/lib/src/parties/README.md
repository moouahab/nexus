# Parties Service

`parties_server` owns business actors and the membership links between user
profiles and those actors.

It owns:

- companies;
- associations;
- consultant practices;
- memberships between `users.UserProfile` ids and parties.

It does not own authentication or human profile details. Identity owns login and
Users owns the functional human profile.

