# Core RBF FPGA configuration (Agilex™ 7 PTP)

## Place the bitstream

Copy the hardware-generated **core** RBF into:

```text
meta-custom/recipes-fpga/fpga-bitstream/files/
```

Use the **exact** filename for the design you will build (`PTP_DESIGN` → `FPGA_RBF_FILE` in `meta-custom/conf/ptp-solution.inc`):

| `PTP_DESIGN` | Filename |
|--------------|----------|
| `10G_ANLT` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P10G_MCQ_ANLT.core.rbf` |
| `10G` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P10G_MCQ.core.rbf` |
| `25G_ANLT` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ_ANLT.core.rbf` |
| `25G` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ.core.rbf` |
| `50G_ANLT` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P50G_MCQ_ANLT.core.rbf` |
| `50G` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P50G_MCQ.core.rbf` |
| `100G_ANLT` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P100G_MCQ_ANLT.core.rbf` |
| `100G` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P100G_MCQ.core.rbf` |
| `DR` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P_MCQ_DR.core.rbf` |

Example:

```bash
cp ../../../../synth/output_files/<generated>.core.rbf \
  files/agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ_ANLT.core.rbf
```

## Build with `PTP_DESIGN`

Prefer selecting the design via environment / `build.sh` (do not change `FPGA_RBF_FILE` by hand for each rate):

```bash
# from yocto_linux/
./build.sh 100G_ANLT sd

# or
PTP_DESIGN=100G kas shell kas.yml -c "bitbake console-image-minimal"
```

To build only the bitstream recipe:

```bash
PTP_DESIGN=25G_ANLT kas shell kas.yml -c "bitbake fpga-bitstream"
```

## What the recipe installs

- Input: `${FPGA_RBF_FILE}` from `files/`
- Deploy name: **`top.core.rbf`** under `build/tmp/deploy/images/agilex7/`
- Kernel FIT then stages it as **`ghrd.core.rbf`** inside the ITB

This path is for **HPS boot first** with core RBF programming enabled (`FPGA_ENABLE_CORE_PGM`).

## Optional: kas menu

If you use `kas menu` instead of `PTP_DESIGN`, enable **Enable core RBF FPGA configuration** under FPGA options and set the Core RBF filename to match a file in `files/`. For multi-rate PTP SEDs, `PTP_DESIGN` + `ptp-solution.inc` is the supported flow.
