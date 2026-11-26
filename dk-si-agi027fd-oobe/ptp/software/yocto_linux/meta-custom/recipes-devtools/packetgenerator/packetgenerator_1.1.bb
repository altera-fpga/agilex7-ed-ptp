SUMMARY = "Packet Generator configurator for Linux on ARM"
DESCRIPTION = "Packet Generator configurator executable for Linux to control pktgen module"
HOMEPAGE = "https://github.com/altera-fpga/applications.fpga.hps.packetgenerator.git"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7c6367005511b6ea56cf4966d5ba33fb"

FILESEXTRAPATHS:prepend := "/tmp/downloads:${THISDIR}/files:"
 
SRC_URI = "file://packetgenerator_v1.1.tgz"
SRC_URI[sha256sum] = "b46af10f5c80cbff705b13869c1e25dfce3ad63248ff02b5d39c5c6f0d262835"
S = "${UNPACKDIR}/packetgenerator_v1.1"

inherit autotools pkgconfig
FILES:${PN} += "${bindir}/packetgenerator"
