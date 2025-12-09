#!/usr/bin/env bash
cd "$(dirname "$0")"
export FACTOR_ROOTS="$PWD"
exec factor -e='"maxrectangle/maxrectangle.factor" run-file'
