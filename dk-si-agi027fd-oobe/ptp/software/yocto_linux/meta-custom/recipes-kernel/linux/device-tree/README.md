# Linux Kernel device-tree (Agilex™ 7 PTP)

## Where to place files

Copy design-specific Linux device trees into this directory:

```text
meta-custom/recipes-kernel/linux/device-tree/
```

The Yocto flow selects the DTB used in the FIT from `PTP_DESIGN` via `FPGA_LINUX_DTB_FILE` in `meta-custom/conf/ptp-solution.inc`.

| `PTP_DESIGN` | Expected DTB name |
|--------------|-------------------|
| `10G_ANLT` | `socfpga_fm87_ftile_10g_2port_2conn_mcq_ptp_anlt.dtb` |
| `10G` | `socfpga_fm87_ftile_10g_2port_2conn_mcq_ptp.dtb` |
| `25G_ANLT` | `socfpga_fm87_ftile_25g_2port_2conn_mcq_ptp_anlt.dtb` |
| `25G` | `socfpga_fm87_ftile_25g_2port_2conn_mcq_ptp.dtb` |
| `50G_ANLT` | `socfpga_fm87_ftile_50g_2port_2conn_mcq_ptp_anlt.dtb` |
| `50G` | `socfpga_fm87_ftile_50g_2port_2conn_mcq_ptp.dtb` |
| `100G_ANLT` | `socfpga_fm87_ftile_100g_2port_2conn_mcq_ptp_anlt.dtb` |
| `100G` | `socfpga_fm87_ftile_100g_2port_2conn_mcq_ptp.dtb` |
| `DR` | `socfpga_fm87_ftile_2port_2conn_mcq_ptp_dr.dtb` |

Place matching `.dts` / `.dtsi` sources here as well when you maintain them out-of-tree.

**Required for build:** at least the prebuilt `.dtb` for your current `PTP_DESIGN` must exist in this folder (the kernel recipe `SRC_URI` pulls only `FPGA_LINUX_DTB_FILE`). Example for `./build.sh 100G sd`:

```bash
# from yocto_linux/
ls meta-custom/recipes-kernel/linux/device-tree/socfpga_fm87_ftile_100g_2port_2conn_mcq_ptp.dtb
```

Reference base trees: [linux-socfpga](https://github.com/altera-fpga/linux-socfpga.git) under `arch/arm64/boot/dts/intel/` (FM87 F-Tile PTP MCQ names as above). Board base DTS in this BSP is typically `socfpga_agilex_socdk.dts` (`kas/machine.yml`).

## Build

```bash
# from yocto_linux/ — pick design first
export PTP_DESIGN=100G_ANLT
kas shell kas.yml
bitbake -c clean linux-socfpga-lts
bitbake linux-socfpga-lts
# or full image
bitbake console-image-minimal
```

## Deployed DTBs

DTBs land under:

```text
build/tmp/deploy/images/agilex7/
```

The FIT (`kernel_fm87.itb`) embeds the DTB selected by `FPGA_LINUX_DTB_FILE` for the current `PTP_DESIGN`.
