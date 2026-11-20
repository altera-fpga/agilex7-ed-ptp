#!/bin/bash
set -eux
DIR=$PWD
WORKDIR="$PWD/../"
TEST_NAME="$1"
SEQ_NAME="$2"

ROOTDIR="$WORKDIR/src/hw"
source ${ROOTDIR}/verification/env/arc_resource_list.sh
ARC_RESOURCE="${PYTHON} ${CMAKE} ${VCS} ${QUARTUS_VER}"

cd ${ROOTDIR}/verification/scripts

arc shell ${ARC_RESOURCE}  -- "export ROOTDIR=$ROOTDIR;source  $ROOTDIR/verification/env/setup.sh;make -f Makefile.mk run TESTNAME=$TEST_NAME SEQNAME=$SEQ_NAME"