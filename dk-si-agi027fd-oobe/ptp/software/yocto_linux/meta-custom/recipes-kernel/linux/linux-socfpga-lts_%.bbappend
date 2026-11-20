KERNEL_REPO = "git://github.com/altera-innersource/applications.fpga.soc.linux-socfpga.git"
SRCREV = "SED-Ethernet-PTP-Agilex5-Quartus-26.3-Rel-D1.1"
LINUX_VERSION = "6.18.37"
KBRANCH = "socfpga-6.18.37-lts-ethernet-sed"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

# Append GSRD specific kernel config fragments and Patches.
FILESEXTRAPATHS:prepend := "${THISDIR}/device-tree:${THISDIR}/linux-socfpga-lts/configs:${THISDIR}/linux-socfpga-lts/patches:"

# Build PTP DTB(s) from kernel sources (arch/${ARCH}/boot/dts/intel/*.dts).
# PTP_KERNEL_DEVICETREE comes from meta-custom/conf/ptp-solution.inc (one or all).
KERNEL_DEVICETREE:append = " ${PTP_KERNEL_DEVICETREE}"

SRC_URI:append = " file://ftile-ptp.scc"
KERNEL_FEATURES:append = " ftile-ptp.scc"
SRC_URI:append = " file://ftile-mcq.scc"
KERNEL_FEATURES:append = " ftile-mcq.scc"
KERNEL_VERSION_SANITY_SKIP = "1"

LINUX_VERSION_EXTENSION = "${SW_VERSION_STRING}"

FILESEXTRAPATHS:prepend := "${THISDIR}/linux-socfpga-lts:"


SRC_URI:append:agilex7 = " file://fit_kernel_sed_ftile_PTP_2P10G_MCQ.its"
SRC_URI:append:agilex7 = " file://fit_kernel_sed_ftile_PTP_2P25G_MCQ.its"
SRC_URI:append:agilex7 = " file://fit_kernel_sed_ftile_PTP_2P50G_MCQ.its"
SRC_URI:append:agilex7 = " file://fit_kernel_sed_ftile_PTP_2P100G_MCQ.its"
SRC_URI:append:agilex7 = " file://fit_kernel_sed_ftile_PTP_2P10G_MCQ_ANLT.its"
SRC_URI:append:agilex7 = " file://fit_kernel_sed_ftile_PTP_2P25G_MCQ_ANLT.its"
SRC_URI:append:agilex7 = " file://fit_kernel_sed_ftile_PTP_2P50G_MCQ_ANLT.its"
SRC_URI:append:agilex7 = " file://fit_kernel_sed_ftile_PTP_2P100G_MCQ_ANLT.its"
SRC_URI:append:agilex7 = " file://fit_kernel_sed_ftile_PTP_2P_MCQ_DR.its"


do_deploy:append() {
        # Stage required binaries for kernel.itb
        # Supported device family: Agilex SED

	if [[ "${MACHINE}" == *"agilex"* ]]; then
		# linux.dtb
		if [[ -n ${SOLUTION} ]]; then
			if [[ ${SOLUTION} == "PTP_2P10G_MCQ" ]]; then
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_10g_2port_2conn_mcq_ptp.dtb ${B};
			elif [[ ${SOLUTION} == "PTP_2P25G_MCQ" ]]; then
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_25g_2port_2conn_mcq_ptp.dtb ${B};
			elif [[ ${SOLUTION} == "PTP_2P50G_MCQ" ]]; then
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_50g_2port_2conn_mcq_ptp.dtb ${B};
			elif [[ ${SOLUTION} == "PTP_2P100G_MCQ" ]]; then
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_100g_2port_2conn_mcq_ptp.dtb ${B};
			elif [[ ${SOLUTION} == "PTP_2P10G_MCQ_ANLT" ]]; then
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_10g_2port_2conn_mcq_ptp_anlt.dtb ${B};
			elif [[ ${SOLUTION} == "PTP_2P25G_MCQ_ANLT" ]]; then
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_25g_2port_2conn_mcq_ptp_anlt.dtb ${B};
			elif [[ ${SOLUTION} == "PTP_2P50G_MCQ_ANLT" ]]; then
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_50g_2port_2conn_mcq_ptp_anlt.dtb ${B};
			elif [[ ${SOLUTION} == "PTP_2P100G_MCQ_ANLT" ]]; then
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_100g_2port_2conn_mcq_ptp_anlt.dtb ${B};
			elif [[ ${SOLUTION} == "PTP_2P_MCQ_DR" ]]; then
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_2port_2conn_mcq_ptp_dr.dtb ${B};
			elif [[ ${SOLUTION} == "PTP_ALL" ]]; then
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_10g_2port_2conn_mcq_ptp.dtb ${B};
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_25g_2port_2conn_mcq_ptp.dtb ${B};
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_50g_2port_2conn_mcq_ptp.dtb ${B};
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_100g_2port_2conn_mcq_ptp.dtb ${B};
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_10g_2port_2conn_mcq_ptp_anlt.dtb ${B};
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_25g_2port_2conn_mcq_ptp_anlt.dtb ${B};
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_50g_2port_2conn_mcq_ptp_anlt.dtb ${B};
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_100g_2port_2conn_mcq_ptp_anlt.dtb ${B};
				cp ${LINUXDEPLOYDIR}/socfpga_fm87_ftile_2port_2conn_mcq_ptp_dr.dtb ${B};
			fi
		fi
		# core.rbf
		echo -n "DEPLOY_DIR_IMAGE = ${DEPLOY_DIR_IMAGE} Machine - ${MACHINE} ImageType - ${IMAGE_TYPE} Destination - ${B} "
		if [[ -n ${SOLUTION} ]]; then
			if [[ "${SOLUTION}" == *"PTP_ALL"* ]]; then
				cp ${DEPLOY_DIR_IMAGE}/${MACHINE}_${IMAGE_TYPE}_ghrd/*.core.rbf ${B}
			else
                                cp ${DEPLOY_DIR_IMAGE}/top.core.rbf ${B}/ghrd.core.rbf
			fi
		fi
	fi

        # Generate and deploy kernel.itb
        if [[ "${MACHINE}" == *"agilex"* || "${MACHINE}" == "stratix10" ]]; then
                # kernel.its
		if [[ -n ${SOLUTION} ]]; then
			if [[ ${SOLUTION} == "PTP_ALL" ]]; then
                                cp ${UNPACKDIR}/fit_kernel_sed_ftile_*.its ${B}/
			else
                                cp ${UNPACKDIR}/fit_kernel_sed_ftile_${SOLUTION}.its ${B}/fit_kernel_sed_ftile.its
				cp ${B}/fit_kernel_sed_ftile.its ${B}/fit_kernel_${MACHINE}.its
			fi
		fi
        
                # Image
                cp ${LINUXDEPLOYDIR}/Image ${B}/Image_sed
                # Compress Image to lzma format
                xz --force --format=lzma ${B}/Image_sed
                # Generate kernel.itb
		if [[ -n ${SOLUTION} ]]; then
			if [[ ${SOLUTION} == "PTP_ALL" ]]; then
				# Build each FIT only when its core.rbf was staged (partial HW OK)
				for sol in \
					PTP_2P10G_MCQ PTP_2P25G_MCQ PTP_2P50G_MCQ PTP_2P100G_MCQ \
					PTP_2P10G_MCQ_ANLT PTP_2P25G_MCQ_ANLT PTP_2P50G_MCQ_ANLT \
					PTP_2P100G_MCQ_ANLT PTP_2P_MCQ_DR
				do
					rbf="${B}/agilex7_dk_si_agi027fc_gsrd_ghrd_${sol}.core.rbf"
					its="${B}/fit_kernel_sed_ftile_${sol}.its"
					itb="${B}/kernel_sed_${sol}.itb"
					if [ ! -f "$rbf" ] || [ ! -f "$its" ]; then
						bbwarn "PTP_ALL: skip ${sol} (missing rbf or its)"
						continue
					fi
					cp -f "$rbf" ${B}/ghrd.core.rbf
					mkimage -f "$its" "$itb"
					install -m 744 "$its" ${DEPLOYDIR}
					install -m 744 "$itb" ${DEPLOYDIR}
					rm -f ${B}/ghrd.core.rbf
				done
				if [ -f ${B}/kernel_sed_PTP_2P10G_MCQ.itb ]; then
					install -m 744 ${B}/kernel_sed_PTP_2P10G_MCQ.itb ${DEPLOYDIR}/kernel_sed.itb
				elif [ -f ${B}/kernel_sed_PTP_2P25G_MCQ_ANLT.itb ]; then
					install -m 744 ${B}/kernel_sed_PTP_2P25G_MCQ_ANLT.itb ${DEPLOYDIR}/kernel_sed.itb
				fi
				install -m 744 ${B}/Image_sed.lzma ${DEPLOYDIR}
			else
                                mkimage -f ${B}/fit_kernel_sed_ftile.its  -k "${UBOOT_SIGN_KEYDIR}"  -r ${B}/kernel_sed.itb
				# Deploy kernel.its, kernel.itb and Image.lzma
				install -m 744 ${B}/fit_kernel_sed_ftile.its ${DEPLOYDIR}
				install -m 744 ${B}/kernel_sed.itb ${DEPLOYDIR}
				install -m 744 ${B}/Image_sed.lzma ${DEPLOYDIR}
			fi
		fi
        fi
}

# Ensure PTP DTB(s) are compiled from in-tree DTS.
do_compile:append() {
	for dtb_name in ${FPGA_LINUX_DTB_FILES}; do
		dtb_rel="intel/${dtb_name}"
		bbnote "Building PTP DTB from kernel: ${dtb_rel}"
		oe_runmake ${dtb_rel} || oe_runmake dtbs
	done
}

do_deploy:prepend() {
	install -d ${LINUXDEPLOYDIR}
	if [ -z "${FPGA_LINUX_DTB_FILES}" ]; then
		bbfatal "FPGA_LINUX_DTB_FILES is empty (check PTP_DESIGN / ptp-solution.inc)"
	fi

	for dtb_name in ${FPGA_LINUX_DTB_FILES}; do
		dtb_src=""

		# 1) Preferred: DTB produced by kernel compile
		for cand in \
			"${B}/arch/${ARCH}/boot/dts/intel/${dtb_name}" \
			"${B}/arch/${ARCH}/boot/dts/${dtb_name}" \
			"${D}${nonarch_base_libdir}/firmware/${dtb_name}" \
			"${D}/boot/${dtb_name}"; do
			if [ -f "${cand}" ]; then
				dtb_src="${cand}"
				break
			fi
		done

		# 2) Optional fallback: legacy prebuilt under device-tree/
		if [ -z "${dtb_src}" ] && [ -f "${UNPACKDIR}/${dtb_name}" ]; then
			bbwarn "Using legacy prebuilt DTB ${UNPACKDIR}/${dtb_name}; prefer kernel-built DTB"
			dtb_src="${UNPACKDIR}/${dtb_name}"
		fi

		# 3) Last resort: compile with dtc from kernel DTS in ${S}
		if [ -z "${dtb_src}" ]; then
			dts="${S}/arch/${ARCH}/boot/dts/intel/${dtb_name%.dtb}.dts"
			if [ ! -f "${dts}" ]; then
				bbfatal "Cannot find kernel-built DTB or DTS for ${dtb_name}. Expected DTS at ${dts}"
			fi
			bbnote "Compiling ${dtb_name} with dtc from ${dts}"
			dtb_src="${B}/${dtb_name}"
			dtc -I dts -O dtb -o "${dtb_src}" \
				-i "${S}/arch/${ARCH}/boot/dts" \
				-i "${S}/arch/${ARCH}/boot/dts/intel" \
				"${dts}" || bbfatal "dtc failed for ${dts}"
		fi

		install -m 0644 "${dtb_src}" "${LINUXDEPLOYDIR}/${dtb_name}"
		if [ -n "${DEPLOYDIR}" ]; then
			install -d "${DEPLOYDIR}"
			install -m 0644 "${dtb_src}" "${DEPLOYDIR}/${dtb_name}"
		fi
		bbnote "Staged PTP DTB: ${dtb_src} -> ${LINUXDEPLOYDIR}/${dtb_name}"
	done
}
