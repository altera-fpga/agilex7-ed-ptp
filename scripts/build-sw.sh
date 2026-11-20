#!/bin/bash
# Legacy single-rate SW build (25G NON_ANLT). Prefer scripts/build-sw-anlt.sh for full CI.
set -e
set -x
umask 022

PTP_DESIGN="${PTP_DESIGN:-25G}"
PTP_ROOT="dk-si-agi027fd-oobe/ptp"
YOCTO_DIR="$PTP_ROOT/software/yocto_linux"
RBF_DEST="$YOCTO_DIR/meta-custom/recipes-fpga/fpga-bitstream/files"
DEPLOY_DIR="$YOCTO_DIR/build/tmp/deploy/images/agilex7"
RBF_NAME="agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ.core.rbf"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT
cd "$WORKDIR"
echo "FLAG_DIR=$FLAG_DIR"
echo "Build branch: $GITHUB_REF"
echo "PTP_DESIGN=$PTP_DESIGN"

git init
git remote add origin "$GITHUB_SERVER_URL"/"$GITHUB_REPOSITORY"
git fetch origin "$GITHUB_REF"
git checkout FETCH_HEAD

mkdir -vp "$RBF_DEST"
if [ -n "$SSTATE_DIR" ]; then
  mkdir -vp "$SSTATE_DIR"
  ln -vsnfT "$SSTATE_DIR" "$YOCTO_DIR/sstate_cache" || true
fi

if [ -n "$FLAG_DIR" ]; then
  if [[ -f "$FLAG_DIR/hardware_done" ]]; then
    echo "Hardware build is completed."
    ls -lrt "$FLAG_DIR"/../hw/*core.rbf
    cp -rf "$FLAG_DIR"/../hw/*core.rbf "$RBF_DEST/$RBF_NAME"
    sha1sum "$FLAG_DIR"/../hw/*core.rbf
    sha1sum "$RBF_DEST/$RBF_NAME"
  else
    echo "Hardware build did not complete."
    exit 1
  fi
fi

(
  cd "$YOCTO_DIR"
  ./build.sh "$PTP_DESIGN" sd
)

mkdir -vp "$DESTDIR"
ls -lrt "$DEPLOY_DIR" || true

itb_src=""
for cand in "$DEPLOY_DIR/kernel_sed.itb" "$DEPLOY_DIR/kernel.itb"; do
  if [ -f "$cand" ]; then itb_src="$cand"; break; fi
done
[ -n "$itb_src" ] || { echo "Missing ITB under $DEPLOY_DIR"; exit 1; }
cp -f "$itb_src" "$DESTDIR/kernel_sed.itb"

console_src=""
for cand in \
  "$DEPLOY_DIR/gsrd-console-image-agilex7.tar.gz" \
  "$DEPLOY_DIR/gsrd-console-image-agilex7.rootfs.tar.gz" \
  "$DEPLOY_DIR/console-image-minimal-agilex7.rootfs.tar.gz"; do
  if [ -f "$cand" ]; then console_src="$cand"; break; fi
done
if [ -n "$console_src" ]; then
  cp -f "$console_src" "$DESTDIR/gsrd-console-image-agilex7.tar.gz"
fi

wic=""
for cand in "$DEPLOY_DIR"/gsrd-console-image-agilex7*.wic "$DEPLOY_DIR"/console-image-minimal-agilex7*.wic; do
  if [ -f "$cand" ]; then wic="$cand"; break; fi
done
if [ -n "$wic" ]; then
  tar -chzf "$DESTDIR/sdimage.tar.gz" -C "$(dirname "$wic")" "$(basename "$wic")"
fi

if [ -f "$DEPLOY_DIR/u-boot-spl-dtb.hex" ]; then
  cp -f "$DEPLOY_DIR/u-boot-spl-dtb.hex" "$DESTDIR/u-boot-spl-dtb.hex"
fi

ls -lrt "$DESTDIR"
