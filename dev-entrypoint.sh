#!/bin/bash
# Interpreter identifier

set -e
# Exit on fail

BUNDLE_PATH="/bundle"
UNDLE_BIN=$(which bundle)
GEM_HOME="/bundle"
PATH="${BUNDLE_BIN}:${PATH}"

bundle check || bundle install --binstubs="$BUNDLE_BIN"
# Ensure all gems installed. Add binstubs to bin which has been added to PATH in Dockerfile.

[ -z "$POSTGRES_USER" ] && usr="postgres" || usr="$POSTGRES_USER"

until pg_isready -h "db" -U "postgres"; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 2
done
>&2 echo "Postgres is up!"

exec "$@"
# Finally call command issued to the docker service
