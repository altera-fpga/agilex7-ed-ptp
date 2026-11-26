#! /bin/bash
# Prerequisites:
# - Place design RBF files under meta-custom/recipes-fpga/fpga-bitstream/files/
# - Place matching DTB/DTS under meta-custom/recipes-kernel/linux/device-tree/
# - Initialize your .gitconfig file
# Command line parameters:
# - PTP_DESIGN: Design selector (default: 25G_ANLT)
#     Valid: 10G 25G 50G 100G 10G_ANLT 25G_ANLT 50G_ANLT 100G_ANLT DR
# - BOOT_SOURCE: Boot source for the build: 'sd', 'qspi', 'emmc', or 'nand'
# Supported environment variables:
# - GITCONFIG_CREATE_SCRIPT: Path to a script that creates the .gitconfig file
# - GITCONFIG_CREATE_SCRIPT_PARAMS: Parameters to pass to the gitconfig creation script
# - CONTAINER_COMMAND: Command to run the build in a container (e.g., "docker run --rm -v $(pwd):/workspace -w /workspace your_container_image")
set -e
PTP_DESIGN="${1:-25G_ANLT}"
BOOT_SOURCE=$2
GITCONFIG_CREATE_SCRIPT=${GITCONFIG_CREATE_SCRIPT:-""}
CONTAINER_COMMAND=${CONTAINER_COMMAND:-""}
export PTP_DESIGN
echo "Yocto Linux Build Script"
echo "PTP_DESIGN: $PTP_DESIGN"
echo "Boot Source: $BOOT_SOURCE"
echo "Gitconfig Creation Script: $GITCONFIG_CREATE_SCRIPT"
echo "Container Command: $CONTAINER_COMMAND"
case "$PTP_DESIGN" in
  10G|25G|50G|100G|10G_ANLT|25G_ANLT|50G_ANLT|100G_ANLT|DR) ;;
  *)
    echo "Error: unsupported PTP_DESIGN='$PTP_DESIGN'"
    echo "Usage: $0 <PTP_DESIGN> <BOOT_SOURCE>"
    echo "  PTP_DESIGN: 10G 25G 50G 100G 10G_ANLT 25G_ANLT 50G_ANLT 100G_ANLT DR"
    echo "  BOOT_SOURCE: 'sd', 'qspi', 'emmc', or 'nand'"
    exit 1
    ;;
esac
if [ "$BOOT_SOURCE" != "sd" ] && [ "$BOOT_SOURCE" != "qspi" ] && [ "$BOOT_SOURCE" != "emmc" ] && [ "$BOOT_SOURCE" != "nand" ]; then
    echo "Error: Boot source must be 'sd', 'qspi', 'emmc', or 'nand'"
    echo "Usage: $0 <PTP_DESIGN> <BOOT_SOURCE>"
    echo "  PTP_DESIGN: 10G 25G 50G 100G 10G_ANLT 25G_ANLT 50G_ANLT 100G_ANLT DR"
    echo "  BOOT_SOURCE: 'sd', 'qspi', 'emmc', or 'nand'"
    exit 1
fi
# Check if the gitconfig creation script is provided
if [ -n "$GITCONFIG_CREATE_SCRIPT" ]; then
    if [ ! -f "$GITCONFIG_CREATE_SCRIPT" ]; then
        echo "Error: Gitconfig creation script not found at $GITCONFIG_CREATE_SCRIPT"
        exit 1
    else
        echo "Running gitconfig creation script: $GITCONFIG_CREATE_SCRIPT"
        bash "$GITCONFIG_CREATE_SCRIPT"
        if [ $? -ne 0 ]; then
            echo "Error: Gitconfig creation script failed."
            exit 1
        fi
    fi
else
    echo "Warning: No gitconfig creation script provided. Skipping gitconfig setup."
fi
# If .gitconfig file exists in the current directory set the GITCONFIG_FILE environment variable
if [ -f "./.gitconfig" ]; then
    export GITCONFIG_FILE="./.gitconfig"
    echo "Using .gitconfig file from current directory."
else
    echo "Warning: No .gitconfig file found in the current directory."
    echo "Please ensure your .gitconfig is set up correctly."
fi
if [ -z "$CONTAINER_COMMAND" ]; then
    bash ./kas_build.sh "$PTP_DESIGN" "$BOOT_SOURCE"
    if [ $? -ne 0 ]; then
        echo "Error: Build command failed."
        exit 1
    fi
else
    echo "Executing container command: $CONTAINER_COMMAND ./kas_build.sh $PTP_DESIGN $BOOT_SOURCE"
    $CONTAINER_COMMAND ./kas_build.sh "$PTP_DESIGN" "$BOOT_SOURCE"
    if [ $? -ne 0 ]; then
        echo "Error: Container command failed."
        exit 1
    fi
fi
echo "Build completed successfully."
