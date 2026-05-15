#!/usr/bin/env bash
# scripts/replica-init.sh
# This file is present so Docker does not error on the mount.
# Actual replica bootstrapping is handled by the `command:` in docker-compose.yaml
# via pg_basebackup, which writes standby.signal and recovery settings automatically.

echo ">>> Replica init script — nothing extra to do here."
