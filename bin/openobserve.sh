#!/usr/bin/env bash
set -euo pipefail

export ZO_ROOT_USER_EMAIL="${ZO_ROOT_USER_EMAIL:-admin@admin.com}"
export ZO_ROOT_USER_PASSWORD="${ZO_ROOT_USER_PASSWORD:-adminadmin}"

exec openobserve "$@"
