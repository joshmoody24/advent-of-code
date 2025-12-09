#!/usr/bin/env bash
cd "$(dirname "$0")"
export FACTOR_ROOTS="$PWD"

if [[ -n "$1" ]]; then
    exec factor -e="\"$1\" run-file"
else
    exec factor
fi
