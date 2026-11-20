SUMMARY = "PacketSwitch IP configurator for Linux on ARM"
DESCRIPTION = "PacketSwitch IP configurator executable for Linux to control PacketSwitch module"
HOMEPAGE = "https://github.com/altera-fpga/applications.fpga.hps.packetswitch.git"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7c6367005511b6ea56cf4966d5ba33fb"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
 
SRC_URI = "git://github.com/altera-fpga/applications.fpga.hps.packetswitch.git;protocol=https;branch=Agilex7_PacketSwitch"
SRCREV = "${AUTOREV}"

inherit autotools pkgconfig
FILES:${PN} += "${bindir}/packetswitch"
