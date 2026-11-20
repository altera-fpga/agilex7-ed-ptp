#!/bin/sh
# Thin wrapper: default DESIGN if unset, then reuse ANLT/NON-ANLT HW builder
set -eux
DESIGN="${DESIGN:-25G_ANLT}"
export DESIGN
exec "$(dirname "$0")/build-hw-anlt.sh"
