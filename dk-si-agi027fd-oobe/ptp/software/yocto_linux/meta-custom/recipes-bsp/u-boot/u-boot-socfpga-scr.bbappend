FILESEXTRAPATHS:prepend := "${THISDIR}/files:${THISDIR}/files/configs:"

SRC_URI:agilex7 = " file://uboot_ftile.txt file://uboot_script_ftile.its"
SRC_URI:agilex7_dk_si_agi027fc = "file://uboot_ftile.txt file://uboot_script_ftile.its"

do_compile() {
        if echo "${MACHINE}" | grep -q agilex7; then
                cd ${UNPACKDIR}
                mkimage -f uboot_script_ftile.its ${B}/boot.scr.uimg
        fi
}
do_deploy() {
        install -d ${DEPLOYDIR}
        if echo "${MACHINE}" | grep -q agilex7 || [ "${MACHINE}" = "stratix10" ]; then
                install -m 0755 ${UNPACKDIR}/uboot_ftile.txt ${DEPLOYDIR}/u-boot.txt
                install -m 0644 ${B}/boot.scr.uimg ${DEPLOYDIR}/boot.scr.uimg
        fi
}
