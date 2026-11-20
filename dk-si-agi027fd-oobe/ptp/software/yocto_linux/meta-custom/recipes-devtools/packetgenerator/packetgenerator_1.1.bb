SUMMARY = "Packet Generator configurator for Linux on ARM"
DESCRIPTION = "Packet Generator configurator executable for Linux to control pktgen module"
HOMEPAGE = "https://github.com/altera-innersource/applications.fpga.hps.packetgenerator.git"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7c6367005511b6ea56cf4966d5ba33fb"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
 
SRC_URI = "git://github.com/altera-innersource/applications.fpga.hps.packetgenerator.git;protocol=https;branch=main"
SRCREV = "${AUTOREV}"

inherit autotools pkgconfig
FILES:${PN} += "${bindir}/packetgenerator"
