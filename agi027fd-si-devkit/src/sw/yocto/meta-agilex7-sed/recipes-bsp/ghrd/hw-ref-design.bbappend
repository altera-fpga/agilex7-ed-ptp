FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit deploy

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

IMAGE_TYPE ?= "gsrd"
ARM64_GHRD_CORE_RBF = "ghrd.core.rbf"

sha256sum_PTP_2P_MCQ_DR = "795d56917c46402536a5ab43cb0253d3b800c0d17c00e9fa909074f0ca0f7153"
<<<<<<< HEAD
sha256sum_PTP_2P10G_MCQ = "d93bf16452a5606755c84a816c6b61fa3dcba6206ff37957fe6ddb847f8f0a10"
sha256sum_PTP_2P25G_MCQ = "de19dc76b6b1596ca373a4d09f043ec59c68c99d22e72b807bff99d7ace87621"
sha256sum_PTP_2P50G_MCQ = "5c6055cec762abfe70dffb66c3ee463195807bd6bff93f1aba65cddcf5c79f3a"
sha256sum_PTP_2P100G_MCQ = "f564ddbdf3dcba9627fa5a49bec44ab3b38ffac7c0e48b0651ba9a8ccfd8d5ad"
sha256sum_PTP_2P10G_MCQ_ANLT = "4c9bfbbc3a6bdc3f7694dccb1b95283df6641e36b025c578e8ee388acada516d"
sha256sum_PTP_2P25G_MCQ_ANLT = "b68ca31613f8b1f08842e54dc14e621e988d24a242a673a015eb1a15148c9a3a"
sha256sum_PTP_2P50G_MCQ_ANLT = "c7bf0d82c92bb94ae67121a762b8f52e51be99b9dd7988842a57aedd0220574d"
sha256sum_PTP_2P100G_MCQ_ANLT = "4645efe0c9d022740091560db82695bf257383e571a05d79e24fb4e492a91f60"
=======
sha256sum_PTP_2P10G_MCQ = "c7bf0d82c92bb94ae67121a762b8f52e51be99b9dd7988842a57aedd0220574d"
sha256sum_PTP_2P25G_MCQ = "5c6055cec762abfe70dffb66c3ee463195807bd6bff93f1aba65cddcf5c79f3a"
sha256sum_PTP_2P50G_MCQ = "4645efe0c9d022740091560db82695bf257383e571a05d79e24fb4e492a91f60"
sha256sum_PTP_2P100G_MCQ = "f564ddbdf3dcba9627fa5a49bec44ab3b38ffac7c0e48b0651ba9a8ccfd8d5ad"
sha256sum_PTP_2P10G_MCQ_ANLT = "4c9bfbbc3a6bdc3f7694dccb1b95283df6641e36b025c578e8ee388acada516d"
sha256sum_PTP_2P25G_MCQ_ANLT = "d93bf16452a5606755c84a816c6b61fa3dcba6206ff37957fe6ddb847f8f0a10"
sha256sum_PTP_2P50G_MCQ_ANLT = "b68ca31613f8b1f08842e54dc14e621e988d24a242a673a015eb1a15148c9a3a"
sha256sum_PTP_2P100G_MCQ_ANLT = "de19dc76b6b1596ca373a4d09f043ec59c68c99d22e72b807bff99d7ace87621"
>>>>>>> rel/26.1

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
