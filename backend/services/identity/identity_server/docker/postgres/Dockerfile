FROM pgvector/pgvector:pg16

COPY entrypoint-secure.sh /usr/local/bin/nexus-postgres-entrypoint

RUN chmod 0555 /usr/local/bin/nexus-postgres-entrypoint

ENTRYPOINT ["/usr/local/bin/nexus-postgres-entrypoint"]
CMD ["postgres"]