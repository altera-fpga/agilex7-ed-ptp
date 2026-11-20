# Overview of yocto_linux

Yocto / KAS BSP for the Agilex™ 7 PTP Multi-Channel QoS SEDs (`MACHINE=agilex7`).
Select a rate variant with **`PTP_DESIGN`** (see `meta-custom/conf/ptp-solution.inc`).
Hardware compile (`src` / `synth`): [../../README.md](../../README.md).

The base layer is `meta-altera-fpga` / `meta-altera-bsp`. Configure and build with KAS and BitBake.

## Software directory layout

```text
software/yocto_linux/
├── kas.yml / kas/              # KAS config
├── build.sh                    # ./build.sh <PTP_DESIGN> <BOOT_SOURCE>
├── meta-custom/
│   ├── conf/ptp-solution.inc   # PTP_DESIGN → RBF / DTB / SOLUTION
│   ├── recipes-fpga/fpga-bitstream/files/   # place *.core.rbf here
│   └── recipes-kernel/linux/device-tree/    # place design *.dtb / *.dts here
└── build/tmp/deploy/images/agilex7/         # outputs after build
```

Following is the top level view of the yocto_linux framework.

```
.
├── kas
│   ├── bsp.yml
│   ├── gsrd
│   │   └── Kconfig
│   ├── image
│   │   ├── all-image-targets.yaml
│   │   ├── console-image-minimal.yaml
│   │   ├── core-image-minimal.yaml
│   │   ├── gsrd-console-image.yaml
│   │   └── Kconfig
│   └── machine.yml
├── kas.yml
├── Kconfig
├── meta-custom
│   ├── conf
│   │   ├── layer.conf
│   │   ├── ptp-solution.inc    # PTP_DESIGN → RBF / DTB / SOLUTION
│   │   └── machine
│   ├── LICENSE
│   ├── README.md
│   ├── recipes-bsp
│   │   └── u-boot
│   ├── recipes-devtools
│   │   ├── packetgenerator
│   │   └── packetswitch
│   ├── recipes-files
│   │   └── rootfs-files
│   ├── recipes-fpga
│   │   └── fpga-bitstream      # place *.core.rbf under files/
│   └── recipes-kernel
│       └── linux
│           ├── device-tree     # place design DTS/DTB here
│           └── linux-socfpga-lts
├── build.sh                    # ./build.sh <PTP_DESIGN> <BOOT_SOURCE>
├── qspi_boot_src.yml
├── scripts
└── README.md

```

## KAS
- **Kconfig**  
Contains configuration definitions for KAS menu options to configure the Yocto.
- **kas.yml**  
kas.yaml is the configuration file used by KAS and contains the info of repos to be cloned, machine and other Yocto related configurations.

- **kas/image**  
The image directory contains yaml configurations for core-image-minimal, console-image-minimal and gsrd-console-image targets.

    - **core-image-minimal**  
        In the Yocto core-image-minimal is the most basic reference image recipes provided by the Poky
        distribution. It’s essentially a minimal root filesystem which is just enough to boot the system and
        provide a command-line interface.
    - **console-image-minimal**  
        In addition to core-image-base, console-image-minimal enables following packages,
        - Common essentials
        - Network essentials
        - Openssh
        - NFS
        - lighttpd
        - udev
        - systemd
        - mtd-utils

    - **gsrd-console-image**  
        In addition to core-image-base, gsrd-console-image enables following packages,
        - Common essentials
        - dev-tools essentials
        - Network essentials
        - web-server essentials
        - nfs-utils-client
        - Openssh
        - FIO
        - perl
        - NFS
        - lighttpd
        - udev
        - systemd
        - mtd-utils

## meta-custom layer
- **conf**  
Contains layer configuration (`ptp-solution.inc` maps `PTP_DESIGN` → RBF / DTB / `SOLUTION`).
- **recipes-bsp**  
Contains _u-boot_ recipe for boot loader.
    - _u-boot_ recipe allows integration of custom device tree source to enable the hardware-specific modifications. Also, allows integration of custom U-Boot environment variables.
- **recipes-devtools**  
Contains _packetgenerator_ and _packetswitch_ application recipes.
- **recipes-files**  
Contains recipes for adding custom files to the root filesystem.
- **recipes-fpga**  
Contains the _fpga-bitstream_ recipe to include RBF file(s).
- **recipes-kernel**  
Contains _linux_ recipe to create Kernel Image with custom configurations.
    - _device-tree_ — optional out-of-tree DTS override; design DTBs are built from in-kernel DTS via `PTP_DESIGN`.
    - _linux-socfpga-lts_ contains kernel configuration fragments, FIT ITS files, and patches.

Refer following links to understand more on BSP customization (Top level ```meta-custom/README.md``` provides introduction to each section).

- U-Boot
	```meta-custom/recipes-bsp/u-boot/README.md```
- Linux Kernel
	```meta-custom/recipes-kernel/linux/README.md```
- Linux Device Tree
	```meta-custom/recipes-kernel/linux/device-tree/README.md```
- FPGA Bitstream
	```meta-custom/recipes-fpga/fpga-bitstream/README.md```

## scripts
Contains helper scripts and configuration files for generating QSPI JIC images from Yocto build outputs.
Refer to ```scripts/README.md``` for detailed instructions on creating bootable images for QSPI flash.

# Yocto Build

## Prepare FPGA Bitstream (RBF) and device trees

1. Build hardware from `../../synth/` (see [../../README.md](../../README.md)).
2. Copy the **core** RBF into `meta-custom/recipes-fpga/fpga-bitstream/files/` using the **exact** name below.
3. **DTB:** no manual copy. The kernel recipe builds `socfpga_fm87_*.dtb` from linux-socfpga `arch/arm64/boot/dts/intel/*.dts` using `PTP_DESIGN` / `FPGA_LINUX_DTB_FILE`. See `meta-custom/recipes-kernel/linux/device-tree/README.md`.

| Hardware `CONFIG` (`synth/`) | `PTP_DESIGN` | Core RBF filename under `fpga-bitstream/files/` |
|------------------------------|--------------|--------------------------------------------------|
| `10G_ANLT` | `10G_ANLT` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P10G_MCQ_ANLT.core.rbf` |
| `10G_NON_ANLT` | `10G` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P10G_MCQ.core.rbf` |
| `25G_ANLT` | `25G_ANLT` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ_ANLT.core.rbf` |
| `25G_NON_ANLT` | `25G` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ.core.rbf` |
| `50G_ANLT` | `50G_ANLT` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P50G_MCQ_ANLT.core.rbf` |
| `50G_NON_ANLT` | `50G` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P50G_MCQ.core.rbf` |
| `100G_ANLT` | `100G_ANLT` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P100G_MCQ_ANLT.core.rbf` |
| `100G_NON_ANLT` | `100G` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P100G_MCQ.core.rbf` |
| `10G_25G_NON_ANLT_DR` | `DR` | `agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P_MCQ_DR.core.rbf` |
| *(all rates above)* | `PTP_ALL` | Place **all** `*.core.rbf` names from the rows above under `fpga-bitstream/files/` |

```bash
# Example: 100G (non-ANLT) from ptp/
cp ../../synth/output_files/<generated>.core.rbf \
  meta-custom/recipes-fpga/fpga-bitstream/files/agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P100G_MCQ.core.rbf
```

Do **not** hard-code `FPGA_RBF_FILE` in `kas.yml` per rate. Use `PTP_DESIGN` / `./build.sh`; `ptp-solution.inc` sets `FPGA_RBF_FILE`, `FPGA_LINUX_DTB_FILE`, and `SOLUTION`.

**Single-rate build:** the selected RBF is installed as `top.core.rbf` and included in the kernel FIT as `ghrd.core.rbf`. The matching DTB is built from the kernel and included in `kernel_fm87.itb`.

**`PTP_ALL` build:** one Yocto build stages every available `*.core.rbf` and produces per-design FIT images `kernel_fm87_PTP_*.itb` (skips a design if its RBF is missing).

## Build environment

**Prerequisites**
- Ubuntu 22.04 LTS or later is recommended for Yocto builds
- The system shell must use bash instead of dash. On Ubuntu 22.04, run:
  ```bash
  sudo ln -sf /bin/bash /bin/sh
  ```

Install the following host packages and tools required for yocto build.

**Host packages**
```bash
# apt install build-essential chrpath cpio debianutils diffstat file gawk gcc git iputils-ping libacl1 liblz4-tool locales python3 python3-git python3-jinja2 python3-pexpect python3-pip python3-subunit python3-newt socat texinfo unzip wget xz-utils zstd
```
Reference, https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#build-host-packages

**KAS tool**
```bash
$ python3 -m venv venv --system-site-packages
$ source venv/bin/activate
$ pip install --upgrade pip
$ pip install kas
$ pip install kconfiglib
```
Reference, https://kas.readthedocs.io/en/latest/userguide/getting-started.html#dependencies-installation

## How to build

### PTP design selection (`PTP_DESIGN`)

Valid values: `10G`, `25G`, `50G`, `100G`, `10G_ANLT`, `25G_ANLT`, `50G_ANLT`, `100G_ANLT`, `DR`, `PTP_ALL`  
Default: `25G_ANLT`

| Value | Behavior |
|-------|----------|
| Single rate (e.g. `100G`, `25G_ANLT`) | One FIT (`kernel_fm87.itb`) for that design |
| `PTP_ALL` | One Yocto build → all rate FIT ITBs (`kernel_fm87_PTP_*.itb`) |

### From design root (`ptp/`) — top-level make

```bash
cd ../..   # ptp/
make dk-si-agi027fd-oobe-baseline-ptp-software-yocto_linux_sd-build-sw PTP_DESIGN=100G
# All rates in one build:
make dk-si-agi027fd-oobe-baseline-ptp-software-yocto_linux_sd-build-sw PTP_DESIGN=PTP_ALL
```

### Recommended — `build.sh`

```bash
./build.sh 100G sd
./build.sh PTP_ALL sd    # one build, all ITBs
# Usage: ./build.sh <PTP_DESIGN> <BOOT_SOURCE>
# BOOT_SOURCE: sd | qspi | emmc | nand
```

### From command line — `kas shell`

```bash
PTP_DESIGN=100G kas shell kas.yml -c "bitbake console-image-minimal"
PTP_DESIGN=PTP_ALL kas shell kas.yml -c "bitbake console-image-minimal"
```

Or:

```bash
export PTP_DESIGN=100G_ANLT
kas shell kas.yml
bitbake console-image-minimal
```

### Using Yocto GUI (`kas menu`)

```bash
export PTP_DESIGN=25G_ANLT   # or PTP_ALL; default is 25G_ANLT
kas menu
# configure options, then Build — or Save & Exit and:
kas shell .config.yaml
bitbake console-image-minimal
```

### Binaries

After the build, binaries are under `build/tmp/deploy/images/agilex7/`.

| Binary | Description |
|--------|-------------|
| `uboot.env` | U-Boot environment |
| `boot.scr.uimg` | Boot script |
| `u-boot-spl-dtb.bin` | U-Boot FSBL (binary) |
| `u-boot-spl-dtb.hex` | U-Boot FSBL (hex) — use with `quartus_pfg` |
| `u-boot.itb` | U-Boot proper + DTB |
| `bl31.bin` | Arm Trusted Firmware |
| `Image` | Linux kernel image |
| `kernel_fm87.itb` / `kernel.itb` | FIT (Image + design DTB + RBF) for a single-rate build |
| `kernel_fm87_PTP_*.itb` | Per-design FITs when `PTP_DESIGN=PTP_ALL` |
| `top.core.rbf` | Selected design core RBF (`FPGA_RBF_FILE` staged by `fpga-bitstream`) |
| `socfpga_fm87_ftile_*_mcq_ptp*.dtb` | Design-specific Linux DTBs |
| `console-image-minimal-agilex7.rootfs.tar.gz` | Rootfs tarball |
| `console-image-minimal-agilex7*.wic` | SD/MMC bootable disk image |

### Steps to create QSPI bootable image (JIC)
Follow steps mentioned in ```scripts/README.md``` file.

### Notes

#### KAS Configuration - Include and Append/Override configurations

KAS supports modularizing build configurations by allowing multiple YAML files to be included and merged.
When multiple files are specified, KAS processes and merges them **in order**, with settings in later files overriding those from earlier ones.
This mechanism enables maintaining a stable base configuration while applying targeted overrides or additions as needed.

**Usage Example**

Before building, verify final configuration after merge:
```bash
kas dump kas.yml:bsp.yml
```

To build the project:
```bash
kas build kas.yml:bsp.yml
```

* `kas.yml` is the base configuration file.
* `kas/bsp.yml` contains the BSP pins (ATF/U-Boot/Linux branches and versions).
* `kas/machine.yml` contains machine and device-tree settings (e.g. `MACHINE`, `LINUX_DTS_FILE`, `CUSTOM_LINUX_DTS_FILE`).

This layered approach promotes a clean and maintainable configuration strategy, allowing you to customize specific settings without altering the main configuration directly.

**Example `kas.yml` with Includes**

```yaml
header:
  version: 11
  includes:
    - kas/machine.yml
    - kas/bsp.yml
```

* Here, `kas/machine.yml` and `kas/bsp.yml` are included and merged in that order.
* Later files can override or add settings to earlier ones.

**References**

* [Including In-Tree Configuration Files](https://kas.readthedocs.io/en/latest/userguide/project-configuration.html#including-in-tree-configuration-files)
* [Including Configuration Files from Other Repos](https://kas.readthedocs.io/en/latest/userguide/project-configuration.html#including-configuration-files-from-other-repos)
* [Including Configuration Files via the Command Line](https://kas.readthedocs.io/en/latest/userguide/project-configuration.html#including-configuration-files-via-the-command-line)

#### Bitbake commands for building key targets
- **Core Image**
```bash
$ bitbake -c build core-image-minimal
```
- **GSRD Image**
```bash
$ bitbake -c build gsrd-console-image
```
- **U-Boot**
```bash
$ bitbake -c build u-boot-socfpga (or) bitbake -c build virtual/bootloader
```
- **Linux**
```bash
$ bitbake -c build linux-socfpga-lts  (or) bitbake -c build virtual/kernel
```
- **ATF**
```bash
$ bitbake -c build arm-trusted-firmware
```
- **Device Tree**
```bash
$ bitbake -c build device-tree
```

### eSDK build

The extensible SDK (eSDK) provides a cross-development toolchain and libraries tailored to the contents of a specific image.

**Prerequisites**

Before building the eSDK, modify `kas.yml` to add the following configurations under `local_conf_header`:

```yaml
  yocto-config: |
    CONF_VERSION = "2"

  llvm-provider: |
    PREFERRED_PROVIDER_llvm-native = "clang-native"
    PROVIDES:pn-clang-native = "llvm-native"
```

**Build eSDK**

After modifying `kas.yml`, build the extensible SDK:

```bash
# Set bitbake build environment
$ kas shell kas.yml

# Build eSDK for console-image-minimal and gsrd-console-image
$ bitbake console-image-minimal gsrd-console-image -c populate_sdk_ext
```

The generated eSDK installer will be located in `build/tmp/deploy/sdk/`.

### Documentation
- [KAS] https://kas.readthedocs.io/en/latest/
- [YOCTO] https://docs.yoctoproject.org/

