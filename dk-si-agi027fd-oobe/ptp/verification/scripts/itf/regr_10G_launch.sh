/usr/intel/bin/bash
#1 source env.sh and setup.sh for Makefile qsys/rtl and build
export ITF_DIR_PATH="/p/psg/pac/release/main/github/psgpac/sed/regression_test/simulation/1588_ptp_agx7_fm87/10g_non_anlt/applications.fpga.system-example-designs.agilex7-ed-ptp/dk-si-agi027fd-oobe/ptp/verification/scripts/itf"
export REG_LOCAL_ROOT_DIR_PATH="$(realpath "$ITF_DIR_PATH/../..")"
#export SCR_DIR_PATH=$ITF_DIR_PATH/../
source $REG_LOCAL_ROOT_DIR_PATH/env/env.sh
echo "Executing env10G.sh"
#/usr/intel/bin/bash 
source $REG_LOCAL_ROOT_DIR_PATH/env/setup.sh
cd $REG_LOCAL_ROOT_DIR_PATH/scripts/ && /p/psg/flows/sw/make_altera/4.3/linux64/gmake -f Makefile.mk cmplib HSSI_10G=1 | tee cmp.log && /p/psg/flows/sw/make_altera/4.3/linux64/gmake -f Makefile.mk build HSSI_10G=1 
#2 Cleanup old files, launch regression through ITF flow and generate Spetc report
cd $REG_LOCAL_ROOT_DIR_PATH/scripts/itf
/p/psg/flows/sw/regutils/23.4/5/linux64/bin/reg_reset
/p/psg/flows/sw/regutils/23.4/5/linux64/bin/reg_exe --farm --title="SIM-AGX7-FTILEPTP_10G" --regr_cfg=sanity_regr
