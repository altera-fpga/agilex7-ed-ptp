# Agilex™ 7 IEEE 1588 PTP Multi-Channel QoS System Example Design - Software

## Description

The software build provides the Linux software stack for the HPS subsystem of the
Agilex 7 PTP Multi-Channel QoS System Example Design. It uses a KAS-driven Yocto
flow in [`yocto_linux/`](yocto_linux/) to build the Linux kernel, U-Boot, Arm
Trusted Firmware, and root filesystem images.

Hardware sources and Quartus build files are outside this directory:

| Directory | Contents |
|-----------|----------|
| [`../src/`](../src/) | RTL, Qsys, and custom IP |
| [`../synth/`](../synth/) | Quartus project and hardware build |
| [`../verification/`](../verification/) | Testbench and verification |

See the [design README](../README.md) for hardware builds, programming files,
and top-level Make targets.

**Note:** Yocto build outputs are generated under
`yocto_linux/build/tmp/deploy/images/agilex7/`.

## Directory structure

```text
ptp/
├── src/                 # Hardware sources
├── synth/               # Quartus project
├── verification/        # Verification
└── software/
    ├── README.md        # This document
    └── yocto_linux/     # Yocto / KAS BSP
        ├── kas.yml
        ├── kas/         # Machine, BSP, and image configuration
        ├── meta-custom/ # PTP-specific Yocto layer
        ├── build.sh
        └── build/tmp/deploy/images/agilex7/  # Generated build outputs
```

## Getting started

### Select a PTP design

`PTP_DESIGN` selects the matching hardware and software rate variant. The
default is `25G_ANLT`. Supported values are:

```text
10G 25G 50G 100G
10G_ANLT 25G_ANLT 50G_ANLT 100G_ANLT
DR
```

The mapping from `PTP_DESIGN` to the FPGA RBF, Linux device tree, and Yocto
`SOLUTION` is defined in
[`yocto_linux/meta-custom/conf/ptp-solution.inc`](yocto_linux/meta-custom/conf/ptp-solution.inc).
See the [Yocto build README](yocto_linux/README.md) for the full mapping and
build details.

### Build with the top-level Makefile

Run these commands from the design root (`ptp/`). The software target builds
the selected hardware design if needed, stages its matching core RBF, and then
runs the Yocto SD build:

```bash
# Software build (includes the selected hardware build when needed)
make dk-si-agi027fd-oobe-baseline-ptp-software-yocto_linux_sd-build-sw PTP_DESIGN=25G_ANLT

# Build hardware and software
make dk-si-agi027fd-oobe-baseline-ptp-all PTP_DESIGN=25G_ANLT
```

For hardware-only builds, installation targets, and SD/QSPI post-processing,
see the [design README](../README.md).

### Build Yocto directly

For a standalone software build, first build the matching hardware core RBF and
place it under
`yocto_linux/meta-custom/recipes-fpga/fpga-bitstream/files/`. The matching
device tree is selected and built by the Yocto kernel recipe.

Then run from `ptp/software/yocto_linux/`:

```bash
./build.sh 25G_ANLT sd
```

The script prepares a Python virtual environment with KAS and builds the
`console-image-minimal` and `gsrd-console-image` images. Supported boot sources
are `sd`, `qspi`, `emmc`, and `nand`. Supply the boot source as the second
argument.

To invoke KAS and BitBake manually, after setting up the host prerequisites and
Python environment described in the [Yocto build README](yocto_linux/README.md):

```bash
PTP_DESIGN=25G_ANLT kas shell kas.yml -c "bitbake console-image-minimal"
```

### Build outputs

After a successful build, images and boot components are in
`yocto_linux/build/tmp/deploy/images/agilex7/`. Common outputs include:

| File | Description |
|------|-------------|
| `gsrd-console-image-agilex7.rootfs.wic` | SD card image |
| `u-boot-spl-dtb.hex` | U-Boot SPL / FSBL in hex format for `quartus_pfg` |
| `u-boot.itb` | U-Boot proper |
| `kernel_fm87.itb` | Linux FIT image with the selected device tree and FPGA RBF |

The SD build also packages the WIC image as
`install/binaries/software/yocto_linux_sd/sdimage.tar.gz`.

For the detailed Yocto configuration, host dependencies, design-to-RBF mapping,
QSPI image generation, and additional build options, see
[`yocto_linux/README.md`](yocto_linux/README.md).
