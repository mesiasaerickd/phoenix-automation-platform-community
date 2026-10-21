#!/bin/sh
# AWX Operator-compatible subset for FRESH disposable databases only.
set -eu
export PGDATA="${PGDATA:-/var/lib/pgsql/data}"
db_user="${POSTGRESQL_USER:-${POSTGRES_USER:-postgres}}"
db_name="${POSTGRESQL_DATABASE:-${POSTGRES_DB:-postgres}}"
db_pass="${POSTGRESQL_PASSWORD:-${POSTGRES_PASSWORD:-}}"
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    if [ -n "$(ls -A "$PGDATA" 2>/dev/null)" ]; then
        echo "BLOCKED: unrecognized non-empty PGDATA" >&2
        exit 1
    fi
    : "${db_pass:?Set POSTGRESQL_PASSWORD or POSTGRES_PASSWORD}"
    umask 077
    pwfile="$(mktemp)"
    trap 'rm -f "$pwfile"' EXIT
    printf '%s\n' "$db_pass" > "$pwfile"
    /usr/bin/initdb -D "$PGDATA" -U "$db_user" --pwfile="$pwfile" --auth-local=scram-sha-256 --auth-host=scram-sha-256
    rm -f "$pwfile"
    trap - EXIT
    printf '\nlisten_addresses = '\''*'\''\n' >> "$PGDATA/postgresql.conf"

    : "${PAP_POSTGRES_ALLOWED_CIDR:?Set PAP_POSTGRES_ALLOWED_CIDR}"

    python3 - "$PAP_POSTGRES_ALLOWED_CIDR" <<'VALIDATE_CIDR'
import ipaddress
import sys
network = ipaddress.ip_network(sys.argv[1], strict=True)
if network.prefixlen == 0:
    raise SystemExit("CIDR demasiado amplio")
print("POSTGRES_ALLOWED_NETWORK=" + str(network))
VALIDATE_CIDR

    printf 'host awx awx %s scram-sha-256\n'         "$PAP_POSTGRES_ALLOWED_CIDR" >> "$PGDATA/pg_hba.conf"

    # Create AWX database locally only. Fails closed if initialization is incomplete.
    if [ "$db_name" != postgres ]; then
        /usr/bin/pg_ctl -D "$PGDATA" -o '-c listen_addresses=127.0.0.1 -c unix_socket_directories=/run/postgresql' -w start
        if ! PGPASSWORD="$db_pass" /usr/bin/createdb -h /run/postgresql -U "$db_user" "$db_name"; then
            /usr/bin/pg_ctl -D "$PGDATA" -m immediate stop
            exit 1
        fi
        /usr/bin/pg_ctl -D "$PGDATA" -m fast -w stop
    fi
fi
exec /usr/bin/postgres -D "$PGDATA" -c unix_socket_directories=/run/postgresql
