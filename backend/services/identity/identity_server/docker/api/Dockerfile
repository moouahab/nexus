# Build from the identity workspace root with:
# docker build -f identity_server/docker/api/Dockerfile .

# Build stage
FROM dart:3.8.0 AS build

# Copy the Dart workspace metadata first to keep dependency resolution cacheable.
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
COPY identity_client/pubspec.yaml identity_client/pubspec.yaml
COPY identity_server/pubspec.yaml identity_server/pubspec.yaml
RUN dart pub get

# Copy the workspace packages.
COPY identity_server identity_server
COPY identity_client identity_client

# Compile the server executable.
WORKDIR /app/identity_server
RUN dart compile exe bin/main.dart -o bin/server

# Add a fallback for the copy of possibly missing directories.
RUN mkdir -p config web migrations \
  && rm -f config/passwords.yaml

# Final stage
FROM alpine:3.22
WORKDIR /app

# Environment variables
ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

# Copy runtime dependencies
COPY --from=build /runtime/ /

# Copy compiled server executable
COPY --from=build /app/identity_server/bin/server server
COPY identity_server/docker/api/entrypoint.sh /usr/local/bin/identity-server-entrypoint
RUN chmod 0555 /usr/local/bin/identity-server-entrypoint

# Copy configuration files and resources
COPY --from=build /app/identity_server/config/ config/
COPY --from=build /app/identity_server/web/ web/
COPY --from=build /app/identity_server/migrations/ migrations/

# This file is required to enable the endpoint log filter in Insights.
COPY --from=build /app/identity_server/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

# Expose ports
EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

# Define the entrypoint command
ENTRYPOINT ["/usr/local/bin/identity-server-entrypoint"]
