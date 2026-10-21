#!/bin/sh
set -e

if [ "$#" -eq 0 ]; then
    set -- redis-server
fi

if [ "$1" = "redis-server" ]; then
    shift
    exec redis-server "$@"
fi

exec "$@"
