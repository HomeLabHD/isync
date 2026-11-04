#!/bin/sh
# Flags go to mbsync; anything else (sh, a script) runs as given.
set -eu
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    set -- mbsync "$@"
fi
exec "$@"
