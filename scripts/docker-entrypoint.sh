#!/usr/bin/env sh
set -eu

PUID="${PUID:-0}"
PGID="${PGID:-0}"
APP_USER="${APP_USER:-lncrawl}"
APP_GROUP="${APP_GROUP:-lncrawl}"
DATA_DIR="${LNCRAWL_DATA_PATH:-/data}"

mkdir -p "${DATA_DIR}"

if [ "${PUID}" != "0" ] || [ "${PGID}" != "0" ]; then
    if ! getent group "${PGID}" >/dev/null 2>&1; then
        groupadd -g "${PGID}" "${APP_GROUP}" >/dev/null 2>&1 || true
    fi

    if ! getent passwd "${PUID}" >/dev/null 2>&1; then
        useradd -u "${PUID}" -g "${PGID}" -M -s /usr/sbin/nologin "${APP_USER}" >/dev/null 2>&1 || true
    fi

    chown -R "${PUID}:${PGID}" "${DATA_DIR}" 2>/dev/null || true
    exec setpriv --reuid "${PUID}" --regid "${PGID}" --clear-groups /app/.venv/bin/python -m lncrawl "$@"
fi

exec /app/.venv/bin/python -m lncrawl "$@"
