#!/bin/sh
set -eu

while true; do
  if [ "$DEPENDENCY_PROTOCOL" = postgres ]; then
    dependency_response="$(printf '\000\000\000\010\004\322\026\057' | nc -w 1 "$DEPENDENCY_HOST" "$DEPENDENCY_PORT" || true)"
  else
    dependency_response="$(printf '*1\r\n$4\r\nPING\r\n' | nc -w 1 "$DEPENDENCY_HOST" "$DEPENDENCY_PORT" || true)"
  fi
  if [ -n "$dependency_response" ]; then
    response='HTTP/1.1 200 OK\r\nContent-Length: 3\r\nConnection: close\r\n\r\nOK\n'
  else
    response='HTTP/1.1 503 Service Unavailable\r\nContent-Length: 5\r\nConnection: close\r\n\r\nDOWN\n'
  fi
  printf "$response" | nc -l -p 8080
done
