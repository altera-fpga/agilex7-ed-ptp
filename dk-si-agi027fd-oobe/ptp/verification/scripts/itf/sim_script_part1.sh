#!/bin/bash
# Variables
speed_size="$1"


# Clean build artifacts
#cd $REG_LOCAL_ROOT_DIR_PATH/scripts && /p/psg/flows/sw/make_altera/4.3/linux64/gmake -f Makefile.mk clean
#cd $CURR_DIR

# Check if input is empty
if [ -z "$speed_size" ]; then
    echo "Usage: $0 {10g|25g|50g|100g}"
    exit 1
fi

# Convert input to lowercase
speed_size=$(echo "$speed_size" | tr '[:upper:]' '[:lower:]')

if [ "$speed_size" = "10g" ]; then
    echo "Running job with 10g"

    export CURR_DIR="/p/psg/pac/release/main/github/psgpac/sed/regression_test/simulation/1588_ptp_agx7_fm87/10g_non_anlt/applications.fpga.system-example-designs.agilex7-ed-ptp/dk-si-agi027fd-oobe/ptp/verification/scripts/itf"
    SIM_REPO_PATH="$(realpath "$CURR_DIR/../..")"
    export REG_LOCAL_ROOT_DIR_PATH="$SIM_REPO_PATH"
    SIM_SCRIPTS_PATH="$CURR_DIR"
    GIT_REPO_PATH="$(realpath "$SIM_REPO_PATH/../../..")"
    SIM_LAUNCH_10G_FILE="$SIM_REPO_PATH/scripts/itf/regr_10G_launch.sh"
    SIM_RUN_LAUNCH_10G_FILE="$SIM_REPO_PATH/scripts/itf/run_regr_10G_launch.sh"
    SIM_OUTPUT_10G_FILE="$SIM_SCRIPTS_PATH/SIM_SED_FPTP_PDK_10G_STDOUT.out"
    SIM_LOG_10G_FILE="$SIM_SCRIPTS_PATH/SIM_SED_FPTP_PDK_10G_LOG.out"



    # Cleanup files
    rm -rf $SIM_RUN_LAUNCH_10G_FILE
    rm -rf $SIM_OUTPUT_10G_FILE
    rm -rf $SIM_LOG_10G_FILE
    rm -rf t.log

    # git pull repo
    echo " Executng test cmd"
    echo "cd $SIM_REPO_PATH"
    echo "/usr/intel/bin/git pull" >> $SIM_OUTPUT_10G_FILE
    test_cmd=$(cd $GIT_REPO_PATH; /usr/intel/bin/git pull)
    echo -ne "# " >> $SIM_OUTPUT_10G_FILE
    echo "$test_cmd" >> $SIM_OUTPUT_10G_FILE
    echo "" >> $SIM_OUTPUT_10G_FILE

    # Copy launch file
    cp $SIM_LAUNCH_10G_FILE $SIM_RUN_LAUNCH_10G_FILE

    ### Update REG_LOCAL_ROOT_DIR_PATH
    #sed -i "s#^export REG_LOCAL_ROOT_DIR_PATH=.*#export REG_LOCAL_ROOT_DIR_PATH=$SIM_REPO_PATH" "$SIM_RUN_LAUNCH_FILE"

    ## Temp file to hold modified contents
    TMP_FILE=$(mktemp)

    ## Path prefix to match
    PREFIX="/p/psg/flows/sw/regutils/23.4/5/linux64/bin/reg_exe"

    awk -v prefix="$PREFIX" '
    {
        # If line starts with the known prefix
        if (index($0, prefix) == 1) {
            # Escape any double quotes for the echo part
            gsub(/"/, "\\\"", $0)
            echo_part = "echo \"" $0 "\" >> '${SIM_OUTPUT_10G_FILE}'"
   
            # Undo quote escaping for actual execution part
            gsub(/\\"/, "\"", $0)
            exec_part = $0 " >> '${SIM_OUTPUT_10G_FILE}'"

            # Print the combined output
            print echo_part " && " exec_part
        } else {
            # Print the line as-is
            print $0
        }
    }' "$SIM_RUN_LAUNCH_10G_FILE" > "$TMP_FILE"
    cat $TMP_FILE

    #sleep 1
    #
    ## Overwrite the original file
    mv "$TMP_FILE" "$SIM_RUN_LAUNCH_10G_FILE"

    rm -rf "$TMP_FILE"

    chmod +x $SIM_RUN_LAUNCH_10G_FILE


    #sleep 10m
    # submit job to arc
    echo "/p/psg/ctools/arc/2019.1/bin/arc submit vcs-vcsmx-lic,acds/26.1,devacds/23.4,testutils/23.4/79,regutils/23.4,itf/23.4,ostype/suse15,synopsys_vip_common/vip_W-2025.03C,p4/psgeng,perl/5.8.8,python/3.7.7/1,vcsmx/X-2025.06-SP1-1  -- '${SIM_RUN_LAUNCH_10G_FILE}'" >> $SIM_OUTPUT_10G_FILE
    test_cmd=$(/p/psg/ctools/arc/2019.1/bin/arc submit flow/sw/bigmem vcs-vcsmx-lic,acds/26.1,devacds/23.4,testutils/23.4/79,regutils/23.4,itf/23.4,ostype/suse15,synopsys_vip_common/vip_W-2025.03C,p4/psgeng,perl/5.8.8,python/3.7.7/1,vcsmx/X-2025.06-SP1-1 mem=32000  -- "$SIM_RUN_LAUNCH_10G_FILE")
    echo -ne "# ARC Job Id: " >> $SIM_OUTPUT_10G_FILE
    echo "$test_cmd" >> $SIM_OUTPUT_10G_FILE
    echo "" >> $SIM_OUTPUT_10G_FILE

elif [ "$speed_size" = "25g" ]; then
    echo "Running job with 25g "

    export CURR_DIR="/p/psg/pac/release/main/github/psgpac/sed/regression_test/simulation/1588_ptp_agx7_fm87/25g_non_anlt/applications.fpga.system-example-designs.agilex7-ed-ptp/dk-si-agi027fd-oobe/ptp/verification/scripts/itf"
    SIM_REPO_PATH="$(realpath "$CURR_DIR/../..")"
    export REG_LOCAL_ROOT_DIR_PATH="$SIM_REPO_PATH"
    SIM_SCRIPTS_PATH="$CURR_DIR"
    GIT_REPO_PATH="$(realpath "$SIM_REPO_PATH/../../..")"
    SIM_LAUNCH_25G_FILE="$SIM_REPO_PATH/scripts/itf/regr_25G_launch.sh"
    SIM_RUN_LAUNCH_25G_FILE="$SIM_REPO_PATH/scripts/itf/run_regr_25G_launch.sh"
    SIM_OUTPUT_25G_FILE="$SIM_SCRIPTS_PATH/SIM_SED_FPTP_PDK_25G_STDOUT.out"
    SIM_LOG_25G_FILE="$SIM_SCRIPTS_PATH/SIM_SED_FPTP_PDK_25G_LOG.out"

    # Cleanup files
    rm -rf $SIM_RUN_LAUNCH_25G_FILE
    rm -rf $SIM_OUTPUT_25G_FILE
    rm -rf $SIM_LOG_25G_FILE
    rm -rf t.log

    # git pull repo
    echo " Executng test cmd"
    echo "cd $SIM_REPO_PATH"
    echo "/usr/intel/bin/git pull" >> $SIM_OUTPUT_25G_FILE
    test_cmd=$(cd $GIT_REPO_PATH; /usr/intel/bin/git pull)
    echo -ne "# " >> $SIM_OUTPUT_25G_FILE
    echo "$test_cmd" >> $SIM_OUTPUT_25G_FILE
    echo "" >> $SIM_OUTPUT_25G_FILE

    # Copy launch file
    cp $SIM_LAUNCH_25G_FILE $SIM_RUN_LAUNCH_25G_FILE

    ### Update REG_LOCAL_ROOT_DIR_PATH
    #sed -i "s#^export REG_LOCAL_ROOT_DIR_PATH=.*#export REG_LOCAL_ROOT_DIR_PATH=$SIM_REPO_PATH" "$SIM_RUN_LAUNCH_FILE"

    ## Temp file to hold modified contents
    TMP_FILE=$(mktemp)

    ## Path prefix to match
    PREFIX="/p/psg/flows/sw/regutils/23.4/5/linux64/bin/reg_exe"

    awk -v prefix="$PREFIX" '
    {
        # If line starts with the known prefix
        if (index($0, prefix) == 1) {
            # Escape any double quotes for the echo part
            gsub(/"/, "\\\"", $0)
            echo_part = "echo \"" $0 "\" >> '${SIM_OUTPUT_25G_FILE}'"
   
            # Undo quote escaping for actual execution part
            gsub(/\\"/, "\"", $0)
            exec_part = $0 " >> '${SIM_OUTPUT_25G_FILE}'"

            # Print the combined output
            print echo_part " && " exec_part
        } else {
            # Print the line as-is
            print $0
        }
    }' "$SIM_RUN_LAUNCH_25G_FILE" > "$TMP_FILE"
    cat $TMP_FILE

    #sleep 1
    #
    ## Overwrite the original file
    mv "$TMP_FILE" "$SIM_RUN_LAUNCH_25G_FILE"

    rm -rf "$TMP_FILE"

    chmod +x $SIM_RUN_LAUNCH_25G_FILE


    #sleep 10m
    # submit job to arc
    echo "/p/psg/ctools/arc/2019.1/bin/arc submit vcs-vcsmx-lic,acds/26.1,devacds/23.4,testutils/23.4/79,regutils/23.4,itf/23.4,ostype/suse15,synopsys_vip_common/vip_W-2025.03C,p4/psgeng,perl/5.8.8,python/3.7.7/1,vcsmx/X-2025.06-SP1-1  -- '${SIM_RUN_LAUNCH_25G_FILE}'" >> $SIM_OUTPUT_25G_FILE
    test_cmd=$(/p/psg/ctools/arc/2019.1/bin/arc submit flow/sw/bigmem vcs-vcsmx-lic,acds/26.1,devacds/23.4,testutils/23.4/79,regutils/23.4,itf/23.4,ostype/suse15,synopsys_vip_common/vip_W-2025.03C,p4/psgeng,perl/5.8.8,python/3.7.7/1,vcsmx/X-2025.06-SP1-1 mem=32000  -- "$SIM_RUN_LAUNCH_25G_FILE")
    echo -ne "# ARC Job Id: " >> $SIM_OUTPUT_25G_FILE
    echo "$test_cmd" >> $SIM_OUTPUT_25G_FILE
    echo "" >> $SIM_OUTPUT_25G_FILE


elif [ "$speed_size" = "50g" ]; then
    echo "Running job with 50g "

    export CURR_DIR="/p/psg/pac/release/main/github/psgpac/sed/regression_test/simulation/1588_ptp_agx7_fm87/50g_non_anlt/applications.fpga.system-example-designs.agilex7-ed-ptp/dk-si-agi027fd-oobe/ptp/verification/scripts/itf"
    SIM_REPO_PATH="$(realpath "$CURR_DIR/../..")"
    export REG_LOCAL_ROOT_DIR_PATH="$SIM_REPO_PATH"
    SIM_SCRIPTS_PATH="$CURR_DIR"
    GIT_REPO_PATH="$(realpath "$SIM_REPO_PATH/../../..")"
    SIM_LAUNCH_50G_FILE="$SIM_REPO_PATH/scripts/itf/regr_50G_launch.sh"
    SIM_RUN_LAUNCH_50G_FILE="$SIM_REPO_PATH/scripts/itf/run_regr_50G_launch.sh"
    SIM_OUTPUT_50G_FILE="$SIM_SCRIPTS_PATH/SIM_SED_FPTP_PDK_50G_STDOUT.out"
    SIM_LOG_50G_FILE="$SIM_SCRIPTS_PATH/SIM_SED_FPTP_PDK_50G_LOG.out"

    # Cleanup files
    rm -rf $SIM_RUN_LAUNCH_50G_FILE
    rm -rf $SIM_OUTPUT_50G_FILE
    rm -rf $SIM_LOG_50G_FILE
    rm -rf t.log

    # git pull repo
    echo " Executng test cmd"
    echo "cd $SIM_REPO_PATH"
    echo "/usr/intel/bin/git pull" >> $SIM_OUTPUT_50G_FILE
    test_cmd=$(cd $GIT_REPO_PATH; /usr/intel/bin/git pull)
    echo -ne "# " >> $SIM_OUTPUT_50G_FILE
    echo "$test_cmd" >> $SIM_OUTPUT_50G_FILE
    echo "" >> $SIM_OUTPUT_50G_FILE

    # Copy launch file
    cp $SIM_LAUNCH_50G_FILE $SIM_RUN_LAUNCH_50G_FILE

    ### Update REG_LOCAL_ROOT_DIR_PATH
    #sed -i "s#^export REG_LOCAL_ROOT_DIR_PATH=.*#export REG_LOCAL_ROOT_DIR_PATH=$SIM_REPO_PATH" "$SIM_RUN_LAUNCH_FILE"

    ## Temp file to hold modified contents
    TMP_FILE=$(mktemp)

    ## Path prefix to match
    PREFIX="/p/psg/flows/sw/regutils/23.4/5/linux64/bin/reg_exe"

    awk -v prefix="$PREFIX" '
    {
        # If line starts with the known prefix
        if (index($0, prefix) == 1) {
            # Escape any double quotes for the echo part
            gsub(/"/, "\\\"", $0)
            echo_part = "echo \"" $0 "\" >> '${SIM_OUTPUT_50G_FILE}'"
   
            # Undo quote escaping for actual execution part
            gsub(/\\"/, "\"", $0)
            exec_part = $0 " >> '${SIM_OUTPUT_50G_FILE}'"

            # Print the combined output
            print echo_part " && " exec_part
        } else {
            # Print the line as-is
            print $0
        }
    }' "$SIM_RUN_LAUNCH_50G_FILE" > "$TMP_FILE"
    cat $TMP_FILE

    #sleep 1
    #
    ## Overwrite the original file
    mv "$TMP_FILE" "$SIM_RUN_LAUNCH_50G_FILE"

    rm -rf "$TMP_FILE"

    chmod +x $SIM_RUN_LAUNCH_50G_FILE


    #sleep 10m
    # submit job to arc
    echo "/p/psg/ctools/arc/2019.1/bin/arc submit vcs-vcsmx-lic,acds/26.1,devacds/23.4,testutils/23.4/79,regutils/23.4,itf/23.4,ostype/suse15,synopsys_vip_common/vip_W-2025.03C,p4/psgeng,perl/5.8.8,python/3.7.7/1,vcsmx/X-2025.06-SP1-1  -- '${SIM_RUN_LAUNCH_50G_FILE}'" >> $SIM_OUTPUT_50G_FILE
    test_cmd=$(/p/psg/ctools/arc/2019.1/bin/arc submit flow/sw/bigmem vcs-vcsmx-lic,acds/26.1,devacds/23.4,testutils/23.4/79,regutils/23.4,itf/23.4,ostype/suse15,synopsys_vip_common/vip_W-2025.03C,p4/psgeng,perl/5.8.8,python/3.7.7/1,vcsmx/X-2025.06-SP1-1 mem=32000  -- "$SIM_RUN_LAUNCH_50G_FILE")
    echo -ne "# ARC Job Id: " >> $SIM_OUTPUT_50G_FILE
    echo "$test_cmd" >> $SIM_OUTPUT_50G_FILE
    echo "" >> $SIM_OUTPUT_50G_FILE

elif [ "$speed_size" = "100g" ]; then
    echo "Running job with 100g"

    export CURR_DIR="/p/psg/pac/release/main/github/psgpac/sed/regression_test/simulation/1588_ptp_agx7_fm87/100g_non_anlt/applications.fpga.system-example-designs.agilex7-ed-ptp/dk-si-agi027fd-oobe/ptp/verification/scripts/itf"
    SIM_REPO_PATH="$(realpath "$CURR_DIR/../..")"
    export REG_LOCAL_ROOT_DIR_PATH="$SIM_REPO_PATH"
    SIM_SCRIPTS_PATH="$CURR_DIR"
    GIT_REPO_PATH="$(realpath "$SIM_REPO_PATH/../../..")"
    SIM_LAUNCH_100G_FILE="$SIM_REPO_PATH/scripts/itf/regr_100G_launch.sh"
    SIM_RUN_LAUNCH_100G_FILE="$SIM_REPO_PATH/scripts/itf/run_regr_100G_launch.sh"
    SIM_OUTPUT_100G_FILE="$SIM_SCRIPTS_PATH/SIM_SED_FPTP_PDK_100G_STDOUT.out"
    SIM_LOG_100G_FILE="$SIM_SCRIPTS_PATH/SIM_SED_FPTP_PDK_100G_LOG.out"

    # Cleanup files
    rm -rf $SIM_RUN_LAUNCH_100G_FILE
    rm -rf $SIM_OUTPUT_100G_FILE
    rm -rf $SIM_LOG_100G_FILE
    rm -rf t.log

    # git pull repo
    echo " Executng test cmd"
    echo "cd $SIM_REPO_PATH"
    echo "/usr/intel/bin/git pull" >> $SIM_OUTPUT_100G_FILE
    test_cmd=$(cd $GIT_REPO_PATH; /usr/intel/bin/git pull)
    echo -ne "# " >> $SIM_OUTPUT_100G_FILE
    echo "$test_cmd" >> $SIM_OUTPUT_100G_FILE
    echo "" >> $SIM_OUTPUT_100G_FILE


    # Copy launch file
    cp $SIM_LAUNCH_100G_FILE $SIM_RUN_LAUNCH_100G_FILE

    ### Update REG_LOCAL_ROOT_DIR_PATH
    #sed -i "s#^export REG_LOCAL_ROOT_DIR_PATH=.*#export REG_LOCAL_ROOT_DIR_PATH=$SIM_REPO_PATH" "$SIM_RUN_LAUNCH_FILE"

    ## Temp file to hold modified contents
    TMP_FILE=$(mktemp)

    ## Path prefix to match
    PREFIX="/p/psg/flows/sw/regutils/23.4/5/linux64/bin/reg_exe"

    awk -v prefix="$PREFIX" '
    {
        # If line starts with the known prefix
        if (index($0, prefix) == 1) {
            # Escape any double quotes for the echo part
            gsub(/"/, "\\\"", $0)
            echo_part = "echo \"" $0 "\" >> '${SIM_OUTPUT_100G_FILE}'"
   
            # Undo quote escaping for actual execution part
            gsub(/\\"/, "\"", $0)
            exec_part = $0 " >> '${SIM_OUTPUT_100G_FILE}'"

            # Print the combined output
            print echo_part " && " exec_part
        } else {
            # Print the line as-is
            print $0
        }
    }' "$SIM_RUN_LAUNCH_100G_FILE" > "$TMP_FILE"
    cat $TMP_FILE

    #sleep 1
    #
    ## Overwrite the original file
    mv "$TMP_FILE" "$SIM_RUN_LAUNCH_100G_FILE"

    rm -rf "$TMP_FILE"

    chmod +x $SIM_RUN_LAUNCH_100G_FILE


    #sleep 10m
    # submit job to arc
    echo "/p/psg/ctools/arc/2019.1/bin/arc submit vcs-vcsmx-lic,acds/26.1,devacds/23.4,testutils/23.4/79,regutils/23.4,itf/23.4,ostype/suse15,synopsys_vip_common/vip_W-2025.03C,p4/psgeng,perl/5.8.8,python/3.7.7/1,vcsmx/X-2025.06-SP1-1  -- '${SIM_RUN_LAUNCH_100G_FILE}'" >> $SIM_OUTPUT_100G_FILE
    test_cmd=$(/p/psg/ctools/arc/2019.1/bin/arc submit flow/sw/bigmem vcs-vcsmx-lic,acds/26.1,devacds/23.4,testutils/23.4/79,regutils/23.4,itf/23.4,ostype/suse15,synopsys_vip_common/vip_W-2025.03C,p4/psgeng,perl/5.8.8,python/3.7.7/1,vcsmx/X-2025.06-SP1-1 mem=32000  -- "$SIM_RUN_LAUNCH_100G_FILE")
    echo -ne "# ARC Job Id: " >> $SIM_OUTPUT_100G_FILE
    echo "$test_cmd" >> $SIM_OUTPUT_100G_FILE
    echo "" >> $SIM_OUTPUT_100G_FILE

else
    echo "Invalid input: $speed_size"
    echo "Allowed values: 10g, 25g, 50g, 100g, 10G, 25G, 50G, 100G"
    exit 1
fi



