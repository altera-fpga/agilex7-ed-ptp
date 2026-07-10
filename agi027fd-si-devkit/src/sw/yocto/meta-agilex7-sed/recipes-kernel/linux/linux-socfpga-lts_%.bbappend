KERNEL_REPO = "git://github.com/altera-fpga/linux-socfpga.git"
SRCREV = "SED-PTP-agilex7_dk_si_agi027fd-Q26.1-Rel-1.1"
#SRCREV = "${AUTOREV}"
LINUX_VERSION = "6.12.19"
KBRANCH = "socfpga-6.12.19-lts-ethernet-sed"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

SRC_URI:append = " file://config-eth.scc"
KERNEL_FEATURES:append = " config-eth.scc"
SRC_URI:append = " file://config-mcq.scc"
KERNEL_FEATURES:append = " config-mcq.scc"
KERNEL_VERSION_SANITY_SKIP="1"

LINUX_VERSION_EXTENSION = "${SW_VERSION_STRING}"

FILESEXTRAPATHS:prepend := "${THISDIR}/linux-socfpga-lts:"

SRC_URI:append:agilex7_dk_si_agi027fc = " file://fit_kernel_agilex7_dk_si_agi027fc_sed_PTP_2P10G_MCQ.its"
SRC_URI:append:agilex7_dk_si_agi027fc = " file://fit_kernel_agilex7_dk_si_agi027fc_sed_PTP_2P25G_MCQ.its"
SRC_URI:append:agilex7_dk_si_agi027fc = " file://fit_kernel_agilex7_dk_si_agi027fc_sed_PTP_2P50G_MCQ.its"
SRC_URI:append:agilex7_dk_si_agi027fc = " file://fit_kernel_agilex7_dk_si_agi027fc_sed_PTP_2P100G_MCQ.its"
SRC_URI:append:agilex7_dk_si_agi027fc = " file://fit_kernel_agilex7_dk_si_agi027fc_sed_PTP_2P10G_MCQ_ANLT.its"
SRC_URI:append:agilex7_dk_si_agi027fc = " file://fit_kernel_agilex7_dk_si_agi027fc_sed_PTP_2P25G_MCQ_ANLT.its"
SRC_URI:append:agilex7_dk_si_agi027fc = " file://fit_kernel_agilex7_dk_si_agi027fc_sed_PTP_2P50G_MCQ_ANLT.its"
SRC_URI:append:agilex7_dk_si_agi027fc = " file://fit_kernel_agilex7_dk_si_agi027fc_sed_PTP_2P100G_MCQ_ANLT.its"
SRC_URI:append:agilex7_dk_si_agi027fc = " file://fit_kernel_agilex7_dk_si_agi027fc_sed_PTP_2P_MCQ_DR.its"

#SRC_URI:append = " file://ubifs.scc"

do_deploy:append() {
        # Stage required binaries for kernel.itb

	if [[ "${MACHINE}" == *"agilex"* ]]; then
		# linux.dtb
		if [[ -n ${SOLUTION} ]]; then
			if [[ ${SOLUTION} == "PTP_2P10G_MCQ" ]]; then
                                 cp ${DTBDEPLOYDIR}/socfpga_fm87_ftile_10g_2port_2conn_mcq_ptp.dtb ${B};
                         elif [[ ${SOLUTION} == "PTP_2P25G_MCQ" ]]; then
                                 cp ${DTBDEPLOYDIR}/socfpga_fm87_ftile_25g_2port_2conn_mcq_ptp.dtb ${B};
                         elif [[ ${SOLUTION} == "PTP_2P50G_MCQ" ]]; then
                                 cp ${DTBDEPLOYDIR}/socfpga_fm87_ftile_50g_2port_2conn_mcq_ptp.dtb ${B};
                         elif [[ ${SOLUTION} == "PTP_2P100G_MCQ" ]]; then
                                 cp ${DTBDEPLOYDIR}/socfpga_fm87_ftile_100g_2port_2conn_mcq_ptp.dtb ${B};
                         elif [[ ${SOLUTION} == "PTP_2P10G_MCQ_ANLT" ]]; then
                                 cp ${DTBDEPLOYDIR}/socfpga_fm87_ftile_10g_2port_2conn_mcq_ptp_anlt.dtb ${B};
                         elif [[ ${SOLUTION} == "PTP_2P25G_MCQ_ANLT" ]]; then
                                 cp ${DTBDEPLOYDIR}/socfpga_fm87_ftile_25g_2port_2conn_mcq_ptp_anlt.dtb ${B};
                         elif [[ ${SOLUTION} == "PTP_2P50G_MCQ_ANLT" ]]; then
                                 cp ${DTBDEPLOYDIR}/socfpga_fm87_ftile_50g_2port_2conn_mcq_ptp_anlt.dtb ${B};
                         elif [[ ${SOLUTION} == "PTP_2P100G_MCQ_ANLT" ]]; then
                                 cp ${DTBDEPLOYDIR}/socfpga_fm87_ftile_100g_2port_2conn_mcq_ptp_anlt.dtb ${B};
                         elif [[ ${SOLUTION} == "PTP_2P_MCQ_DR" ]]; then
                                 cp ${DTBDEPLOYDIR}/socfpga_fm87_ftile_2port_2conn_mcq_ptp_dr.dtb ${B};
			fi
		fi
		# core.rbf
		echo -n "DEPLOY_DIR_IMAGE = ${DEPLOY_DIR_IMAGE} Machine - ${MACHINE} ImageType - ${IMAGE_TYPE} Destination - ${B} "
		cp ${DEPLOY_DIR_IMAGE}/${MACHINE}_${IMAGE_TYPE}_ghrd/ghrd.core.rbf ${B}
	fi

        # Generate and deploy kernel.itb
        if [[ "${MACHINE}" == *"agilex"* || "${MACHINE}" == "stratix10" ]]; then
                # kernel.its
		if [[ -n ${SOLUTION} ]]; then
			cp ${WORKDIR}/fit_kernel_${MACHINE}_sed_${SOLUTION}.its ${B}/fit_kernel.its
			cp ${B}/fit_kernel.its ${B}/fit_kernel_${MACHINE}.its
		fi
        
                # Image 
                cp ${LINUXDEPLOYDIR}/Image ${B}/Image
                # Compress Image to lzma format
                xz --force --format=lzma ${B}/Image
                # Generate kernel.itb
                mkimage -f ${B}/fit_kernel.its ${B}/kernel_sed.itb
		cp ${B}/kernel_sed.itb ${B}/kernel.itb
                # Deploy kernel.its, kernel.itb and Image.lzma
                install -m 744 ${B}/fit_kernel.its ${DEPLOYDIR}
		install -m 744 ${B}/fit_kernel_${MACHINE}.its ${DEPLOYDIR}
                install -m 744 ${B}/kernel_sed.itb ${DEPLOYDIR}
                install -m 744 ${B}/kernel.itb ${DEPLOYDIR}
                install -m 744 ${B}/Image.lzma ${DEPLOYDIR}
        fi
}
