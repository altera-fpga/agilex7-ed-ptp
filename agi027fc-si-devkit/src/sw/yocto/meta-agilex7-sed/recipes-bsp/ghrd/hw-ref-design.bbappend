FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit deploy

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

IMAGE_TYPE ?= "gsrd"
ARM64_GHRD_CORE_RBF = "ghrd.core.rbf"

sha256sum_PTP_2P10G_MCQ = "e4f2f7dd517693fdbe663a10e81308d766f00bf220771148eabe83330aea2d7e"
sha256sum_PTP_2P25G_MCQ = "e2d618eb2c3029daa15cc68dbea1a1bcf547c71156c691fd36dc1bd171cead51"
sha256sum_PTP_2P50G_MCQ = "190a092b3906332f6a4e022c1b70fb7ad0efdab9f670374069ee08ac1483f64a"
sha256sum_PTP_2P100G_MCQ = "0ddf53e81cee54bd22930838679c60e87b6ad3fd68c23a9e5f7c7ad492f9ece9"
sha256sum_PTP_2P10G_MCQ_ANLT = "fb89fbbf216f9ad73581c1de69b5cc851dd2f8ad481b5861b19e0541f1a91fbc"
sha256sum_PTP_2P25G_MCQ_ANLT = "3c4bf3f2a83cc96a5c368f176ee6c9a83d8716b50d210c54d26ad8a41a45636a"
sha256sum_PTP_2P50G_MCQ_ANLT = "c1ef85cb2b8f930a09bc2626b9a048d7141195d666258c501a21df3a87bfdf94"
sha256sum_PTP_2P100G_MCQ_ANLT = "b15df0819fe8120bd56230930d6df35c3adac4a5a90fb0f47402d893137358b8"

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
