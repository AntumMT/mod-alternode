#!/bin/bash

DOCS="$(dirname $(readlink -f $0))"
ROOT="$(dirname ${DOCS})"
CONFIG="${DOCS}/config.ld"

cd "${ROOT}"

# Clean old files
rm -rf "${DOCS}/api.html" "${DOCS}/scripts" "${DOCS}/modules" "${DOCS}/data"
# Create new files
ldoc -c "${CONFIG}" -d "${DOCS}" -o "api" "${ROOT}"
