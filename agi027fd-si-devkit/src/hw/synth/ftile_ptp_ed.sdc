
# ######################################################################## 
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
# ######################################################################## 

create_clock -name {MAIN_CLOCK} -period 10.000 -waveform { 0.000 5.000 } [get_ports {fpga_clk_100}]
create_clock -name {TOD_CLOCK} -period 6.400 -waveform { 0.000 3.200 } [get_ports {ftile_master_todclk_ref}]
#create_clock -name {FTILE_CLOCK} -period 6.400 -waveform { 0.000 3.200 } [get_ports {ftile_clk_ref}]
create_clock -name {EMIF_REF_CLOCK} -period 6.666 -waveform { 0.000 3.333 } [get_ports {emif_hps_pll_ref_clk}]

set zl_clk hps_i2c_internal
set qsfp_0_clk MAIN_CLOCK
set_clock_groups -asynchronous -group [get_clocks {inst_qsys_top|dma_subsys|iopll_clk_avst_div2|altera_iopll_inst_outclk0}] -group [get_clocks {top_auto_tiles|z1577b_*||tx_clkout|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_qsys_top|sys_manager|ftile_iopll_ptp_sampling|iopll_0_refclk}] -group [get_clocks {top_auto_tiles|z1577b_*||tx_clkout|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_qsys_top|sys_manager|ftile_iopll_ptp_sampling|iopll_0_refclk}] -group [get_clocks {inst_port*_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|*x_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {TOD_CLOCK}] -group [get_clocks {inst_port*_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|*x_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_qsys_top|sys_manager|tod_sync_25g_iopll_0|tod_sync_25g_iopll_0_n_cnt_clk (INVERTED)}] -group [get_clocks {inst_port1_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|tx_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_qsys_top|sys_manager|tod_sync_25g_iopll_0|tod_sync_25g_iopll_0_n_cnt_clk (INVERTED)}] -group [get_clocks {inst_port2_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|tx_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_qsys_top|sys_manager|tod_sync_25g_iopll_0|tod_sync_25g_iopll_0_n_cnt_clk (INVERTED)}] -group [get_clocks {inst_port1_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|rx_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_qsys_top|sys_manager|tod_sync_25g_iopll_0|tod_sync_25g_iopll_0_n_cnt_clk (INVERTED)}] -group [get_clocks {inst_port2_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|rx_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_qsys_top|sys_manager|ftile_iopll_todsync_sampling|ftile_iopll_todsync_sampling_n_cnt_clk (INVERTED)}] -group [get_clocks {inst_port1_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|tx_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_qsys_top|sys_manager|ftile_iopll_todsync_sampling|ftile_iopll_todsync_sampling_n_cnt_clk (INVERTED)}] -group [get_clocks {inst_port2_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|tx_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_qsys_top|sys_manager|ftile_iopll_todsync_sampling|ftile_iopll_todsync_sampling_n_cnt_clk (INVERTED)}] -group [get_clocks {inst_port1_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|rx_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_qsys_top|sys_manager|ftile_iopll_todsync_sampling|ftile_iopll_todsync_sampling_n_cnt_clk (INVERTED)}] -group [get_clocks {inst_port2_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|rx_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_port1_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|tx_clkout2*|ch*}] -group [get_clocks {inst_port1_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|rx_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {inst_port2_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|tx_clkout2*|ch*}] -group [get_clocks {inst_port2_hssi_*|hssi_ss_*|U_eth_f_inst_p8|eth_f_top_p8|rx_clkout2*|ch*}]
set_clock_groups -asynchronous -group [get_clocks {TOD_CLOCK}] -group [get_clocks {inst_qsys_top|sys_manager|ftile_iopll_ptp_sampling|iopll_0_refclk}]

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
