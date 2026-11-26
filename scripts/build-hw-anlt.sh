#!/bin/sh
set -ex

QUARTUS_VERSION=acds/26.1
PTP_DIR="dk-si-agi027fd-oobe/ptp"
MAKE_STEM="dk-si-agi027fd-oobe-baseline-ptp"

# Map legacy CI DESIGN (CONFIG name) -> PTP_DESIGN
if [ -z "$PTP_DESIGN" ] && [ -n "$DESIGN" ]; then
  case "$DESIGN" in
    10G_NON_ANLT) PTP_DESIGN=10G ;;
    25G_NON_ANLT) PTP_DESIGN=25G ;;
    50G_NON_ANLT) PTP_DESIGN=50G ;;
    100G_NON_ANLT) PTP_DESIGN=100G ;;
    10G_25G_NON_ANLT_DR) PTP_DESIGN=DR ;;
    *) PTP_DESIGN="$DESIGN" ;;
  esac
fi
PTP_DESIGN="${PTP_DESIGN:-25G_ANLT}"

if [ -n "$BUILD_PATH" ]; then
  arc shell $QUARTUS_VERSION -- "quartus_sh --version" | \
    awk -F',' '/entering shell with resources/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' \
    > "$BUILD_PATH/quartus_info"
fi

echo "Building PTP_DESIGN=$PTP_DESIGN (legacy DESIGN=${DESIGN:-unset})"
cd "$PTP_DIR"

# Hardware compile (SOF + reports under synth/ and ptp/output_files)
arc shell $QUARTUS_VERSION -- "make ${MAKE_STEM}-build PTP_DESIGN=$PTP_DESIGN"

# Core RBF for Yocto / NFS (ghrd.core.rbf)
arc shell $QUARTUS_VERSION -- "make ${MAKE_STEM}-install-core-rbf PTP_DESIGN=$PTP_DESIGN"

# Stage names expected by GitHub HW workflows (top.sof / top.core.rbf)
mkdir -p synth/output_files
if [ -f output_files/baseline.sof ]; then
  cp -f output_files/baseline.sof synth/output_files/top.sof
fi
if [ -f output_files/ghrd.rbf ]; then
  cp -f output_files/ghrd.rbf synth/output_files/top.core.rbf
elif [ -f install/binaries/ghrd.core.rbf ]; then
  cp -f install/binaries/ghrd.core.rbf synth/output_files/top.core.rbf
fi

# Optional: full HPS+core RBF if SPL hex is present (legacy PFG flow)
HEX_PATH="../src/sw/artifacts/u-boot-spl-dtb.hex"
if [ ! -f "$HEX_PATH" ]; then
  HEX_PATH="software/yocto_linux/build/tmp/deploy/images/agilex7/u-boot-spl-dtb.hex"
fi
if [ -f "$HEX_PATH" ] && [ -f synth/output_files/top.sof ]; then
  arc shell $QUARTUS_VERSION -- \
    "quartus_pfg -c -o hps=on -o hps_path=$HEX_PATH synth/output_files/top.sof synth/output_files/top.rbf" || true
fi

ls -l synth/output_files/ || true
