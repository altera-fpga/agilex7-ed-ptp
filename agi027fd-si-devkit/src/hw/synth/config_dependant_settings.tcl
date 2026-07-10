if { $param_value eq "10G_ANLT" } {
puts "Info: Configuration selected is 10G_ANLT"
# Verilog Macro Settings
# ============================
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_10G_25G
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_10G_ANLT
set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G
# ETH SERIAL IO
# 13C qsfp connector quad2
set_location_assignment PIN_T7 -to ftile_tx_serial[0]
set_location_assignment PIN_U8 -to ftile_tx_serial_n[0]
set_location_assignment PIN_M1 -to ftile_rx_serial[0]
set_location_assignment PIN_N2 -to ftile_rx_serial_n[0]

# 13A qsfp connector quad2
set_location_assignment PIN_CE10 -to ftile_tx_serial[1]
set_location_assignment PIN_CF11 -to ftile_tx_serial_n[1]
set_location_assignment PIN_CH1 -to ftile_rx_serial[1]
set_location_assignment PIN_CG2 -to ftile_rx_serial_n[1]

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[1] -entity top


set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[1] -entity top

# Logic Generation Assignments
# ============================
set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port1_hssi_10G_anlt|hssi_ss_1|kr_dut_8|eth_anlt_f_inst8 -to inst_port1_hssi_10G_anlt|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top
set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port2_hssi_10G_anlt|hssi_ss_1|kr_dut_8|eth_anlt_f_inst8 -to inst_port2_hssi_10G_anlt|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top

# IP Selection
# ============================
set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_10G/hssi_ss_10G_anlt.ip

} elseif { $param_value eq "10G_NON_ANLT" } {
puts "Info: Configuration selected is 10G_NON_ANLT"
# Verilog Macro Settings
# ============================
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_10G_25G
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_10G
set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G
# ETH SERIAL IO
# 13C qsfp connector quad2
set_location_assignment PIN_T7 -to ftile_tx_serial[0]
set_location_assignment PIN_U8 -to ftile_tx_serial_n[0]
set_location_assignment PIN_M1 -to ftile_rx_serial[0]
set_location_assignment PIN_N2 -to ftile_rx_serial_n[0]

# 13A qsfp connector quad2
set_location_assignment PIN_CE10 -to ftile_tx_serial[1]
set_location_assignment PIN_CF11 -to ftile_tx_serial_n[1]
set_location_assignment PIN_CH1 -to ftile_rx_serial[1]
set_location_assignment PIN_CG2 -to ftile_rx_serial_n[1]

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[1] -entity top


set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[1] -entity top

# Logic Generation Assignments
# ============================
#set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port1_hssi_10G_anlt|hssi_ss_1|kr_dut_8|eth_anlt_f_inst8 -to inst_port1_hssi_10G_anlt|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top
#set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port2_hssi_10G_anlt|hssi_ss_1|kr_dut_8|eth_anlt_f_inst8 -to inst_port2_hssi_10G_anlt|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_LOW_LOSS" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_LOW_LOSS" -to ftile_rx_serial[1] -entity top

# IP Selection
# ============================
set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_10G/hssi_ss_10G.ip

} elseif {$param_value eq "25G_ANLT"} {
puts "Info: Configuration selected is 25G_ANLT"
# Verilog Macro Settings
# ============================
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_10G_25G
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_25G_ANLT
set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G
# ETH SERIAL IO
# 13C qsfp connector quad2
set_location_assignment PIN_T7 -to ftile_tx_serial[0]
set_location_assignment PIN_U8 -to ftile_tx_serial_n[0]
set_location_assignment PIN_M1 -to ftile_rx_serial[0]
set_location_assignment PIN_N2 -to ftile_rx_serial_n[0]

# 13A qsfp connector quad2
set_location_assignment PIN_CE10 -to ftile_tx_serial[1]
set_location_assignment PIN_CF11 -to ftile_tx_serial_n[1]
set_location_assignment PIN_CH1 -to ftile_rx_serial[1]
set_location_assignment PIN_CG2 -to ftile_rx_serial_n[1]

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[1] -entity top


set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[1] -entity top

# Logic Generation Assignments
# ============================
set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port1_hssi_25G_anlt|hssi_ss_1|kr_dut_8|eth_anlt_f_inst8 -to inst_port1_hssi_25G_anlt|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top
set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port2_hssi_25G_anlt|hssi_ss_1|kr_dut_8|eth_anlt_f_inst8 -to inst_port2_hssi_25G_anlt|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top

# IP Selection
# ============================
set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_25G/hssi_ss_25G_anlt.ip

} elseif {$param_value eq "10G_25G_NON_ANLT_DR"} {
puts "Info: Configuration selected is 10G_25G_NON_ANLT_DR"
# Verilog Macro Settings
# ============================
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_10G_25G
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_10G_25G_NON_ANLT_DR
set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G
# ETH SERIAL IO
# 13C qsfp connector quad2
set_location_assignment PIN_T7 -to ftile_tx_serial[0]
set_location_assignment PIN_U8 -to ftile_tx_serial_n[0]
set_location_assignment PIN_M1 -to ftile_rx_serial[0]
set_location_assignment PIN_N2 -to ftile_rx_serial_n[0]

# 13A qsfp connector quad2
set_location_assignment PIN_CE10 -to ftile_tx_serial[1]
set_location_assignment PIN_CF11 -to ftile_tx_serial_n[1]
set_location_assignment PIN_CH1 -to ftile_rx_serial[1]
set_location_assignment PIN_CG2 -to ftile_rx_serial_n[1]

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[1] -entity top


set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[1] -entity top

# Logic Generation Assignments
# ============================

# set_global_assignment -name IP_RECONFIG_GROUP_TYPE "RG_A:INCLUSIVE:CLK_MASTER" -entity top
# set_global_assignment -name IP_RECONFIG_GROUP_TYPE "RG_B:INCLUSIVE:CLK_MASTER" -entity top
	
	# set_instance_assignment -name IP_RECONFIG_GROUP RG_A -to inst_port1_hssi_10G_25G_non_anlt_dr|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 
	# set_instance_assignment -name IP_RECONFIG_GROUP RG_B -to inst_port2_hssi_10G_25G_non_anlt_dr|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 
	#set_global_assignment -name IP_RECONFIG_GROUP_PARENT "RG_A:INST_PORT1_HSSI_10G_25G_NON_ANLT_DR|HSSI_SS_1|U_ETH_F_INST_P8|ETH_F_TOP_P8/RG_A" -entity top
	#set_global_assignment -name IP_RECONFIG_GROUP_PARENT "RG_B:INST_PORT2_HSSI_10G_25G_NON_ANLT_DR|HSSI_SS_1|U_ETH_F_INST_P8|ETH_F_TOP_P8/RG_B" -entity top
	
	set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port1_hssi_10G_25G_non_anlt_dr|hssi_ss_1|U_dr_dut|hssi_ss_f_dr_ctrl -to inst_port1_hssi_10G_25G_non_anlt_dr|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top
	set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port2_hssi_10G_25G_non_anlt_dr|hssi_ss_1|U_dr_dut|hssi_ss_f_dr_ctrl -to inst_port2_hssi_10G_25G_non_anlt_dr|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top

	set_instance_assignment -name IP_RECONFIG_ID 1 -to inst_port1_hssi_10G_25G_non_anlt_dr|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top
	set_instance_assignment -name IP_RECONFIG_ID 100 -to inst_port2_hssi_10G_25G_non_anlt_dr|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top

set_instance_assignment -name IP_RECONFIG_GROUP_MASTER_CLOCK_CHANNEL OFF -to inst_port1_hssi_10G_25G_non_anlt_dr|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top
set_instance_assignment -name IP_RECONFIG_GROUP_MASTER_CLOCK_CHANNEL OFF -to inst_port2_hssi_10G_25G_non_anlt_dr|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top

set_instance_assignment -name IP_RECONFIG_GROUP_MASTER_CLOCK_CHANNEL "PLD_PCS_TX_CLK_OUT1_DCM:INST_PORT1_HSSI_10G_25G_NON_ANLT_DR|HSSI_SS_1|U_ETH_F_INST_P8|ETH_F_TOP_P8/RG_A" -to inst_port1_hssi_10G_25G_non_anlt_dr|hssi_ss_1|ptp_adpt_f|ptp_adpt|hip_inst|x_bb_m_hdpldadapt_tx_ch7 -entity top
set_instance_assignment -name IP_RECONFIG_GROUP_MASTER_CLOCK_CHANNEL "PLD_PCS_TX_CLK_OUT1_DCM:INST_PORT2_HSSI_10G_25G_NON_ANLT_DR|HSSI_SS_1|U_ETH_F_INST_P8|ETH_F_TOP_P8/RG_A" -to inst_port2_hssi_10G_25G_non_anlt_dr|hssi_ss_1|ptp_adpt_f|ptp_adpt|hip_inst|x_bb_m_hdpldadapt_tx_ch7 -entity top

# IP Selection
# ============================
set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_10G_25G_DR/hssi_ss_10G_25G_non_anlt_dr.ip

} elseif {$param_value eq "25G_NON_ANLT"} {
puts "Info: Configuration selected is 25G_NON_ANLT"
# Verilog Macro Settings
# ============================
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_10G_25G
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_25G
set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G
# ETH SERIAL IO
# 13C qsfp connector quad2
set_location_assignment PIN_T7 -to ftile_tx_serial[0]
set_location_assignment PIN_U8 -to ftile_tx_serial_n[0]
set_location_assignment PIN_M1 -to ftile_rx_serial[0]
set_location_assignment PIN_N2 -to ftile_rx_serial_n[0]

# 13A qsfp connector quad2
set_location_assignment PIN_CE10 -to ftile_tx_serial[1]
set_location_assignment PIN_CF11 -to ftile_tx_serial_n[1]
set_location_assignment PIN_CH1 -to ftile_rx_serial[1]
set_location_assignment PIN_CG2 -to ftile_rx_serial_n[1]

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[1] -entity top


set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[1] -entity top

# Logic Generation Assignments
# ============================
#set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port1_hssi_25G_anlt|hssi_ss_1|kr_dut_8|eth_anlt_f_inst8 -to inst_port1_hssi_25G_anlt|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top
#set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port2_hssi_25G_anlt|hssi_ss_1|kr_dut_8|eth_anlt_f_inst8 -to inst_port2_hssi_25G_anlt|hssi_ss_1|U_eth_f_inst_p8|eth_f_top_p8 -entity top
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_LOW_LOSS" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_LOW_LOSS" -to ftile_rx_serial[1] -entity top

# IP Selection
# ============================
set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_25G/hssi_ss_25G.ip

} elseif {$param_value eq "50G_ANLT"} {
puts "Info: Configuration selected is 50G_ANLT"
# Verilog Macro Settings
# ============================
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_50G_AUI1_PAM4_ANLT
set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G

# ETH SERIAL IO
# 13C qsfp connector quad2
set_location_assignment PIN_W10 -to ftile_tx_serial[0]
set_location_assignment PIN_V11 -to ftile_tx_serial_n[0]
set_location_assignment PIN_W4 -to ftile_rx_serial[0]
set_location_assignment PIN_V5 -to ftile_rx_serial_n[0]

# 13A qsfp connector quad2
set_location_assignment PIN_CH7 -to ftile_tx_serial[1]
set_location_assignment PIN_CG8 -to ftile_tx_serial_n[1]
set_location_assignment PIN_CJ4 -to ftile_rx_serial[1]
set_location_assignment PIN_CK5 -to ftile_rx_serial_n[1]

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[1] -entity top

set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[1] -entity top

# Logic Generation Assignments
# ============================
set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port1_hssi_50G_PAM4_anlt|hssi_ss_0|kr_dut_8|eth_anlt_f_inst8 -to inst_port1_hssi_50G_PAM4_anlt|hssi_ss_0|U_eth_f_inst_p8|eth_f_top_p8 -entity top
set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port2_hssi_50G_PAM4_anlt|hssi_ss_0|kr_dut_8|eth_anlt_f_inst8 -to inst_port2_hssi_50G_PAM4_anlt|hssi_ss_0|U_eth_f_inst_p8|eth_f_top_p8 -entity top

# IP Selection
# ============================
set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_50G/hssi_ss_50G_PAM4_anlt.ip

} elseif {$param_value eq "50G_NON_ANLT"} {
puts "Info: Configuration selected is 50G_NON_ANLT"
# Verilog Macro Settings
# ============================
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_50G_AUI1_PAM4
set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G

# ETH SERIAL IO
# 13C qsfp connector quad2
set_location_assignment PIN_W10 -to ftile_tx_serial[0]
set_location_assignment PIN_V11 -to ftile_tx_serial_n[0]
set_location_assignment PIN_W4 -to ftile_rx_serial[0]
set_location_assignment PIN_V5 -to ftile_rx_serial_n[0]

# 13A qsfp connector quad2
set_location_assignment PIN_CH7 -to ftile_tx_serial[1]
set_location_assignment PIN_CG8 -to ftile_tx_serial_n[1]
set_location_assignment PIN_CJ4 -to ftile_rx_serial[1]
set_location_assignment PIN_CK5 -to ftile_rx_serial_n[1]

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[1] -entity top

set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[0] -entity top

set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[1] -entity top

# Logic Generation Assignments
# ============================
#set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port1_hssi_50G_PAM4_anlt|hssi_ss_0|kr_dut_8|eth_anlt_f_inst8 -to inst_port1_hssi_50G_PAM4_anlt|hssi_ss_0|U_eth_f_inst_p8|eth_f_top_p8 -entity top
#set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port2_hssi_50G_PAM4_anlt|hssi_ss_0|kr_dut_8|eth_anlt_f_inst8 -to inst_port2_hssi_50G_PAM4_anlt|hssi_ss_0|U_eth_f_inst_p8|eth_f_top_p8 -entity top
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_LOW_LOSS" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_LOW_LOSS" -to ftile_rx_serial[1] -entity top

# IP Selection
# ============================
set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_50G/hssi_ss_50G_PAM4.ip

} elseif {$param_value eq "100G_ANLT"} {
puts "Info: Configuration selected is 100G_ANLT"
# Verilog Macro Settings
# ============================
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_100G_GAUI2_PAM4_ANLT
set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G

# 13C - ETH SERIAL IO 
set_location_assignment PIN_W10  -to ftile_tx_serial[0]
set_location_assignment PIN_V11  -to ftile_tx_serial_n[0]
set_location_assignment PIN_T7   -to ftile_tx_serial[1]
set_location_assignment PIN_U8   -to ftile_tx_serial_n[1]
set_location_assignment PIN_CH7  -to ftile_tx_serial[2]
set_location_assignment PIN_CG8  -to ftile_tx_serial_n[2]
set_location_assignment PIN_CE10 -to ftile_tx_serial[3]
set_location_assignment PIN_CF11 -to ftile_tx_serial_n[3]

set_location_assignment PIN_W4  -to ftile_rx_serial[0]
set_location_assignment PIN_V5  -to ftile_rx_serial_n[0]
set_location_assignment PIN_M1  -to ftile_rx_serial[1]
set_location_assignment PIN_N2  -to ftile_rx_serial_n[1]
set_location_assignment PIN_CJ4 -to ftile_rx_serial[2]
set_location_assignment PIN_CK5 -to ftile_rx_serial_n[2]
set_location_assignment PIN_CH1 -to ftile_rx_serial[3]
set_location_assignment PIN_CG2 -to ftile_rx_serial_n[3]


set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[3] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[3] -entity top

set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[3] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[3] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[3] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[3] -entity top


# Logic Generation Assignments
# ============================
set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port1_hssi_100G_PAM4_anlt|hssi_ss_0|kr_dut_8|eth_anlt_f_inst8 -to inst_port1_hssi_100G_PAM4_anlt|hssi_ss_0|U_eth_f_inst_p8|eth_f_top_p8 -entity top
set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port2_hssi_100G_PAM4_anlt|hssi_ss_0|kr_dut_8|eth_anlt_f_inst8 -to inst_port2_hssi_100G_PAM4_anlt|hssi_ss_0|U_eth_f_inst_p8|eth_f_top_p8 -entity top

# IP Selection
# ============================
set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_100G/hssi_ss_100G_PAM4_anlt.ip

} elseif {$param_value eq "100G_NON_ANLT"} {
puts "Info: Configuration selected is 100G_NON_ANLT"
# Verilog Macro Settings
# ============================
set_global_assignment -name VERILOG_MACRO FTILE_PTP_HSSI_100G_GAUI2_PAM4
set_global_assignment -name VERILOG_MACRO MAC_SRD_CFG_25G

# 13C - ETH SERIAL IO 
set_location_assignment PIN_W10  -to ftile_tx_serial[0]
set_location_assignment PIN_V11  -to ftile_tx_serial_n[0]
set_location_assignment PIN_T7   -to ftile_tx_serial[1]
set_location_assignment PIN_U8   -to ftile_tx_serial_n[1]
set_location_assignment PIN_CH7  -to ftile_tx_serial[2]
set_location_assignment PIN_CG8  -to ftile_tx_serial_n[2]
set_location_assignment PIN_CE10 -to ftile_tx_serial[3]
set_location_assignment PIN_CF11 -to ftile_tx_serial_n[3]

set_location_assignment PIN_W4  -to ftile_rx_serial[0]
set_location_assignment PIN_V5  -to ftile_rx_serial_n[0]
set_location_assignment PIN_M1  -to ftile_rx_serial[1]
set_location_assignment PIN_N2  -to ftile_rx_serial_n[1]
set_location_assignment PIN_CJ4 -to ftile_rx_serial[2]
set_location_assignment PIN_CK5 -to ftile_rx_serial_n[2]
set_location_assignment PIN_CH1 -to ftile_rx_serial[3]
set_location_assignment PIN_CG2 -to ftile_rx_serial_n[3]


set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to ftile_rx_serial[3] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to ftile_rx_serial[3] -entity top

set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to ftile_tx_serial[3] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to ftile_tx_serial[3] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to ftile_tx_serial[3] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to ftile_tx_serial[3] -entity top


# Logic Generation Assignments
# ============================
#set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port1_hssi_100G_PAM4_anlt|hssi_ss_0|kr_dut_8|eth_anlt_f_inst8 -to inst_port1_hssi_100G_PAM4_anlt|hssi_ss_0|U_eth_f_inst_p8|eth_f_top_p8 -entity top
#set_instance_assignment -name IP_COLOCATE F_TILE -from inst_port2_hssi_100G_PAM4_anlt|hssi_ss_0|kr_dut_8|eth_anlt_f_inst8 -to inst_port2_hssi_100G_PAM4_anlt|hssi_ss_0|U_eth_f_inst_p8|eth_f_top_p8 -entity top
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_LOW_LOSS" -to ftile_rx_serial[0] -entity top
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_LOW_LOSS" -to ftile_rx_serial[1] -entity top
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_LOW_LOSS" -to ftile_rx_serial[2] -entity top
set_instance_assignment -name HSSI_PARAMETER "vsr_mode=VSR_MODE_LOW_LOSS" -to ftile_rx_serial[3] -entity top

# IP Selection
# ============================
set_global_assignment -name IP_FILE ../src/ip/qsys_top/hssi_ss_100G/hssi_ss_100G_PAM4.ip

}
