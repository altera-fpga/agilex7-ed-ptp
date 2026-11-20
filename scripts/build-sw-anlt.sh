#!/bin/bash
set -e
set -x
umask 022
echo "RELEASE FLAG: $RELEASE"
echo "NIGHTLY FLAG: $NIGHTLY"
echo "QUARTUS FLAG: $QUARTUS"

if [ -z "${BUILD_PATH:-}" ]; then
  echo "ERROR: BUILD_PATH must point to a hardware build artifact root." >&2
  exit 1
fi
if [ ! -d "$BUILD_PATH" ]; then
  echo "ERROR: BUILD_PATH does not exist: $BUILD_PATH" >&2
  exit 1
fi

# Hardware design folders (lowercase) parallel to weekly TEST matrix
folders=(
  "$BUILD_PATH/10g_anlt"
  "$BUILD_PATH/10g_non_anlt"
  "$BUILD_PATH/25g_anlt"
  "$BUILD_PATH/25g_non_anlt"
  "$BUILD_PATH/50g_anlt"
  "$BUILD_PATH/50g_non_anlt"
  "$BUILD_PATH/100g_anlt"
  "$BUILD_PATH/100g_non_anlt"
  "$BUILD_PATH/10g_25g_non_anlt_dr"
)

# Makefile / build.sh PTP_DESIGN values (same order as folders)
ptp_designs=(
  "10G_ANLT" "10G" "25G_ANLT" "25G"
  "50G_ANLT" "50G" "100G_ANLT" "100G" "DR"
)

# Expected RBF names under meta-custom/recipes-fpga/fpga-bitstream/files/
rbf_files=(
  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P10G_MCQ_ANLT.core.rbf"
  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P10G_MCQ.core.rbf"
  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ_ANLT.core.rbf"
  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ.core.rbf"
  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P50G_MCQ_ANLT.core.rbf"
  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P50G_MCQ.core.rbf"
  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P100G_MCQ_ANLT.core.rbf"
  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P100G_MCQ.core.rbf"
  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P_MCQ_DR.core.rbf"
)

# Published legacy ITB names
itb_files=(
  "kernel_sed_PTP_2P10G_MCQ_ANLT.itb"
  "kernel_sed_PTP_2P10G_MCQ.itb"
  "kernel_sed_PTP_2P25G_MCQ_ANLT.itb"
  "kernel_sed_PTP_2P25G_MCQ.itb"
  "kernel_sed_PTP_2P50G_MCQ_ANLT.itb"
  "kernel_sed_PTP_2P50G_MCQ.itb"
  "kernel_sed_PTP_2P100G_MCQ_ANLT.itb"
  "kernel_sed_PTP_2P100G_MCQ.itb"
  "kernel_sed_PTP_2P_MCQ_DR.itb"
)

declare -a hw_ready_idx
start_time=$(date +%s)

PTP_ROOT="dk-si-agi027fd-oobe/ptp"
YOCTO_DIR="$PTP_ROOT/software/yocto_linux"
RBF_DEST="$YOCTO_DIR/meta-custom/recipes-fpga/fpga-bitstream/files"
# DEPLOY_DIR resolved after YOCTO_TMPDIR (OE requires node-local TMPDIR)

# Hybrid: shared sources + node-local BitBake TMPDIR (avoids ARC -1004 on /tmp full tree)
if [ -n "${BUILD_ROOT:-}" ]; then
  WORKDIR="${BUILD_ROOT}/.yocto-build"
  echo "Using BUILD_ROOT workdir: $WORKDIR"
  mkdir -vp "$WORKDIR"
elif [ -d "dk-si-agi027fd-oobe/ptp/software/yocto_linux" ]; then
  WORKDIR="$(pwd)"
  echo "Using ARC iwd as workdir: $WORKDIR"
else
  WORKDIR=$(mktemp -d)
  echo "WARNING: falling back to /tmp workdir: $WORKDIR"
  trap 'rm -rf "$WORKDIR"' EXIT
fi

if [ -z "${YOCTO_TMPDIR:-}" ]; then
  if [ -n "${BUILD_ROOT:-}" ]; then
    YOCTO_TMPDIR="/tmp/yocto-tmp-$(basename "$BUILD_ROOT")"
  else
    YOCTO_TMPDIR="/tmp/yocto-tmp-$$"
  fi
fi
mkdir -vp "$YOCTO_TMPDIR"
export YOCTO_TMPDIR
echo "YOCTO_TMPDIR (node-local BitBake TMPDIR)=$YOCTO_TMPDIR"
trap 'rm -rf "$YOCTO_TMPDIR"' EXIT

cd "$WORKDIR"

if [ ! -d .git ]; then
  git init
  git remote add origin "$GITHUB_SERVER_URL"/"$GITHUB_REPOSITORY"
fi
git fetch origin "$GITHUB_REF"
git checkout -f FETCH_HEAD

mkdir -vp "$RBF_DEST"
if [ -n "$SSTATE_DIR" ]; then
  mkdir -vp "$SSTATE_DIR"
  ln -vsnfT "$SSTATE_DIR" "$YOCTO_DIR/sstate_cache" || true
fi

for i in "${!folders[@]}"; do
  if [ "$RELEASE" == 1 ]; then
    folder="${folders[$i]}/$TAG/latest"
  else
    folder="${folders[$i]}/latest"
  fi
  rbf_file="${rbf_files[$i]}"
  if [[ -f "$folder/build_flags/hardware_done" ]]; then
    echo "Hardware ready in $folder. Staging RBF as $rbf_file"
    cp "$folder/hw/"*core.rbf "$RBF_DEST/$rbf_file"
    sha1sum "$folder/hw/"*core.rbf
    sha1sum "$RBF_DEST/$rbf_file"
    hw_ready_idx+=("$i")
  else
    echo "No hardware_done in $folder, skipping..."
  fi
done

echo "HW-ready indices: ${hw_ready_idx[*]}"
mkdir -vp "$DESTDIR"

if [ ${#hw_ready_idx[@]} -eq 0 ]; then
  echo "ERROR: No hardware_done flags found under $BUILD_PATH/*/latest"
  echo "SW needs HW to publish *core.rbf + build_flags/hardware_done (NIGHTLY/schedule or manual with triggered_by_schedule)."
  ls -la "$BUILD_PATH"/*/latest/build_flags 2>/dev/null || true
  exit 1
fi

# ---- Single Yocto build (PTP_ALL) — do not loop bitbake per design ----
echo "======== SW PTP_DESIGN=PTP_ALL (one bitbake; all kernel_sed_PTP_*.itb) ========"
set +x
if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "ERROR: GITHUB_TOKEN unset; set GSRD_GITHUB_USER + GSRD_GITHUB_PAT and use a NEW workflow run"
  set -x
  exit 1
fi
GITHUB_USER="${GITHUB_USER:-x-access-token}"
GITCFG="$YOCTO_DIR/.gitconfig"
NETRC="$YOCTO_DIR/.netrc"
CA_BUNDLE=""
for cand in \
  /etc/ssl/certs/ca-certificates.crt \
  /etc/pki/tls/certs/ca-bundle.crt \
  /etc/ssl/cert.pem
do
  if [ -f "$cand" ]; then CA_BUNDLE="$cand"; break; fi
done
if [ -z "$CA_BUNDLE" ]; then
  echo "WARNING: no system CA bundle found; git https may fail TLS verify"
fi
{
  cat <<EOF
[url "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/"]
	insteadOf = https://github.com/
	insteadOf = http://github.com/
	insteadOf = git://github.com/
[credential]
	helper =
[http]
	sslVerify = false
EOF
  if [ -n "$CA_BUNDLE" ]; then
    printf '\tsslCAInfo = %s\n' "$CA_BUNDLE"
  fi
} > "$GITCFG"
cat > "$NETRC" <<EOF
machine github.com
login ${GITHUB_USER}
password ${GITHUB_TOKEN}
EOF
chmod 600 "$NETRC"
GIT_CONFIG_GLOBAL="$(cd "$YOCTO_DIR" && pwd)/.gitconfig"
cp -f "$GITCFG" "$HOME/.gitconfig" 2>/dev/null || true
cp -f "$NETRC" "$HOME/.netrc" 2>/dev/null || true
chmod 600 "$HOME/.netrc" 2>/dev/null || true
export GIT_CONFIG_GLOBAL
if [ -n "$CA_BUNDLE" ]; then
  export SSL_CERT_FILE="$CA_BUNDLE"
  export CURL_CA_BUNDLE="$CA_BUNDLE"
  export GIT_SSL_CAINFO="$CA_BUNDLE"
  export REQUESTS_CA_BUNDLE="$CA_BUNDLE"
fi
export GIT_SSL_NO_VERIFY=true
echo "Wrote kas gitconfig/netrc; GIT_CONFIG_GLOBAL=$GIT_CONFIG_GLOBAL user=${GITHUB_USER} CA=${CA_BUNDLE:-none} GIT_SSL_NO_VERIFY=true"
set -x
(
  cd "$YOCTO_DIR"
  export GITHUB_ACTIONS=true
  export YOCTO_TMPDIR
  export GITCONFIG_FILE="$(pwd)/.gitconfig"
  export NETRC_FILE="$(pwd)/.netrc"
  export GIT_CONFIG_GLOBAL
  export GIT_SSL_NO_VERIFY=true
  if [ -n "${CA_BUNDLE:-}" ]; then
    export SSL_CERT_FILE CURL_CA_BUNDLE GIT_SSL_CAINFO REQUESTS_CA_BUNDLE
  fi
  ./build.sh PTP_ALL sd
)

if [ -n "${YOCTO_TMPDIR:-}" ]; then
  DEPLOY_DIR="$YOCTO_TMPDIR/deploy/images/agilex7"
else
  DEPLOY_DIR="$YOCTO_DIR/build/tmp/deploy/images/agilex7"
fi

console_src=""
for cand in \
  "$DEPLOY_DIR/gsrd-console-image-agilex7.tar.gz" \
  "$DEPLOY_DIR/gsrd-console-image-agilex7.rootfs.tar.gz" \
  "$DEPLOY_DIR/console-image-minimal-agilex7.rootfs.tar.gz"; do
  if [ -f "$cand" ]; then console_src="$cand"; break; fi
done

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
if [ -n "$console_src" ]; then
  cp -f "$console_src" "$DESTDIR/gsrd-console-image-agilex7.tar.gz"
fi

# Publish per HW-ready design from the single PTP_ALL deploy dir
for i in "${hw_ready_idx[@]}"; do
  if [ "$RELEASE" == 1 ]; then
    folder="${folders[$i]}/$TAG/latest"
  else
    folder="${folders[$i]}/latest"
  fi
  itb_pub="${itb_files[$i]}"
  design_name=$(basename "$(dirname "$folder")")
  if [ "$RELEASE" == 1 ]; then
    design_name=$(basename "$(dirname "$(dirname "$folder")")")
  fi

  itb_src="$DEPLOY_DIR/${itb_pub}"
  if [ ! -f "$itb_src" ]; then
    echo "ERROR: missing $itb_src after PTP_ALL build"
    ls -la "$DEPLOY_DIR"/kernel_sed_PTP_*.itb 2>/dev/null || true
    exit 1
  fi

  mkdir -p "$folder/sw" "$folder/timing" "$folder/build_flags"
  cp -f "$itb_src" "$folder/sw/${ARTIFACT_NAME_PREFIX}.${itb_pub}"
  cp -f "$itb_src" "$DESTDIR/${itb_pub}"
  # Prefer design ITB as kernel_sed.itb for this publish; last write wins in DESTDIR
  cp -f "$itb_src" "$DESTDIR/kernel_sed.itb"

  if [ -n "$console_src" ]; then
    cp -f "$console_src" "$folder/sw/${ARTIFACT_NAME_PREFIX}_${design_name}.gsrd-console-image.tar.gz"
  fi
  if [ -f "$DESTDIR/sdimage.tar.gz" ]; then
    cp -f "$DESTDIR/sdimage.tar.gz" "$folder/sw/${ARTIFACT_NAME_PREFIX}_${design_name}.sdimage.tar.gz"
  fi
  if [ -f "$DESTDIR/u-boot-spl-dtb.hex" ]; then
    cp -f "$DESTDIR/u-boot-spl-dtb.hex" "$folder/sw/u-boot-spl-dtb.hex"
  fi

  HEX="$folder/sw/u-boot-spl-dtb.hex"
  SOF=$(ls "$folder/hw/"*.ghrd.sof 2>/dev/null | head -1 || true)
  QUARTUS_VERSION="${QUARTUS_VERSION:-acds/26.1}"
  if [ -f "$HEX" ] && [ -n "$SOF" ] && [ -f "$SOF" ]; then
    OUT_BASE="$folder/hw/ghrd_hps_gen"
    HPS_OUT="${SOF%.sof}.hps.rbf"
    echo "PFG HPS: sof=$SOF hex=$HEX -> $HPS_OUT"
    arc shell "$QUARTUS_VERSION" -- \
      "quartus_pfg -c -o hps=on -o hps_path=$HEX $SOF ${OUT_BASE}.rbf"
    if [ -f "${OUT_BASE}.hps.rbf" ]; then
      mv -f "${OUT_BASE}.hps.rbf" "$HPS_OUT"
      rm -f "${OUT_BASE}.rbf" "${OUT_BASE}.core.rbf" 2>/dev/null || true
      ls -la "$HPS_OUT"
    else
      echo "WARNING: PFG did not create ${OUT_BASE}.hps.rbf"
      ls -la "$folder/hw" || true
    fi
  else
    echo "WARNING: skip HPS PFG for $design_name (hex=$HEX sof=${SOF:-missing})"
  fi

  end_time=$(date +%s)
  duration=$((end_time - start_time))
  formatted_duration=$(printf "%02d:%02d:%02d" $((duration / 3600)) $(((duration % 3600) / 60)) $((duration % 60)))
  echo "$formatted_duration" > "$folder/timing/sw_time"
  touch "$folder/build_flags/software_done"
  echo "Created $folder/build_flags/software_done ($design_name -> $itb_pub)"
done

ls -lrt "$DESTDIR" || true
# Marker for workflow Copy outputs — only after all HW-ready designs finished
touch "$DESTDIR/.sw_build_ok"
echo "Wrote $DESTDIR/.sw_build_ok"
