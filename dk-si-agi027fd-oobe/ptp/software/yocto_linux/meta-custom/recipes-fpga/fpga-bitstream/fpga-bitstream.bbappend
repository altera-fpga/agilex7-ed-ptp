SUMMARY = "Altera SoCFPGA Bitstream"
DESCRIPTION = "Custom FPGA bitstream for SOC Development Kit"
SECTION = "bsp"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

python () {
    import os
    if not d.getVar('FPGA_ENABLE_CORE_PGM'):
        raise bb.parse.SkipRecipe("FPGA Enable Core Programming option is not set!")

    # PTP_ALL: stage each RBF that exists under FILESEXTRAPATHS (meta-custom .../files/).
    # Do NOT use THISDIR alone — for bbappends it often points at meta-altera-fpga's recipe dir.
    if (d.getVar("SOLUTION") or "") == "PTP_ALL":
        files = (d.getVar("FPGA_RBF_FILES") or "").split()
        search_dirs = []
        for p in (d.getVar("FILESEXTRAPATHS") or "").split(":"):
            if p and os.path.isdir(p):
                search_dirs.append(p)
        # Explicit meta-custom path (FILESEXTRAPATHS may not be expanded yet)
        here_files = os.path.normpath(os.path.join(
            d.getVar("LAYERDIR_meta_custom") or "",
            "recipes-fpga", "fpga-bitstream", "files"))
        if here_files and os.path.isdir(here_files) and here_files not in search_dirs:
            search_dirs.insert(0, here_files)

        present = []
        for f in files:
            found = None
            for sdir in search_dirs:
                cand = os.path.join(sdir, f)
                if os.path.isfile(cand):
                    found = cand
                    break
            if found:
                d.appendVar("SRC_URI", " file://%s" % f)
                present.append(f)
            else:
                bb.warn("PTP_ALL: RBF not in FILESEXTRAPATHS, skip: %s (searched: %s)" %
                        (f, " ".join(search_dirs) or "<none>"))
        if not present:
            bb.fatal("SOLUTION=PTP_ALL but no *.core.rbf found. Put files in "
                     "meta-custom/recipes-fpga/fpga-bitstream/files/ "
                     "(searched: %s)" % (" ".join(search_dirs) or "<none>"))
        d.setVar("FPGA_RBF_FILES", " ".join(present))
}

# For PTP_ALL, also install RBFs under ${MACHINE}_${IMAGE_TYPE}_ghrd/ with
# original filenames (linux-socfpga-lts bbappend expects that layout).
do_deploy:append() {
	if [ "${SOLUTION}" = "PTP_ALL" ]; then
		install -d ${DEPLOYDIR}/${MACHINE}_${IMAGE_TYPE}_ghrd
		for f in ${FPGA_RBF_FILES}; do
			src=""
			for cand in "${UNPACKDIR}/$f" "${WORKDIR}/$f" "${S}/$f"; do
				if [ -f "$cand" ]; then src="$cand"; break; fi
			done
			if [ -z "$src" ]; then
				bbfatal "PTP_ALL missing RBF in recipe workdir: $f"
			fi
			install -m 0644 "$src" ${DEPLOYDIR}/${MACHINE}_${IMAGE_TYPE}_ghrd/$f
			# Also next to Image for convenience
			install -m 0644 "$src" ${DEPLOYDIR}/$f
		done
	fi
}
