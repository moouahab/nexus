FROM redis:6.2.6

COPY entrypoint-secure.sh /usr/local/bin/redis-secure-entrypoint

RUN chmod 0555 /usr/local/bin/redis-secure-entrypoint

USER redis

ENTRYPOINT ["/usr/local/bin/redis-secure-entrypoint"]
