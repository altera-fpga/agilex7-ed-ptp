#!/bin/bash
set -eux
DIR=$PWD
WORKDIR="$PWD/../"
ROOTDIR="$WORKDIR/src/hw"
source ${ROOTDIR}/verification/env/arc_resource_list.sh
ARC_RESOURCE="${PYTHON} ${CMAKE} ${VCS} ${QUARTUS_VER}"

cd ${ROOTDIR}/verification/scripts
arc shell ${ARC_RESOURCE}  -- "export ROOTDIR=$ROOTDIR;source  $ROOTDIR/verification/env/setup.sh;make -f Makefile.mk cmplib HSSI_25G=1;make -f Makefile.mk build HSSI_25G=1"


