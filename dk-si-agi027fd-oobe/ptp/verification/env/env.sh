########################################################################
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
########################################################################

#######################################
###  Environment setup for Rootport
#######################################
#check for $PTP_ROOTDIR and set to cloned repo toplevel path
echo "Setting PTP_ROOTDIR"

if test -n "$BASH" ; then SCRIPT_NAME=$BASH_SOURCE
elif test -n "$TMOUT"; then SCRIPT_NAME=${.sh.file}
elif test -n "$ZSH_NAME" ; then SCRIPT_NAME=${(%):-%x}
elif test ${0##*/} = dash; then x=$(lsof -p $$ -Fn0 | tail -1); SCRIPT_NAME=${x#n}
else SCRIPT_NAME=$0
fi

SCRIPT_DIR="$(cd "$(dirname -- "$SCRIPT_NAME")" 2>/dev/null && pwd -P)"

export PTP_ROOTDIR=$(readlink -f ${SCRIPT_DIR}/../)
unset SCRIPT_DIR

echo "PTP_ROOTDIR         " $PTP_ROOTDIR

source ${PTP_ROOTDIR}/env/arc_resource_list.sh

ARC_RESOURCE="${PYTHON} ${GCC} ${CMAKE} ${VCS} ${QUARTUS_VER}"

echo "arc shell ${ARC_RESOURCE}"
arc shell ${ARC_RESOURCE}

