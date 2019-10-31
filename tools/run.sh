#!/usr/bin/env bash

set -o errexit
(
  cd "$(dirname "$0")/../app"

  if [[ ! -d staticfiles ]]; then python manage.py collectstatic --noinput; fi

  python manage.py wait_for_db
  python manage.py migrate
  python manage.py create_roles

  if [[ -n "${ADMIN_USERNAME}" ]] && [[ -n "${ADMIN_EMAIL}" ]] && [[ -n "${ADMIN_PASSWORD}" ]]; then
    python manage.py create_admin --noinput --username="${ADMIN_USERNAME}" --email="${ADMIN_EMAIL}" --password="${ADMIN_PASSWORD}"
  fi

  gunicorn --bind="0.0.0.0:${PORT:-8000}" --workers="${WORKERS:-1}" app.wsgi --timeout=300
)
