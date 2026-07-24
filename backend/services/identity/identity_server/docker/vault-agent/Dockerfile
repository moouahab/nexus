FROM hashicorp/vault:1.17

USER root

COPY entrypoint.sh /usr/local/bin/vault-agent-entrypoint

RUN mkdir -p /vault/token /vault/secrets /vault/templates /vault/runtime /vault/tls \
  && chown -R vault:vault /vault/token /vault/secrets /vault/templates /vault/runtime /vault/tls \
  && chmod 0555 /usr/local/bin/vault-agent-entrypoint

USER vault

ENTRYPOINT ["/usr/local/bin/vault-agent-entrypoint"]
CMD ["agent", "-config=/vault/config/agent.hcl"]
