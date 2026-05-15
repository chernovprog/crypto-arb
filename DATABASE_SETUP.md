# PostgreSQL Primary / Replica — Docker Compose

Streaming replication setup using **PostgreSQL 16** with one primary
and one hot-standby replica.

```
postgres-primary  (:5432)  ──WAL stream──►  postgres-replica  (:5433)
```

---

## Quick start

```bash
# 1. Edit credentials if needed
#    (defaults are already set in .env)

# 2. Start services
docker compose up -d

# 3. Check status
docker compose ps
docker compose logs -f
```

---

## Verify replication

```bash
# On primary — should show 1 connected replica with state=streaming
docker exec -it postgres-primary \
  psql -U postgres -c "SELECT pid, usename, application_name, state, sent_lsn, replay_lsn FROM pg_stat_replication;"

# On replica — should return t (true = read-only standby)
docker exec -it postgres-replica \
  psql -U postgres -c "SELECT pg_is_in_recovery();"
```

Expected output:
```
 state    | sent_lsn  | replay_lsn
----------+-----------+------------
 streaming| 0/302E9F0 | 0/302E9F0   ← lag = 0, replication is live
```

### End-to-end data test

```bash
# Write on primary
docker exec -it postgres-primary \
  psql -U postgres -d mydb -c "CREATE TABLE test (id serial, val text); INSERT INTO test (val) VALUES ('hello from primary');"

# Read on replica (read-only)
docker exec -it postgres-replica \
  psql -U postgres -d mydb -c "SELECT * FROM test;"
```

---

## Files

| Path | Purpose |
|---|---|
| `docker-compose.yaml` | Service definitions |
| `.env` | Environment variables (credentials, ports) |
| `postgres/config/primary.conf` | PostgreSQL config for primary (`max_connections=200`, WAL settings) |
| `postgres/config/replica.conf` | PostgreSQL config for replica (`max_connections=200`, `hot_standby=on`) |
| `postgres/config/pg_hba.conf` | Client authentication rules (includes replication entry for `replicator`) |
| `postgres/scripts/primary-init.sh` | Creates the `replicator` role on first start |
| `postgres/scripts/replica-init.sh` | Placeholder — actual bootstrap is done via `pg_basebackup` in `command:` |

---

## How replica bootstrap works

On first start the replica container runs this sequence (see `command:` in `docker-compose.yaml`):

1. Waits until `postgres-primary` passes `pg_isready`.
2. Runs `pg_basebackup` as `root` to copy the full data directory from the primary. Running as root avoids Docker volume permission issues on Windows/WSL2.
3. Fixes directory ownership and permissions:
   ```
   chmod 0700 /var/lib/postgresql/data
   chown -R postgres:postgres /var/lib/postgresql/data
   ```
   This step is required because PostgreSQL refuses to start if the data directory is owned by root or has permissions wider than `0750`.
4. Hands off to `gosu postgres postgres -c config_file=...` so the server process runs as the unprivileged `postgres` user.

`pg_basebackup -R` automatically writes `standby.signal` and `primary_conninfo` into the data directory, so the replica starts in streaming replication mode without any extra configuration.

---

## Key configuration notes

### Why replica.conf sets max_connections = 200

PostgreSQL requires that `max_connections` on the replica is **greater than or equal to** the value on the primary. If it is lower, the replica aborts recovery with:

```
FATAL: recovery aborted because of insufficient parameter settings
DETAIL: max_connections = 100 is a lower setting than on the primary server, where its value was 200.
```

Both `postgres/config/primary.conf` and `postgres/config/replica.conf` set `max_connections = 200`.

### YAML block scalar: | vs >

The replica `command:` uses the literal block scalar `|` (preserves newlines), **not** the folded scalar `>` (collapses newlines into spaces). Using `>` caused multi-line `pg_basebackup` arguments to be interpreted as separate shell commands, resulting in:

```
pg_basebackup: error: must specify output directory or backup target
bash: line 9: -h: command not found
```

---

## Connecting

| Node | Host | Port | User | DB |
|---|---|---|---|---|
| Primary (read-write) | `localhost` | `5432` | `postgres` | `mydb` |
| Replica (read-only) | `localhost` | `5433` | `postgres` | `mydb` |

---

## Reducing healthcheck log noise

By default PostgreSQL logs every connection, including healthcheck probes which fire every 10 s. To reduce noise:

**Option 1 — disable connection logging** in `postgres/config/primary.conf` and `postgres/config/replica.conf`:
```ini
log_connections = off
log_disconnections = off
```

**Option 2 — increase healthcheck interval** in `docker-compose.yaml`:
```yaml
healthcheck:
  interval: 60s   # default is 10s
```

After either change, restart without wiping data:
```bash
docker compose restart
```

---

## Tear down

```bash
# Stop containers, keep volumes (data preserved)
docker compose down

# Full cleanup including all data
docker compose down -v
```

---

## Switching to synchronous replication

Edit `postgres/config/primary.conf`:

```ini
synchronous_commit = remote_apply
synchronous_standby_names = 'postgres-replica'
```

Then restart the primary:

```bash
docker compose restart postgres-primary
```
