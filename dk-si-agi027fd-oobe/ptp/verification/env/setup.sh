########################################################################
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
########################################################################
# Contais TB ENV Varibales used for Simulation
########################################################################

if test -n "$BASH" ; then SCRIPT_NAME=$BASH_SOURCE
elif test -n "$TMOUT"; then SCRIPT_NAME=${.sh.file}
elif test -n "$ZSH_NAME" ; then SCRIPT_NAME=${(%):-%x}
elif test ${0##*/} = dash; then x=$(lsof -p $$ -Fn0 | tail -1); SCRIPT_NAME=${x#n}
else SCRIPT_NAME=$0
fi

SCRIPT_DIR="$(cd "$(dirname -- "$SCRIPT_NAME")" 2>/dev/null && pwd -P)"

export PTP_ROOTDIR=$(readlink -f ${SCRIPT_DIR}/..)
#unset SCRIPT_DIR

export WORKDIR=PTP_ROOTDIR
export DESIGN_DIR=$PTP_ROOTDIR/../src
export QUARTUS_HOME=$QUARTUS_ROOTDIR
export QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
export QUARTUS_ROOTDIR_OVERRIDE=$QUARTUS_ROOTDIR
export IMPORT_IP_ROOTDIR=$QUARTUS_ROOTDIR/../ip
export DESIGNWARE_HOME=/p/psg/EIP/synopsys/vip_common/vip_W-2025.03C
export https_proxy=http://proxy-chain.intel.com:912
export http_proxy=http://proxy-chain.intel.com:911
export BOARD_TYPE=devkit_fm87 
export QUARTUS_DEVICE=AGIB027R31B1E2V
export UVM_HOME=$VCS_HOME/etc/uvm-1.2
export SYNTH_DIR=$PTP_ROOTDIR/../synth


echo "VCS                 " $VCS_HOME
echo "QUARTUS_HOME        " $QUARTUS_HOME
echo "IMPORT_IP_ROOTDIR   " $IMPORT_IP_ROOTDIR
echo "PTP_ROOTDIR         " $PTP_ROOTDIR
echo "SCRIPT_DIR          " $SCRIPT_DIR
echo "DESIGN_DIR          " $DESIGN_DIR
echo "SYNTH_DIR           " $SYNTH_DIR

