SUMMARY = "PacketSwitch IP configurator for Linux on ARM"
DESCRIPTION = "PacketSwitch IP configurator executable for Linux to control PacketSwitch module"
HOMEPAGE = "https://github.com/altera-fpga/applications.fpga.hps.packetswitch.git"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7c6367005511b6ea56cf4966d5ba33fb"

FILESEXTRAPATHS:prepend := "/tmp/downloads:${THISDIR}/files:"
 
SRC_URI = "file://packetswitch_v1.1.tar.gz"
SRC_URI[sha256sum] = "ece0060952a433923b64145a8daf0aafee3f767c1688b8cc3680eaeb2b0c3410"
S = "${UNPACKDIR}/packetswitch_v1.1"

inherit autotools pkgconfig
FILES:${PN} += "${bindir}/packetswitch"
