FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

inherit deploy

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

IMAGE_TYPE ?= "gsrd"
ARM64_GHRD_CORE_RBF = "ghrd.core.rbf"

sha256sum_PTP_2P_MCQ_DR = "3efc75f9491e731ce020790efd620bcade7027f9d2da19d05ae47a2f73813d80"
sha256sum_PTP_2P10G_MCQ = "c366830312d376a64c5c1471cbe6c042af5fbf620e8228446883d09b722cea36"
sha256sum_PTP_2P25G_MCQ = "e4a9f498d2b8354e1dc1b01bf850ecb2fbdc6657ec24dfd250cd87ad589fc8cb"
sha256sum_PTP_2P50G_MCQ = "91ca5feacec334fd4942614eb2bcc3116c3455a4d51c6283b2f8ff3c77d039f1"
sha256sum_PTP_2P100G_MCQ = "b32dd1e442140188d943555dfd11f99b3c22eed6f12010784b9c1adaa6ca07e6"
sha256sum_PTP_2P10G_MCQ_ANLT = "6d17b46ea4b80980f9ec8fe8f04da715cc9b9e1de81745da5a3e367447bd2961"
sha256sum_PTP_2P25G_MCQ_ANLT = "6b64022d1bdb42c2a01d4be83a50cfde7adc8a235e0512b855b45c24e6b7f4c6"
sha256sum_PTP_2P50G_MCQ_ANLT = "a709dcdc0be3364e08466508fa9c7cf2ec773c525d5f9a45fa451cbfb6737e91"
sha256sum_PTP_2P100G_MCQ_ANLT = "4fcdaf2e01a91f82b866f778664a558a1eb3aea004d2db8cda3e547f7571219d"

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
