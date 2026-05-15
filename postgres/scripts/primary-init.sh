#!/usr/bin/env bash
# postgres/scripts/primary-init.sh
# Runs once during primary container initialization (initdb phase).

set -euo pipefail

REPLICATION_USER="${POSTGRES_REPLICATION_USER:-replicator}"
REPLICATION_PASSWORD="${POSTGRES_REPLICATION_PASSWORD:-replication_secret}"

echo ">>> Creating replication user: ${REPLICATION_USER}"

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${REPLICATION_USER}') THEN
            CREATE ROLE "${REPLICATION_USER}"
                WITH REPLICATION LOGIN
                ENCRYPTED PASSWORD '${REPLICATION_PASSWORD}';
            RAISE NOTICE 'Replication user "${REPLICATION_USER}" created.';
        ELSE
            RAISE NOTICE 'Replication user "${REPLICATION_USER}" already exists, skipping.';
        END IF;
    END
    \$\$;
EOSQL

echo ">>> Primary initialization complete."
