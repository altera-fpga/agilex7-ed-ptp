FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit deploy

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

IMAGE_TYPE ?= "gsrd"
ARM64_GHRD_CORE_RBF = "ghrd.core.rbf"

sha256sum_PTP_2P_MCQ_DR = "3bcc4d0131d432ff2056e206cc853f70c2db859af3933231c9573b7deb5f43b9"
sha256sum_PTP_2P10G_MCQ = "687d3152db6640c7962d5d30f1967595150c3847f39df4e3489d69fc901c4b62"
sha256sum_PTP_2P25G_MCQ = "4d01de583c9989a915828ab0d8e84e1cc13adf999fb5df5aaf349c4b8c152c5a"
sha256sum_PTP_2P50G_MCQ = "f7f023adb01b15d4b943d8a28584f5b62f7d4cb1dfa53533cf1097d77e80fb3f"
sha256sum_PTP_2P100G_MCQ = "dc1922727abf74001fc94d0c778ca138f6ff29728c0b61e9d2af91b4c34198be"
sha256sum_PTP_2P10G_MCQ_ANLT = "19a776224e18d2884c8696add831ded0279bfcffbf7377c675a545b4c90943fb"
sha256sum_PTP_2P25G_MCQ_ANLT = "61f8e967689c2d6f4e42dc52337e05f03181494309a24e12bafc5b07911828c9"
sha256sum_PTP_2P50G_MCQ_ANLT = "3aee95198a31e9937b6b13395115b3f6257bb3f5b84e102d6086fb717d46064c"
sha256sum_PTP_2P100G_MCQ_ANLT = "9c0dcbd0b09ec0b5ae06c8b992caf875dace7ac9ff293a3ea81da79d3f33b3e3"

SRC_URI:agilex7_dk_si_agi027fc = "\
                file://${MACHINE}_gsrd_ghrd_${SOLUTION}.core.rbf;name=agilex7_gsrd_core \
                "

SRC_URI[agilex7_gsrd_core.sha256sum] = "${@ d.getVar('sha256sum_'+"d.getVar('SOLUTION')")"}"

do_install () {
        if [[ "${MACHINE}" == *"agilex"* ]]; then
                install -D -m 0644 ${WORKDIR}/${MACHINE}_gsrd_ghrd_${SOLUTION}.core.rbf ${D}/boot/${ARM64_GHRD_CORE_RBF}
	fi
}

do_deploy () {
        if [[ "${MACHINE}" == *"agilex"* ]]; then
                install -D -m 0644 ${WORKDIR}/${MACHINE}_gsrd_ghrd_${SOLUTION}.core.rbf ${DEPLOYDIR}/${MACHINE}_${IMAGE_TYPE}_ghrd/${ARM64_GHRD_CORE_RBF}
	fi
}
