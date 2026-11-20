#!/bin/bash

set -x
BUILD=false

base_dir="/nfs/site/disks/pac_release_1/github/psgpac/sed/build/nightly/1588ptp/agx7/fm87/pdk"

for dir in "$base_dir"/*; do
  [[ -d "$dir" ]] || continue
  
  design_name=$(basename "$dir")

  # Skip D2x25G_MCQOS
  if [[ "$design_name" == "2x25G_MCQOS" ]]; then
    echo "Skipping $design_name"
    continue
  fi

  rerun_path="$dir/latest/reports/re-run"

  if [[ -f "$rerun_path" ]]; then
    echo "Found re-run file in: $design_name"
    BUILD=true
    #break
  else
    echo "No re-run file in: $design_name"
  fi
done

echo "BUILD=$BUILD"
echo $BUILD


