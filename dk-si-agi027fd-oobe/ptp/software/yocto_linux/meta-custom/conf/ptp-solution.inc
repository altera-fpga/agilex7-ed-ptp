# Map PTP_DESIGN -> RBF / DTB / SOLUTION
# Usage: PTP_DESIGN=25G_ANLT kas shell kas.yml -c "bitbake console-image-minimal"
#        PTP_DESIGN=PTP_ALL  -> one Yocto build, all FIT ITBs (see linux bbappend)
#        ./build.sh 25G_ANLT sd
PTP_DESIGN ??= "25G_ANLT"
python () {
    design = (d.getVar("PTP_DESIGN") or "25G_ANLT").strip().upper()
    # Makefile historically used ALL for a for-loop; treat as multi-ITB single build
    if design in ("ALL", "PTP_ALL"):
        design = "PTP_ALL"

    rbf_map = {
        "10G_ANLT":  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P10G_MCQ_ANLT.core.rbf",
        "10G":       "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P10G_MCQ.core.rbf",
        "25G_ANLT":  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ_ANLT.core.rbf",
        "25G":       "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P25G_MCQ.core.rbf",
        "50G_ANLT":  "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P50G_MCQ_ANLT.core.rbf",
        "50G":       "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P50G_MCQ.core.rbf",
        "100G_ANLT": "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P100G_MCQ_ANLT.core.rbf",
        "100G":      "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P100G_MCQ.core.rbf",
        "DR":        "agilex7_dk_si_agi027fc_gsrd_ghrd_PTP_2P_MCQ_DR.core.rbf",
    }
    dtb_map = {
        "10G_ANLT":  "socfpga_fm87_ftile_10g_2port_2conn_mcq_ptp_anlt.dtb",
        "10G":       "socfpga_fm87_ftile_10g_2port_2conn_mcq_ptp.dtb",
        "25G_ANLT":  "socfpga_fm87_ftile_25g_2port_2conn_mcq_ptp_anlt.dtb",
        "25G":       "socfpga_fm87_ftile_25g_2port_2conn_mcq_ptp.dtb",
        "50G_ANLT":  "socfpga_fm87_ftile_50g_2port_2conn_mcq_ptp_anlt.dtb",
        "50G":       "socfpga_fm87_ftile_50g_2port_2conn_mcq_ptp.dtb",
        "100G_ANLT": "socfpga_fm87_ftile_100g_2port_2conn_mcq_ptp_anlt.dtb",
        "100G":      "socfpga_fm87_ftile_100g_2port_2conn_mcq_ptp.dtb",
        "DR":        "socfpga_fm87_ftile_2port_2conn_mcq_ptp_dr.dtb",
    }
    sol_map = {
        "10G_ANLT":  "PTP_2P10G_MCQ_ANLT",
        "10G":       "PTP_2P10G_MCQ",
        "25G_ANLT":  "PTP_2P25G_MCQ_ANLT",
        "25G":       "PTP_2P25G_MCQ",
        "50G_ANLT":  "PTP_2P50G_MCQ_ANLT",
        "50G":       "PTP_2P50G_MCQ",
        "100G_ANLT": "PTP_2P100G_MCQ_ANLT",
        "100G":      "PTP_2P100G_MCQ",
        "DR":        "PTP_2P_MCQ_DR",
    }

    if design == "PTP_ALL":
        d.setVar("PTP_DESIGN", "PTP_ALL")
        d.setVar("SOLUTION", "PTP_ALL")
        # Placeholder for recipes that require a single name; bitstream bbappend
        # installs every RBF when SOLUTION=PTP_ALL.
        d.setVar("FPGA_RBF_FILE", rbf_map["25G_ANLT"])
        d.setVar("FPGA_RBF_FILES", " ".join(rbf_map[k] for k in sorted(rbf_map)))
        dtb_list = [dtb_map[k] for k in sorted(dtb_map)]
        d.setVar("FPGA_LINUX_DTB_FILE", dtb_list[0])
        d.setVar("FPGA_LINUX_DTB_FILES", " ".join(dtb_list))
        d.setVar("PTP_KERNEL_DEVICETREE", " ".join("intel/%s" % t for t in dtb_list))
        return

    if design not in rbf_map:
        bb.fatal("Unsupported PTP_DESIGN='%s'. Valid: %s PTP_ALL" %
                 (design, " ".join(sorted(rbf_map))))
    rbf = rbf_map[design]
    dtb = dtb_map[design]
    sol = sol_map[design]
    d.setVar("PTP_DESIGN", design)
    d.setVar("FPGA_RBF_FILE", rbf)
    d.setVar("FPGA_RBF_FILES", rbf)
    d.setVar("FPGA_LINUX_DTB_FILE", dtb)
    d.setVar("FPGA_LINUX_DTB_FILES", dtb)
    d.setVar("PTP_KERNEL_DEVICETREE", "intel/%s" % dtb)
    d.setVar("SOLUTION", sol)
    # Do NOT set CUSTOM_LINUX_DEVICE_TREE here; kas.yml keeps it as "1"
}
