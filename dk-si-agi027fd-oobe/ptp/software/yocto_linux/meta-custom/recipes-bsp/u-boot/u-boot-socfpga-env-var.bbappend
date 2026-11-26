SUMMARY = "U-boot boot environment for Altera SoCFPGA devices"
DESCRIPTION = "Sets the boot source for Second stage boot loader"
LICENSE = "MIT"

do_compile:prepend() {
    ENV_FILE="${UNPACKDIR}/u-boot-env.txt"
    if [ ! -f "${ENV_FILE}" ]; then
        bbfatal "u-boot-env.txt not found at ${ENV_FILE}"
    fi
    if [ -n "${SSBL_BOOT_SRC}" ]; then
        sed -i -e "s/^boot_targets=.*/boot_targets=${SSBL_BOOT_SRC}/" "${ENV_FILE}"
    else
        bbwarn "SSBL_BOOT_SRC is empty!, configure the boot source.."
    fi

    sed -i 's/^bootfile=kernel\.itb$/bootfile=kernel_sed.itb/' "${ENV_FILE}"
    sed -i '/^custom_bootargs=/d' "${ENV_FILE}"
    printf '%s\n' 'custom_bootargs=earlycon panic=-1 root=/dev/mmcblk0p2 rw rootwait uio_pdrv_genirq.of_id="generic-uio"' >> "${ENV_FILE}"

    # Override Address for Agilex7
    sed -i -e "s/spi@108d2000/spi@ff8d2000/" "${ENV_FILE}"
    sed -i -e "s/0x86000000/0x6000000/" "${ENV_FILE}"
    sed -i -e "s/0x82000000/0x2000000/" "${ENV_FILE}"
    sed -i -e "s/10b80000/ffb90000/" "${ENV_FILE}"
    sed -i -e "s/0x81000000/0x05FF0000/" "${ENV_FILE}"
}
