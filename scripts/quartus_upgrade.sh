#!/bin/sh
set -ex

QUARTUS_VERSION=$QUARTUS_VERSION
echo "QUARTUS_VERSION - $QUARTUS_VERSION"
echo "WORKDIR - $WORKDIR"
echo "PROJECT_PATH - $PROJECT_PATH"
echo "SCRIPT_PATH - $SCRIPT_PATH"
LOG_DIR=$WORKDIR/logging

mkdir -p $LOG_DIR

# if [ -n "$BUILD_PATH" ]; then
#     arc shell $QUARTUS_VERSION -- "quartus_sh --version" | awk -F',' '/entering shell with resources/ { sub(/\/[^/]+$/, "", $2); print $2 }'  > $BUILD_PATH/quartus_info
# fi

sed -i "s|^[[:space:]]*QUARTUS_VERSION=.*|QUARTUS_VERSION=$QUARTUS_VERSION|" scripts/build-hw-anlt.sh
sed -i "s|^[[:space:]]*export QUARTUS_VER=.*|export QUARTUS_VER=\"$QUARTUS_VERSION\"|" $PWD/src/hw/verification/env/arc_resource_list.sh

echo "PWD --- $PWD"

arc shell $QUARTUS_VERSION -- "$SCRIPT_PATH/auto_upgrade.sh $PROJECT_PATH/top.qpf top"  2>&1 | tee $LOG_DIR/quartus_update.log
