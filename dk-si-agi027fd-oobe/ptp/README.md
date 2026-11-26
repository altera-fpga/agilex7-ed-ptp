# Agilex™ 7 IEEE 1588 PTP Multi-Channel QoS System Example Design

The Agilex™ 7 IEEE 1588 PTP Multi-Channel QoS System Example Design targets the [Agilex™ 7 FPGA I-Series Transceiver-SoC Development Kit (DK-SI-AGI027FD)](https://www.altera.com/products/devkit/po-3248/agilex-7-fpga-i-series-transceiver-soc-development-kit-4x-f-tile) with a 2-port F-Tile Ethernet / IEEE 1588v2 PTP design and Multi-Channel QoS (MCQoS) support.

## Description

The Agilex™ 7 IEEE 1588 PTP Multi-Channel QoS System Example Design demonstrates Ethernet and 1588 PTP functionality with Multi-Channel QoS on F-Tile. The integrated Hard Processor System (HPS) runs a PTP software stack that complements the hardware-based timestamping and QoS features.

## Project Details

- **Family**: Agilex 7
- **Quartus Version**: 26.3
- **Patch Number**: Unknown
- **Development Kit**: [Agilex 7 FPGA I-Series Transceiver-SoC Development Kit 4xF-Tile DK-SI-AGI027FD](https://www.altera.com/products/devkit/po-3248/agilex-7-fpga-i-series-transceiver-soc-development-kit-4x-f-tile)
- **Device Part**: AGIB027R31B1E1V
- **Category**: HPS, Ethernet
- **URL**: https://github.com/altera-fpga/agilex7-ed-ptp
- **Design Package**: dk-si-agi027fd-oobe-ptp.zip

## Documentations

- **Title**: Design and Build Readme  
  **URL**: [README.md](./README.md)
- **Title**: Hardware Build (synth)  
  **URL**: [synth/README.md](./synth/README.md)
- **Title**: Software / Yocto Build Readme  
  **URL**: [software/yocto_linux/README.md](./software/yocto_linux/README.md)

## Dependency

- Altera Quartus Prime Pro (see Project Details for the supported version)
- Software / Yocto: [software/yocto_linux/README.md](software/yocto_linux/README.md)

## Directory structure

```text
ptp/
+-- Makefile / project_config.mk / swbuild_config.mk
+-- src/                        # HARDWARE - RTL / Qsys / custom IP
+-- synth/                      # HARDWARE - Quartus project + Makefile
|   +-- output_files/
+-- software/
    +-- yocto_linux/            # SOFTWARE - see software/yocto_linux/README.md
```

| Path | Role |
|------|------|
| `src/` | RTL, Qsys, custom IP |
| `synth/` | Quartus project and rate-variant `Makefile` |
| `software/yocto_linux/` | Yocto / KAS BSP |

## Compiling via Makefile (hardware and software)

The top-level Makefile is in the design root (`ptp/`). The Quartus project
(`top.qpf` / `top.qsf`) lives in `synth/`.

Run `make help` from `ptp/` for the full target list.

Public stem: `dk-si-agi027fd-oobe-baseline-ptp`  
Hardware revision (SOF / RBF basename): `baseline` (`REVISION_NAMES` in `project_config.mk`).

`PTP_DESIGN` selects both hardware and software rate variants. Default: `25G_ANLT`.  
Valid: `10G`, `25G`, `50G`, `100G`, `10G_ANLT`, `25G_ANLT`, `50G_ANLT`, `100G_ANLT`, `DR`.

**Full build (hardware and software):**

```bash
make dk-si-agi027fd-oobe-baseline-ptp-all PTP_DESIGN=100G
```

This builds the selected design's `output_files/baseline.sof`, converts it to a core-only RBF named for `PTP_DESIGN` under `software/yocto_linux/meta-custom/recipes-fpga/fpga-bitstream/files/`, then runs the Yocto SD software build.

**Hardware build only:**

```bash
make dk-si-agi027fd-oobe-baseline-ptp-build PTP_DESIGN=100G
```

This calls `synth/Makefile` (`make -C synth all PTP_DESIGN=...`), keeps the revision SOF under
`output_files/baseline.sof`, and also emits design-named SOF and core RBF files in `output_files/`
for the software build.

**Software build only** also builds the selected hardware design if needed, generates and stages its matching core RBF, then runs Yocto:

```bash
make dk-si-agi027fd-oobe-baseline-ptp-software-yocto_linux_sd-build-sw PTP_DESIGN=100G
```

**Install SOF / reports / software artifacts** under `install/`:

```bash
make dk-si-agi027fd-oobe-baseline-ptp-install PTP_DESIGN=100G
```

**Install core RBF only** (SOF + `quartus_pfg` → `install/binaries/`):

```bash
make dk-si-agi027fd-oobe-baseline-ptp-install-core-rbf PTP_DESIGN=100G
```

Yocto RBF/DTB names, `PTP_DESIGN`, and kas details:
[software/yocto_linux/README.md](software/yocto_linux/README.md).

## Building the Hardware only

See [synth/README.md](./synth/README.md).

## Programming files (SOF + FSBL)

`u-boot-spl-dtb.hex` comes from the Yocto deploy images after a Yocto build.

After a Yocto build:

```bash
cd synth/
quartus_pfg -c -o hps=on \
  -o hps_path=../software/yocto_linux/build/tmp/deploy/images/agilex7/u-boot-spl-dtb.hex \
  output_files/top.sof \
  output_files/top.rbf
```

Or use the revision-named SOF produced by the top-level Makefile under `output_files/`.

### Generate the SD/QSPI JIC and RBF artifacts

After the SD software build completes, generate the JIC and HPS/core RBF files for the selected design with:

```bash
make sd-postprocess PTP_DESIGN=100G_ANLT
```

This uses the selected design-named SOF in `output_files/` (not the generic
revision SOF), inserts the Yocto SPL, and creates the matching
`<design>_yocto_linux_sd.sof`, `<design>.hps.jic`,
`<design>.core.rbf`, and `<design>.hps.rbf`; `qspi_helper.hps.jic` remains
design-independent. The FSBL-inserted SOF is in `output_files/`; the JIC/RBF files are staged under
`install/binaries/software/yocto_linux_sd/`. The matching WIC image,
`kernel_sed.itb`, and `u-boot-spl-dtb.hex` are available under
`software/yocto_linux/build/tmp/deploy/images/agilex7/`; the software build also
packages the WIC as `install/binaries/software/yocto_linux_sd/sdimage.tar.gz`.

## Software

Yocto / KAS, RBF/DTB names, `build.sh`, binaries:  
**[software/yocto_linux/README.md](software/yocto_linux/README.md)**.
