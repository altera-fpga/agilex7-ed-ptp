# ######################################################################## 
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
# ######################################################################## 

create_clock -name {MAIN_CLOCK} -period 10.000 -waveform { 0.000 5.000 } [get_ports {fpga_clk_100}]
create_clock -name {TOD_CLOCK} -period 6.400 -waveform { 0.000 3.200 } [get_ports {ftile_master_todclk_ref}]
create_clock -name {FTILE_CLOCK} -period 6.400 -waveform { 0.000 3.200 } [get_ports {ftile_clk_ref}]
create_clock -name {EMIF_REF_CLOCK} -period 6.666 -waveform { 0.000 3.333 } [get_ports {emif_hps_pll_ref_clk}]

set zl_clk hps_i2c_internal
set qsfp_0_clk MAIN_CLOCK

set_false_path -from [get_ports {ref_pps_in}] -to *
set_false_path -from * -to [get_ports {qsfpdd_1_initmode}]
set_false_path -from * -to [get_ports {qsfpdd_0_initmode}]
set_false_path -from * -to [get_ports {qsfpdd_0_resetn}]
set_false_path -from * -to [get_ports {qsfpdd_0_modseln}]
set_false_path -from * -to [get_ports {master_tod_top_0_pulse_per_second}]
set_false_path -from * -to [get_ports {uart1_TX}]
set_false_path -from [get_ports {uart1_RX}] -to *
set_false_path -from [get_ports {qsfpdd_1_modprsn}] -to *
set_false_path -from [get_ports {qsfpdd_0_modprsn}] -to *
set_false_path -from [get_ports {qsfpdd_1_intn}] -to *
set_false_path -from [get_ports {qsfpdd_0_intn}] -to *
set_false_path -from [get_ports {qsfpdd_0_i2c_sda}] -to *
set_false_path -from * -to [get_ports {qsfpdd_0_i2c_sda}]
set_false_path -from [get_ports {qsfpdd_0_i2c_scl}] -to *
set_false_path -from * -to [get_ports {qsfpdd_0_i2c_scl}]
set_false_path -from [get_ports {qsfpdd_1_i2c_sda}] -to *
set_false_path -from * -to [get_ports {qsfpdd_1_i2c_sda}]
set_false_path -from [get_ports {qsfpdd_1_i2c_scl}] -to *
set_false_path -from * -to [get_ports {qsfpdd_1_i2c_scl}]
set_false_path -from [get_ports {zl_i2c_sda}] -to *
set_false_path -from * -to [get_ports {zl_i2c_sda}]
set_false_path -from [get_ports {zl_i2c_scl}] -to *
set_false_path -from * -to [get_ports {zl_i2c_scl}]

set_input_delay   -source_latency_included 1 -clock $qsfp_0_clk  [get_ports qsfpdd_0_i2c_sda]
set_output_delay  -source_latency_included 1 -clock $qsfp_0_clk  [get_ports qsfpdd_0_i2c_scl]
set_input_delay   -source_latency_included 1 -clock $qsfp_0_clk  [get_ports qsfpdd_1_i2c_sda]
set_output_delay  -source_latency_included 1 -clock $qsfp_0_clk  [get_ports qsfpdd_1_i2c_scl]
set_input_delay   -source_latency_included 1 -clock $qsfp_0_clk  [get_ports zl_i2c_sda]
set_output_delay  -source_latency_included 1 -clock $qsfp_0_clk  [get_ports zl_i2c_scl]
set_output_delay  -source_latency_included 1 -clock $qsfp_0_clk  [get_ports qsfpdd_1_initmode]
set_output_delay  -source_latency_included 1 -clock $qsfp_0_clk  [get_ports qsfpdd_0_initmode]
set_output_delay  -source_latency_included 1 -clock $qsfp_0_clk  [get_ports qsfpdd_0_resetn]
set_output_delay  -source_latency_included 1 -clock $qsfp_0_clk  [get_ports qsfpdd_0_modseln]
set_output_delay  -source_latency_included 1 -clock $qsfp_0_clk  [get_ports master_tod_top_0_pulse_per_second]
set_output_delay  -source_latency_included 1 -clock $qsfp_0_clk  [get_ports uart1_TX]


set_false_path -from {soc_inst|*axi_bridge_for_acp_0|csr_*} -to {*agilex_hps|intel_agilex_hps_inst|*}
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|agilex_axi_bridge_for_acp_0|agilex_axi_bridge_for_acp_0|csr_axuser*}]  -to [get_keepers -no_duplicates {inst_qsys_top|hps_sub_sys|agilex_hps|intel_agilex_hps_inst|fpga_interfaces|mpfe_inst|f2s_module~soc_mpfe_wrapper/s1235_0_24__vio_lab_core_periphery__clk[0].reg}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|agilex_axi_bridge_for_acp_0|agilex_axi_bridge_for_acp_0|csr_awdomain*}]  -to [get_keepers -no_duplicates {inst_qsys_top|hps_sub_sys|agilex_hps|intel_agilex_hps_inst|fpga_interfaces|mpfe_inst|f2s_module~soc_mpfe_wrapper/s1235_0_24__vio_lab_core_periphery__clk[0].reg}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|agilex_axi_bridge_for_acp_0|agilex_axi_bridge_for_acp_0|csr_ardomain*}]  -to [get_keepers -no_duplicates {inst_qsys_top|hps_sub_sys|agilex_hps|intel_agilex_hps_inst|fpga_interfaces|mpfe_inst|f2s_module~soc_mpfe_wrapper/s1235_0_24__vio_lab_core_periphery__clk[0].reg}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|agilex_axi_bridge_for_acp_0|agilex_axi_bridge_for_acp_0|csr_awcache*}]  -to [get_keepers -no_duplicates {inst_qsys_top|hps_sub_sys|agilex_hps|intel_agilex_hps_inst|fpga_interfaces|mpfe_inst|f2s_module~soc_mpfe_wrapper/s1235_0_24__vio_lab_core_periphery__clk[0].reg}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|agilex_axi_bridge_for_acp_0|agilex_axi_bridge_for_acp_0|csr_arcache*}]  -to [get_keepers -no_duplicates {inst_qsys_top|hps_sub_sys|agilex_hps|intel_agilex_hps_inst|fpga_interfaces|mpfe_inst|f2s_module~soc_mpfe_wrapper/s1235_0_24__vio_lab_core_periphery__clk[0].reg}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|agilex_axi_bridge_for_acp_0|agilex_axi_bridge_for_acp_0|csr_awbar*}]  -to [get_keepers -no_duplicates {inst_qsys_top|hps_sub_sys|agilex_hps|intel_agilex_hps_inst|fpga_interfaces|mpfe_inst|f2s_module~soc_mpfe_wrapper/s1235_0_24__vio_lab_core_periphery__clk[0].reg}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|agilex_axi_bridge_for_acp_0|agilex_axi_bridge_for_acp_0|csr_arbar*}]  -to [get_keepers -no_duplicates {inst_qsys_top|hps_sub_sys|agilex_hps|intel_agilex_hps_inst|fpga_interfaces|mpfe_inst|f2s_module~soc_mpfe_wrapper/s1235_0_24__vio_lab_core_periphery__clk[0].reg}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|agilex_axi_bridge_for_acp_0|agilex_axi_bridge_for_acp_0|csr_axprot*}]  -to [get_keepers -no_duplicates {inst_qsys_top|hps_sub_sys|agilex_hps|intel_agilex_hps_inst|fpga_interfaces|mpfe_inst|f2s_module~soc_mpfe_wrapper/s1235_0_24__vio_lab_core_periphery__clk[0].reg}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|agilex_axi_bridge_for_acp_0|agilex_axi_bridge_for_acp_0|csr_arsnoop*}]  -to [get_keepers -no_duplicates {inst_qsys_top|hps_sub_sys|agilex_hps|intel_agilex_hps_inst|fpga_interfaces|mpfe_inst|f2s_module~soc_mpfe_wrapper/s1235_0_24__vio_lab_core_periphery__clk[0].reg}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|agilex_axi_bridge_for_acp_0|agilex_axi_bridge_for_acp_0|csr_awsnoop*}]  -to [get_keepers -no_duplicates {inst_qsys_top|hps_sub_sys|agilex_hps|intel_agilex_hps_inst|fpga_interfaces|mpfe_inst|f2s_module~soc_mpfe_wrapper/s1235_0_24__vio_lab_core_periphery__clk[0].reg}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[*].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|wdata_cdc_fifo|auto_generated|rdaclr|dffe7a[*]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[*].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|araddr_cdc_fifo|auto_generated|rdaclr|dffe7a[*]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|araddr_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|araddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|rdata_cdc_fifo|auto_generated|wraclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|rdata_cdc_fifo|auto_generated|wraclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|waddr_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|wdata_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|waddr_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|waddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|rdata_cdc_fifo|auto_generated|wraclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|rdata_cdc_fifo|auto_generated|wraclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|wdata_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|waddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|wdata_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|araddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {rd1|cntr[*]}] -to [get_keepers -no_duplicates {GenClkRst[*].st_tx_rst_sync|resync_chains[*].synchronizer|dreg[*]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[0].tx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|bresp_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[0].tx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|bresp_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[0].rx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|bresp_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[0].rx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[0].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|bresp_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|araddr_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|araddr_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|waddr_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|waddr_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|araddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|araddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|waddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|waddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|waddr_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|waddr_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|waddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|waddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|wdata_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|wdata_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|wdata_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|wdata_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|araddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|araddr_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|rdata_cdc_fifo|auto_generated|wraclr|dffe7a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|rdata_cdc_fifo|auto_generated|wraclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|rdata_cdc_fifo|auto_generated|wraclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|rdata_cdc_fifo|auto_generated|wraclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|wdata_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|wdata_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|rdata_cdc_fifo|auto_generated|wraclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|rdata_cdc_fifo|auto_generated|wraclr|dffe7a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|rdata_cdc_fifo|auto_generated|wraclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|lite_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|rdata_cdc_fifo|auto_generated|wraclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[1].tx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|bresp_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[1].tx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|bresp_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[1].tx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|bresp_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[1].tx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_tx|bresp_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[1].rx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|bresp_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[1].rx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|bresp_cdc_fifo|auto_generated|rdaclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[1].rx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|bresp_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_rst_sync[1].rx_rst_sync|syn_rst}] -to [get_keepers -no_duplicates {ptp_bridge_subsys|ptp_bridge_top|gen_axi_lt_avmm[1].ptp_bridge_axi_lt_avmm_inst|axi_lt_to_avmm_rx|bresp_cdc_fifo|auto_generated|rdaclr|dffe8a[0]}]

set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|master_tod_top_0|master_tod_top_0|csr_tod_load}] -to [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|master_tod_top_0|master_tod_top_0|csr_tod_load_sync_inst|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|pps_control*}] -to [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|pps_control_1d}]

set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|master_tod_top_0|master_tod_top_0|o_tod_96b_valid*}] -to [get_keepers -no_duplicates {inst_qsys_top|tod_slave_subsys|port_*_tod_stack|port_0_tod_stack*|*x_tod|mtod_valid_sync_inst|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|master_tod_top_0|master_tod_top_0|o_tod_96b_valid*}] -to [get_keepers -no_duplicates {inst_qsys_top|tod_slave_subsys|port_*_tod_stack|port_0_tod_stack*|*x_tod_10g|mtod_valid_sync_inst|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|sys_manager|ftile_iopll_todsync_sampling|ftile_iopll_todsync_sampling|tennm_pll~pll_e_reg__nff}] -to [get_keepers -no_duplicates {inst_qsys_top|tod_slave_subsys|port_*_tod_stack|port_0_tod_stack*|*x_todsync_sampling_locked_sync_inst_10g|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|sys_manager|ftile_iopll_todsync_sampling|ftile_iopll_todsync_sampling|tennm_pll~pll_e_reg__nff}] -to [get_keepers -no_duplicates {inst_qsys_top|tod_slave_subsys|port_*_tod_stack|port_0_tod_stack*|*x_todsync_sampling_locked_sync_inst|din_s1}]

set_false_path -from [get_keepers -no_duplicates {rd1|cntr[27]}] -to [get_keepers -no_duplicates {GenClkRst[*].st_tx_rst_sync|resync_chains[0].synchronizer|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|rst_controller_00*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|csr_readdata[*]}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|rst_controller_00*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|pps_irq_reg}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|rst_controller_00*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|pps_in_csr_2d}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|rst_controller_00*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|read_latch[*]*}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|rst_controller_00*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|pps_in_csr_1d}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|rst_controller_00*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|pps_control*}]

set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|pps_control}] -to [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|pps_control_1d}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|tod_*seconds*_d2[*]}] -to [get_keepers -no_duplicates {inst_qsys_top|mtod_subsys|mtod_subsys_pps_load_tod_0|mtod_subsys_pps_load_tod_0|csr_readdata[*]}]
set_false_path -from [get_keepers -no_duplicates {gen_mulit_inst[*].i_eth_f_packet_client_top|packet_client_csr|reg_00[8]}] -to [get_keepers -no_duplicates {gen_mulit_inst[*].i_eth_f_packet_client_top|inst_stat_*x_cnt_clr_sync|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|tod_slave_subsys|port_0_tod_stack|port_0_tod_stack|tx_pll_locked_reg}] -to [get_keepers -no_duplicates {inst_qsys_top|tod_slave_subsys|port_0_tod_stack|port_0_tod_stack|tx_pll_locked_sync_inst|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|tod_slave_subsys|port_1_tod_stack|port_0_tod_stack_1|tx_pll_locked_reg}] -to [get_keepers -no_duplicates {inst_qsys_top|tod_slave_subsys|port_1_tod_stack|port_0_tod_stack_1|tx_pll_locked_sync_inst|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|dma_subsys_port*|rst_controller|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|dma_subsys_port*|ftile_*x_dma_ch1|*x_dma_fifo_0|*x_dma_fifo_0|cdc_packet_fifo|translate_*_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[*]}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|rst_controller_0*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|dma_subsys_port*|ftile_rx_dma_ch1|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|rst_controller_00*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|dma_subsys_port*|ftile_rx_dma_ch1|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|dma_subsys_port*|ftile_*x_dma_ch1|*x_dma_fifo_0|*x_dma_fifo_0|cdc_packet_fifo|translate_*_pointer|toggle_in|toggled_signal*}] -to [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|dma_subsys_port*|ftile_*x_dma_ch1|*x_dma_fifo_0|*x_dma_fifo_0|cdc_packet_fifo|translate_*_pointer|toggle_in|inst_cdc_sync*|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|dma_subsys_port*|ftile_*x_dma_ch1|*x_dma_fifo_0|*x_dma_fifo_0|cdc_packet_fifo|translate_*_pointer|reg_in*}] -to [get_keepers -no_duplicates {inst_qsys_top|dma_subsys|dma_subsys_port*|ftile_*x_dma_ch1|*x_dma_fifo_0|*x_dma_fifo_0|cdc_packet_fifo|translate_*_pointer|sync|in_data_meta[*]}]
set_false_path -from [get_keepers -no_duplicates {inst_port*_hssi_*|hssi_ss_*|U_eth_f_inst_p*|eth_f_top_p*|sip_inst|o_rx_pcs_ready_r}] -to [get_keepers -no_duplicates {sts_gen*[*].ftile_debug_status*|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_port*_hssi_*|hssi_ss_*|U_eth_f_inst_p*|eth_f_top_p*|sip_inst|o_tx_lanes_stable_r}] -to [get_keepers -no_duplicates {sts_gen*[*].ftile_debug_status*|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_port*_hssi_*|hssi_ss_*|U_eth_f_inst_p*|eth_f_top_p*|sip_inst|PTP_SOFT_GEN.rx_ptp_ready_tx_rst_gated}] -to [get_keepers -no_duplicates {sts_gen*[*].ftile_debug_status*|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_port*_hssi_*|hssi_ss_*|U_eth_f_inst_p*|eth_f_top_p*|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_state_ctrl_u|o_rx_ptp_offset_data_valid}] -to [get_keepers -no_duplicates {sts_gen*[*].ftile_debug_status*|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_port*_hssi_*|hssi_ss_*|U_eth_f_inst_p*|eth_f_top_p*|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_state_ctrl_u|o_tx_ptp_ready}] -to [get_keepers -no_duplicates {sts_gen*[*].ftile_debug_status*|din_s1}]
set_false_path -from [get_keepers -no_duplicates {inst_port*_hssi_*|hssi_ss_*|U_eth_f_inst_p*|eth_f_top_p*|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_state_ctrl_u|o_tx_ptp_offset_data_valid}] -to [get_keepers -no_duplicates {sts_gen*[*].ftile_debug_status*|din_s1}]

set_false_path -from [get_keepers -no_duplicates {rd1|cntr[*]}] -to [get_keepers -no_duplicates {gen_dma_gbx_ptpb_inst_*[*].inst_dma_gbx_ptpb_*|ptp_gbx_*x|rst_sync|*rst*}]


