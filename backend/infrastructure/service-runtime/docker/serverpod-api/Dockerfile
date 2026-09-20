# Build stage
FROM dart:3.8.0 AS build

ARG SERVER_PACKAGE
ARG CLIENT_PACKAGE

WORKDIR /app
COPY --from=nexus_auth . /shared/nexus_auth
COPY pubspec.yaml pubspec.lock ./
COPY ${CLIENT_PACKAGE}/pubspec.yaml ${CLIENT_PACKAGE}/pubspec.yaml
COPY ${SERVER_PACKAGE}/pubspec.yaml ${SERVER_PACKAGE}/pubspec.yaml
RUN dart pub get

COPY ${SERVER_PACKAGE} ${SERVER_PACKAGE}
COPY ${CLIENT_PACKAGE} ${CLIENT_PACKAGE}

WORKDIR /app/${SERVER_PACKAGE}
RUN dart compile exe bin/main.dart -o bin/server

RUN mkdir -p config web migrations \
  && rm -f config/passwords.yaml

# Final stage
FROM alpine:3.22

ARG SERVER_PACKAGE
ARG RUNTIME_USER
ARG ENTRYPOINT_TARGET

WORKDIR /app

ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

COPY --from=build /runtime/ /

COPY --from=build /app/${SERVER_PACKAGE}/bin/server server
COPY --from=service_runtime entrypoint.sh ${ENTRYPOINT_TARGET}
RUN chmod 0555 ${ENTRYPOINT_TARGET}

COPY --from=build /app/${SERVER_PACKAGE}/config/ config-defaults/
COPY --from=build /app/${SERVER_PACKAGE}/config/ config/
COPY --from=build /app/${SERVER_PACKAGE}/web/ web/
COPY --from=build /app/${SERVER_PACKAGE}/migrations/ migrations/
COPY --from=build /app/${SERVER_PACKAGE}/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

RUN getent group ${RUNTIME_USER} >/dev/null || addgroup -S ${RUNTIME_USER} \
  && id -u ${RUNTIME_USER} >/dev/null 2>&1 || adduser -S -G ${RUNTIME_USER} -H -h /app ${RUNTIME_USER} \
  && chown -R ${RUNTIME_USER}:${RUNTIME_USER} /app

EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

USER ${RUNTIME_USER}

ENTRYPOINT ["/usr/local/bin/serverpod-api-entrypoint"]
