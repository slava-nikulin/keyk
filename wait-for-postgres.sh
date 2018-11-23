#!/bin/sh
# wait-for-postgres.sh

set -e

host="$1"
shift
cmd="$@"
[ -z "$POSTGRES_USER" ] && usr="postgres" || usr="$POSTGRES_USER"

until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$host" -U "$usr" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 2
done

>&2 echo "Postgres is up! Creating db.."
bundle exec rails db:create
bundle exec rails db:migrate

>&2 echo "Executing command.."
exec $cmd
