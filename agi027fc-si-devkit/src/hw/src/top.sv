//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

import ofs_fim_eth_if_pkg::*;
import macsec_srd_pkg::*;
import ptp_bridge_pkg::*;
import ptp_bridge_hdr_pkg::*;
`include "custom_rtl/hssi/ofs_fim_axi_lite_if.sv"

  module top #(
  	   parameter FP_WIDTH                      = 20
     `ifdef FTILE_PTP_HSSI_25G 
      ,parameter ETHERNET_PORTS               = 2
      ,parameter ETHERNET_RATE                = 25   // supports 10/25/50/100/200/400   
      ,parameter DMA_TDATA_WIDTH              = 64   // supports only 64b
      ,parameter HSSI_TDATA_WIDTH	          = 64   // supports 64/128/256/512/1024
      ,parameter HSSI_NUM_OF_SEG              = 1    // supports 1/2/4/8/16
      ,parameter TX_USER_CLIENT_WIDTH         = 2
      ,parameter RX_USER_CLIENT_WIDTH         = 7
      ,parameter RX_USER_STS_WIDTH            = 5  
      ,parameter WORDS                        = 1 //8 NOTE: WORDS = 1, DATA WIDTH = WORDS*64 = 64
      ,parameter EMPTY_WIDTH                  = 4 //6 NOTE: EMPTY_WIDTH = $clog2(DATA_WIDTH/8)+1;
    `elsif FTILE_PTP_HSSI_25G_ANLT
      ,parameter ETHERNET_PORTS               = 2
      ,parameter ETHERNET_RATE                = 25   // supports 10/25/50/100/200/400   
      ,parameter DMA_TDATA_WIDTH              = 64   // supports only 64b
      ,parameter HSSI_TDATA_WIDTH	          = 64   // supports 64/128/256/512/1024
      ,parameter HSSI_NUM_OF_SEG              = 1    // supports 1/2/4/8/16
      ,parameter TX_USER_CLIENT_WIDTH         = 2
      ,parameter RX_USER_CLIENT_WIDTH         = 7
      ,parameter RX_USER_STS_WIDTH            = 5  
      ,parameter WORDS                        = 1 //8 NOTE: WORDS = 1, DATA WIDTH = WORDS*64 = 64
      ,parameter EMPTY_WIDTH                  = 4 //6 NOTE: EMPTY_WIDTH = $clog2(DATA_WIDTH/8)+1;
    `elsif FTILE_PTP_HSSI_10G_25G_NON_ANLT_DR
      ,parameter ETHERNET_PORTS               = 2
      ,parameter ETHERNET_RATE                = 25   // supports 10/25/50/100/200/400   
      ,parameter DMA_TDATA_WIDTH              = 64   // supports only 64b
      ,parameter HSSI_TDATA_WIDTH	          = 64   // supports 64/128/256/512/1024
      ,parameter HSSI_NUM_OF_SEG              = 1    // supports 1/2/4/8/16
      ,parameter TX_USER_CLIENT_WIDTH         = 2
      ,parameter RX_USER_CLIENT_WIDTH         = 7
      ,parameter RX_USER_STS_WIDTH            = 5  
      ,parameter WORDS                        = 1 //8 NOTE: WORDS = 1, DATA WIDTH = WORDS*64 = 64
      ,parameter EMPTY_WIDTH                  = 4 //6 NOTE: EMPTY_WIDTH = $clog2(DATA_WIDTH/8)+1;
    `elsif FTILE_PTP_HSSI_50G_AUI1_PAM4_ANLT 
      ,parameter ETHERNET_PORTS               = 2
      ,parameter ETHERNET_RATE                = 50   // supports 10/25/50/100/200/400   
      ,parameter DMA_TDATA_WIDTH              = 64   // supports only 64b
      ,parameter HSSI_TDATA_WIDTH	          = 128  // supports 64/128/256/512/1024
      ,parameter HSSI_NUM_OF_SEG              = 2    // supports 1/2/4/8/16
      ,parameter TX_USER_CLIENT_WIDTH         = 4
      ,parameter RX_USER_CLIENT_WIDTH         = 14
      ,parameter RX_USER_STS_WIDTH            = 10
      ,parameter WORDS                        = 2 //8 NOTE: WORDS = 1, DATA WIDTH = WORDS*64 = 64
      ,parameter EMPTY_WIDTH                  = 5 //6 NOTE: EMPTY_WIDTH = $clog2(DATA_WIDTH/8)+1;
    `elsif FTILE_PTP_HSSI_50G_AUI1_PAM4 
      ,parameter ETHERNET_PORTS               = 2
      ,parameter ETHERNET_RATE                = 50   // supports 10/25/50/100/200/400   
      ,parameter DMA_TDATA_WIDTH              = 64   // supports only 64b
      ,parameter HSSI_TDATA_WIDTH	          = 128  // supports 64/128/256/512/1024
      ,parameter HSSI_NUM_OF_SEG              = 2    // supports 1/2/4/8/16
      ,parameter TX_USER_CLIENT_WIDTH         = 4
      ,parameter RX_USER_CLIENT_WIDTH         = 14
      ,parameter RX_USER_STS_WIDTH            = 10
      ,parameter WORDS                        = 2 //8 NOTE: WORDS = 1, DATA WIDTH = WORDS*64 = 64
      ,parameter EMPTY_WIDTH                  = 5 //6 NOTE: EMPTY_WIDTH = $clog2(DATA_WIDTH/8)+1;
     `elsif FTILE_PTP_HSSI_100G_GAUI2_PAM4_ANLT 
      ,parameter ETHERNET_PORTS               = 4
      ,parameter ETHERNET_RATE                = 100  // supports 10/25/50/100/200/400   
      ,parameter DMA_TDATA_WIDTH              = 64   // supports only 64b
      ,parameter HSSI_TDATA_WIDTH	          = 256  // supports 64/128/256/512/1024
      ,parameter HSSI_NUM_OF_SEG              = 4    // supports 1/2/4/8/16
      ,parameter TX_USER_CLIENT_WIDTH         = 8
      ,parameter RX_USER_CLIENT_WIDTH         = 28
      ,parameter RX_USER_STS_WIDTH            = 20
      ,parameter WORDS                        = 4 //8 NOTE: WORDS = 1, DATA WIDTH = WORDS*64 = 64
      ,parameter EMPTY_WIDTH                  = 6 //6 NOTE: EMPTY_WIDTH = $clog2(DATA_WIDTH/8)+1;
     `elsif FTILE_PTP_HSSI_100G_GAUI2_PAM4 
      ,parameter ETHERNET_PORTS               = 4
      ,parameter ETHERNET_RATE                = 100  // supports 10/25/50/100/200/400   
      ,parameter DMA_TDATA_WIDTH              = 64   // supports only 64b
      ,parameter HSSI_TDATA_WIDTH	          = 256  // supports 64/128/256/512/1024
      ,parameter HSSI_NUM_OF_SEG              = 4    // supports 1/2/4/8/16
      ,parameter TX_USER_CLIENT_WIDTH         = 8
      ,parameter RX_USER_CLIENT_WIDTH         = 28
      ,parameter RX_USER_STS_WIDTH            = 20
      ,parameter WORDS                        = 4 //8 NOTE: WORDS = 1, DATA WIDTH = WORDS*64 = 64
      ,parameter EMPTY_WIDTH                  = 6 //6 NOTE: EMPTY_WIDTH = $clog2(DATA_WIDTH/8)+1;
    `elsif FTILE_PTP_HSSI_10G_ANLT
      ,parameter ETHERNET_PORTS               = 2
      ,parameter ETHERNET_RATE                = 10   // supports 10/25/50/100/200/400   
      ,parameter DMA_TDATA_WIDTH              = 64   // supports only 64b
      ,parameter HSSI_TDATA_WIDTH	          = 64   // supports 64/128/256/512/1024
      ,parameter HSSI_NUM_OF_SEG              = 1    // supports 1/2/4/8/16
      ,parameter TX_USER_CLIENT_WIDTH         = 2
      ,parameter RX_USER_CLIENT_WIDTH         = 7
      ,parameter RX_USER_STS_WIDTH            = 5  
      ,parameter WORDS                        = 1 //8 NOTE: WORDS = 1, DATA WIDTH = WORDS*64 = 64
      ,parameter EMPTY_WIDTH                  = 4 //6 NOTE: EMPTY_WIDTH = $clog2(DATA_WIDTH/8)+1;
    `else //FTILE_PTP_HSSI_10G
      ,parameter ETHERNET_PORTS               = 2
      ,parameter ETHERNET_RATE                = 10   // supports 10/25/50/100/200/400   
      ,parameter DMA_TDATA_WIDTH              = 64   // supports only 64b
      ,parameter HSSI_TDATA_WIDTH	          = 64   // supports 64/128/256/512/1024
      ,parameter HSSI_NUM_OF_SEG              = 1    // supports 1/2/4/8/16
      ,parameter TX_USER_CLIENT_WIDTH         = 2
      ,parameter RX_USER_CLIENT_WIDTH         = 7
      ,parameter RX_USER_STS_WIDTH            = 5
      ,parameter WORDS                        = 1 //8 NOTE: WORDS = 1, DATA WIDTH = WORDS*64 = 64
      ,parameter EMPTY_WIDTH                  = 4 //6 NOTE: EMPTY_WIDTH = $clog2(DATA_WIDTH/8)+1;
    `endif 
    ,parameter NUM_PORTS                       = 2
    ,parameter DMA_NUM_OF_SEG                  = 1    // supports only 1
    ,parameter DMA_NUM_OF_SOP                  = 1    // supports only 1 	
    ,parameter HSSI_NUM_OF_SOP                 = 1    // supports only 1
    ,parameter TXEGR_TS_DW                     = 128
    ,parameter RXIGR_TS_DW                     = 96
    ,parameter PTP_WIDTH                       = 94
    ,parameter PTP_EXT_WIDTH                   = 328
    ,parameter PKT_CYL                         = 1
    ,parameter CLIENT_IF_TYPE                  = 1   // 0:Segmented; 1:AvST;
    ,parameter READY_LATENCY                   = 0
    ,parameter DATA_WIDTH       	              = 64 
    ,parameter DMA_CHS                         = 6
    ,parameter TS_REQ_FP_WIDTH                 = 20
  )
  (

    // Clock and Reset
    input    wire                   fpga_clk_100,
    input    wire [1:0]             ftile_clk_ref,
    input    wire                   ftile_master_todclk_ref,
    output   wire [ETHERNET_PORTS-1:0]   ftile_tx_serial,
    output   wire [ETHERNET_PORTS-1:0]   ftile_tx_serial_n,
    input    wire [ETHERNET_PORTS-1:0]   ftile_rx_serial,
    input    wire [ETHERNET_PORTS-1:0]   ftile_rx_serial_n,
    output   wire                   master_tod_top_0_pulse_per_second,
    input    wire                   ref_pps_in,

    output   wire                   hssi_cdr_clk_out,
    
    //QSFP Sideband
    input    wire                   qsfpdd_0_modprsn,
    output   wire                   qsfpdd_0_resetn,
    output   wire                   qsfpdd_0_modseln,
    input    wire                   qsfpdd_0_intn,
    // initmode  == lpmode
    output   wire                   qsfpdd_0_initmode,
    inout    wire                   qsfpdd_0_i2c_scl,
    inout    wire                   qsfpdd_0_i2c_sda,
    //QSFP_1 Sideband
    input    wire                   qsfpdd_1_modprsn,
    output   wire                   qsfpdd_1_resetn,
    output   wire                   qsfpdd_1_modseln,
    input    wire                   qsfpdd_1_intn,
    // initmode  == lpmode
    output   wire                   qsfpdd_1_initmode,
    inout    wire                   qsfpdd_1_i2c_scl,
    inout    wire                   qsfpdd_1_i2c_sda,
    
    inout    wire                   zl_i2c_scl,
    inout    wire                   zl_i2c_sda,
    
    input    wire                   uart1_RX,
    output   wire                   uart1_TX,

    ////HPS
    output   wire [0:0]             emif_hps_mem_mem_ck,
    output   wire [0:0]             emif_hps_mem_mem_ck_n,
    output   wire [16:0]            emif_hps_mem_mem_a,
    output   wire [0:0]             emif_hps_mem_mem_act_n,
    output   wire [1:0]             emif_hps_mem_mem_ba,
    output   wire [1-1:0]           emif_hps_mem_mem_bg,
    output   wire [0:0]             emif_hps_mem_mem_cke,
    output   wire [0:0]             emif_hps_mem_mem_cs_n,
    output   wire [0:0]             emif_hps_mem_mem_odt,
    output   wire [0:0]             emif_hps_mem_mem_reset_n,
    output   wire [0:0]             emif_hps_mem_mem_par,
    input    wire [0:0]             emif_hps_mem_mem_alert_n,
    input    wire                   emif_hps_oct_oct_rzqin,
    input    wire                   emif_hps_pll_ref_clk,
    inout    wire [8-1:0]           emif_hps_mem_mem_dbi_n,
    inout    wire [64-1:0]          emif_hps_mem_mem_dq,
    inout    wire [8-1:0]           emif_hps_mem_mem_dqs,
    inout    wire [8-1:0]           emif_hps_mem_mem_dqs_n,
    input    wire                   hps_jtag_tck,
    input    wire                   hps_jtag_tms,
    output   wire                   hps_jtag_tdo,
    input    wire                   hps_jtag_tdi,
    output   wire                   hps_sdmmc_CCLK,
    inout    wire                   hps_sdmmc_CMD,
    inout    wire                   hps_sdmmc_D0,
    inout    wire                   hps_sdmmc_D1,
    inout    wire                   hps_sdmmc_D2,
    inout    wire                   hps_sdmmc_D3,
    inout    wire                   hps_usb0_DATA0,
    inout    wire                   hps_usb0_DATA1,
    inout    wire                   hps_usb0_DATA2,
    inout    wire                   hps_usb0_DATA3,
    inout    wire                   hps_usb0_DATA4,
    inout    wire                   hps_usb0_DATA5,
    inout    wire                   hps_usb0_DATA6,
    inout    wire                   hps_usb0_DATA7,
    input    wire                   hps_usb0_CLK,
    output   wire                   hps_usb0_STP,
    input    wire                   hps_usb0_DIR,
    input    wire                   hps_usb0_NXT, 
    output   wire                   hps_emac0_TX_CLK,
    input    wire                   hps_emac0_RX_CLK,
    output   wire                   hps_emac0_TX_CTL,
    input    wire                   hps_emac0_RX_CTL,
    output   wire                   hps_emac0_TXD0,
    output   wire                   hps_emac0_TXD1,
    input    wire                   hps_emac0_RXD0,
    input    wire                   hps_emac0_RXD1,
    output   wire                   hps_emac0_TXD2,
    output   wire                   hps_emac0_TXD3,
    input    wire                   hps_emac0_RXD2,
    input    wire                   hps_emac0_RXD3,
    inout    wire                   hps_emac0_MDIO,
    output   wire                   hps_emac0_MDC,
    input    wire                   hps_uart0_RX,
    output   wire                   hps_uart0_TX, 
    inout    wire                   hps_gpio1_io0,
    inout    wire                   hps_gpio1_io1,
    inout    wire                   hps_gpio1_io4,
    inout    wire                   hps_gpio1_io5,
    inout    wire                   hps_gpio1_io6,
    inout    wire                   hps_gpio1_io7,
    inout    wire                   hps_gpio1_io19,
    inout    wire                   hps_gpio1_io20,
    inout    wire                   hps_gpio1_io21,
    input    wire                   hps_ref_clk
 );


  localparam USER_DATA_WIDTH  = HSSI_TDATA_WIDTH;
  localparam USER_TKEEP_WIDTH = HSSI_TDATA_WIDTH/8;
  localparam USER_NUM_OF_SEG = DMA_NUM_OF_SEG; 
  localparam STS_WIDTH = 5;
  localparam STS_EXT_WIDTH = 32;
  localparam TX_CLIENT_WIDTH = 2;
  localparam RX_CLIENT_WIDTH = 7;
  localparam PTP_BRDG_AWADDR_WIDTH = 16;
  localparam PTP_BRDG_WDATA_WIDTH = 32;
  localparam PTP_BRDG_HSSI_IGR_FIFO_DEPTH = 2048;
  localparam PTP_BRDG_USER_IGR_FIFO_DEPTH = 512;
  localparam PTP_BRDG_DMA_IGR_FIFO_DEPTH  = 512;
  localparam TCAM_KEY_WIDTH = 492;
  localparam TCAM_RESULT_WIDTH = 32;
  localparam TCAM_ENTRIES = 32;
  localparam TCAM_USERMETADATA_WIDTH = 1;
  localparam IGR_DMA_BYTE_ROTATE = 0;
  localparam IGR_USER_BYTE_ROTATE = 0;
  localparam IGR_HSSI_BYTE_ROTATE = 1;
  localparam EGR_DMA_BYTE_ROTATE = 1;
  localparam EGR_USER_BYTE_ROTATE = 1;
  localparam EGR_HSSI_BYTE_ROTATE = 0;
  localparam DBG_CNTR_EN = 0;
  
  logic [NUM_PORTS-1:0] tx_init_done, rx_init_done;
  localparam AWADDR_WIDTH = 32;
  localparam WDATA_WIDTH = 32;

  logic [NUM_PORTS-1:0][AWADDR_WIDTH - 1:0]     axi_lite_tcam_awaddr_o; 
  logic [NUM_PORTS-1:0]                         axi_lite_tcam_awvalid_o;
  logic [NUM_PORTS-1:0]                         axi_lite_tcam_awready_i;
  logic [NUM_PORTS-1:0] [WDATA_WIDTH - 1:0]     axi_lite_tcam_wdata_o; 
  logic [NUM_PORTS-1:0]                         axi_lite_tcam_wvalid_o;
  logic [NUM_PORTS-1:0] [(WDATA_WIDTH/8) - 1:0] axi_lite_tcam_wstrb_o; 
  logic [NUM_PORTS-1:0]                         axi_lite_tcam_wready_i; 
  logic [NUM_PORTS-1:0][1:0]                    axi_lite_tcam_bresp_i; 
  logic [NUM_PORTS-1:0]                         axi_lite_tcam_bvalid_i; 
  logic [NUM_PORTS-1:0]                         axi_lite_tcam_bready_o; 
  logic [NUM_PORTS-1:0] [AWADDR_WIDTH - 1:0]    axi_lite_tcam_araddr_o; 
  logic [NUM_PORTS-1:0]                         axi_lite_tcam_arvalid_o; 
  logic [NUM_PORTS-1:0]                         axi_lite_tcam_arready_i; 
  logic [NUM_PORTS-1:0][1:0]                    axi_lite_tcam_rresp_i;
  logic [NUM_PORTS-1:0] [WDATA_WIDTH - 1:0]     axi_lite_tcam_rdata_i;
  logic [NUM_PORTS-1:0]                         axi_lite_tcam_rvalid_i; 
  logic [NUM_PORTS-1:0]                         axi_lite_tcam_rready_o;
  
  logic [NUM_PORTS-1:0]                         user_axi_st_tx_tvalid_i;
  logic [NUM_PORTS-1:0][USER_DATA_WIDTH-1:0]    user_axi_st_tx_tdata_i;
  logic [NUM_PORTS-1:0][USER_TKEEP_WIDTH-1:0]  user_axi_st_tx_tkeep_i;
  logic [NUM_PORTS-1:0]                         user_axi_st_tx_tlast_i;
  logic [NUM_PORTS-1:0][PTP_WIDTH-1:0]          user_axi_st_tx_tuser_ptp_i;
  logic [NUM_PORTS-1:0][PTP_EXT_WIDTH-1:0]      user_axi_st_tx_tuser_ptp_extended_i;
  logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0] 
                                        [TX_CLIENT_WIDTH-1:0]  user_axi_st_tx_tuser_client_i;
  logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0]    user_axi_st_tx_tuser_pkt_seg_parity_i;
  logic [NUM_PORTS-1:0]                         user_axi_st_rx_tvalid_o;
  logic [NUM_PORTS-1:0] [USER_DATA_WIDTH-1:0]   user_axi_st_rx_tdata_o;
  logic [NUM_PORTS-1:0] [USER_TKEEP_WIDTH-1:0] user_axi_st_rx_tkeep_o;
  logic [NUM_PORTS-1:0]                         user_axi_st_rx_tlast_o;
  logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0]
                                       [RX_CLIENT_WIDTH-1:0] user_axi_st_rx_tuser_client_o;
  logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0] 
  									    [STS_WIDTH-1:0] user_axi_st_rx_tuser_sts_o;
  logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0]
                                          [STS_EXT_WIDTH-1:0] user_axi_st_rx_tuser_sts_extended_o;
  logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0]    user_axi_st_rx_tuser_pkt_seg_parity_o;
  logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0]    user_axi_st_rx_tuser_last_segment_o;
  logic  [NUM_PORTS-1:0]                        user_axi_st_rx_tready_i;
  
  logic [NUM_PORTS-1:0]                         user_axi_st_txegrts0_tvalid_o;
  logic [NUM_PORTS-1:0][TXEGR_TS_DW-1:0]        user_axi_st_txegrts0_tdata_o;
  logic [NUM_PORTS-1:0]                         user_axi_st_txegrts1_tvalid_o;
  logic [NUM_PORTS-1:0][TXEGR_TS_DW-1:0]        user_axi_st_txegrts1_tdata_o;
  
  logic [NUM_PORTS-1:0]                         user_axi_st_rxigrts0_tvalid_o;
  logic [NUM_PORTS-1:0][RXIGR_TS_DW-1:0]        user_axi_st_rxigrts0_tdata_o;
  logic [NUM_PORTS-1:0]                         user_axi_st_rxigrts1_tvalid_o;
  logic [NUM_PORTS-1:0][RXIGR_TS_DW-1:0]        user_axi_st_rxigrts1_tdata_o;
  
  logic [DMA_CHS-1:0]                                    axi_st_tx_tvalid_i                ;
  logic [DMA_CHS-1:0]  [DMA_TDATA_WIDTH-1:0]             axi_st_tx_tdata_i                 ;
  logic [DMA_CHS-1:0]  [DMA_TDATA_WIDTH/8-1:0]           axi_st_tx_tkeep_i                 ;
  logic [DMA_CHS-1:0]                                    axi_st_tx_tlast_i                 ;
  logic [DMA_CHS-1:0]  [PTP_WIDTH -1:0]                  axi_st_tx_tuser_ptp_i             ;
  logic [DMA_CHS-1:0]  [PTP_EXT_WIDTH -1:0]              axi_st_tx_tuser_ptp_extended_i    ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0] [1:0]        axi_st_tx_tuser_client_i          ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0]              axi_st_tx_tuser_pkt_seg_parity_i  ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0]              axi_st_tx_tuser_last_segment_i    ;
  logic [DMA_CHS-1:0]                                    axi_st_tx_tready_o                ;
  
  logic [DMA_CHS-1:0]                                    axi_st_rx_tvalid_o                ;
  logic [DMA_CHS-1:0]  [DMA_TDATA_WIDTH-1:0]             axi_st_rx_tdata_o                 ;
  logic [DMA_CHS-1:0]  [DMA_TDATA_WIDTH/8-1:0]           axi_st_rx_tkeep_o                 ;
  logic [DMA_CHS-1:0]                                    axi_st_rx_tlast_o                 ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0] [6:0]        axi_st_rx_tuser_client_o          ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0] [4:0]        axi_st_rx_tuser_sts_o             ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0] [31:0]       axi_st_rx_tuser_sts_extended_o    ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0]              axi_st_rx_tuser_pkt_seg_parity_o  ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0]              axi_st_rx_tuser_last_segment_o    ;
  logic [DMA_CHS-1:0]                                    axi_st_rx_tready_i                ;
  
  
  logic [DMA_CHS-1:0]                                    dma_gbx_ptpb_axi_st_tx_tvalid                ;
  logic [DMA_CHS-1:0]  [HSSI_TDATA_WIDTH-1:0]            dma_gbx_ptpb_axi_st_tx_tdata                 ;
  logic [DMA_CHS-1:0]  [HSSI_TDATA_WIDTH/8-1:0]          dma_gbx_ptpb_axi_st_tx_tkeep                 ;
  logic [DMA_CHS-1:0]                                    dma_gbx_ptpb_axi_st_tx_tlast                 ;
  logic [DMA_CHS-1:0]  [PTP_WIDTH -1:0]                  dma_gbx_ptpb_axi_st_tx_tuser_ptp             ;
  logic [DMA_CHS-1:0]  [PTP_EXT_WIDTH -1:0]              dma_gbx_ptpb_axi_st_tx_tuser_ptp_extended    ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0] [1:0]       dma_gbx_ptpb_axi_st_tx_tuser_client          ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0]             dma_gbx_ptpb_axi_st_tx_tuser_pkt_seg_parity  ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0]             dma_gbx_ptpb_axi_st_tx_tuser_last_segment    ;
  logic [DMA_CHS-1:0]                                   dma_gbx_ptpb_axi_st_tx_tready                ;
  
  logic [DMA_CHS-1:0]                                    dma_gbx_ptpb_axi_st_rx_tvalid                ;
  logic [DMA_CHS-1:0]  [HSSI_TDATA_WIDTH-1:0]            dma_gbx_ptpb_axi_st_rx_tdata                 ;
  logic [DMA_CHS-1:0]  [HSSI_TDATA_WIDTH/8-1:0]          dma_gbx_ptpb_axi_st_rx_tkeep                 ;
  logic [DMA_CHS-1:0]                                    dma_gbx_ptpb_axi_st_rx_tlast                 ;
  logic [DMA_CHS-1:0]  [HSSI_NUM_OF_SEG-1:0] [1:0]       dma_gbx_ptpb_axi_st_rx_tuser_client          ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0] [1:0]       dma_axi_st_rx_tuser_client          ;
  logic [DMA_CHS-1:0]  [HSSI_NUM_OF_SEG-1:0] [4:0]       dma_gbx_ptpb_axi_st_rx_tuser_sts             ;
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0] [4:0]       dma_axi_st_rx_tuser_sts             ;
  
  logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0]             dma_gbx_ptpb_axi_st_rx_tuser_last_segment    ;
  logic [DMA_CHS-1:0]  [HSSI_NUM_OF_SEG-1:0]             dma_gbx_ptpb_axi_st_rx_tuser_last_segment_conv    ;


  logic [NUM_PORTS-1:0]                           hssi_ss_st_tx_tvalid             ;
  logic [NUM_PORTS-1:0]                           hssi_ss_st_tx_tready             ;
  logic [NUM_PORTS-1:0] [HSSI_TDATA_WIDTH-1:0]    hssi_ss_st_tx_tdata              ;
  logic [NUM_PORTS-1:0] [HSSI_TDATA_WIDTH/8-1:0]  hssi_ss_st_tx_tkeep              ;
  logic [NUM_PORTS-1:0]                           hssi_ss_st_tx_tlast              ;
  logic [NUM_PORTS-1:0] [TX_USER_CLIENT_WIDTH-1:0] hssi_ss_st_tx_tuser_client      ;
  logic [NUM_PORTS-1:0] [PTP_WIDTH -1:0]          hssi_ss_st_tx_tuser_ptp          ;
  logic [NUM_PORTS-1:0] [PTP_EXT_WIDTH -1:0]      hssi_ss_st_tx_tuser_ptp_extended ;
  logic [NUM_PORTS-1:0] [HSSI_NUM_OF_SEG-1:0]     hssi_ss_st_tx_tuser_last_segment ;

  logic [NUM_PORTS-1:0]                           hssi_ss_st_rx_tvalid               ;
  logic [NUM_PORTS-1:0] [HSSI_TDATA_WIDTH-1:0]    hssi_ss_st_rx_tdata                ;
  logic [NUM_PORTS-1:0] [HSSI_TDATA_WIDTH/8-1:0]  hssi_ss_st_rx_tkeep                ;
  logic [NUM_PORTS-1:0]                           hssi_ss_st_rx_tlast                ;
  logic [NUM_PORTS-1:0][RX_USER_CLIENT_WIDTH-1:0] hssi_ss_st_rx_tuser_client;
  logic [NUM_PORTS-1:0][RX_USER_STS_WIDTH-1:0]    hssi_ss_st_rx_tuser_sts;
  logic [NUM_PORTS-1:0][PTP_EXT_WIDTH -1:0]       hssi_ss_st_rx_tuser_sts_extended   ;
  logic [NUM_PORTS-1:0][HSSI_NUM_OF_SEG-1:0]      hssi_ss_st_rx_tuser_pkt_seg_parity ;
  logic [NUM_PORTS-1:0][HSSI_NUM_OF_SEG-1:0]      hssi_ss_st_rx_tuser_last_segment   ;
 
  logic [NUM_PORTS-1:0]                            ms_hssi_ss_st_rx_tvalid              ;
  logic [NUM_PORTS-1:0] [HSSI_TDATA_WIDTH-1:0]     ms_hssi_ss_st_rx_tdata               ;
  logic [NUM_PORTS-1:0] [HSSI_TDATA_WIDTH/8-1:0]   ms_hssi_ss_st_rx_tkeep               ;
  logic [NUM_PORTS-1:0]                            ms_hssi_ss_st_rx_tlast               ;
  logic [NUM_PORTS-1:0] [DMA_NUM_OF_SEG-1:0] [6:0] hssi_axi_st_rx_tuser_client_i       ;
  logic [NUM_PORTS-1:0] [DMA_NUM_OF_SEG-1:0] [4:0] hssi_axi_st_rx_tuser_sts_i          ;
  logic [NUM_PORTS-1:0] [27:0]                     ms_hssi_ss_st_rx_tuser_client       ;
  logic [NUM_PORTS-1:0] [19:0]                     ms_hssi_ss_st_rx_tuser_sts          ;

  logic [NUM_PORTS-1:0] [HSSI_NUM_OF_SEG-1:0] [STS_EXT_WIDTH -1:0] ms_hssi_ss_st_rx_tuser_sts_extended;
  logic [NUM_PORTS-1:0] [HSSI_NUM_OF_SEG-1:0]      ms_hssi_ss_st_rx_tuser_pkt_seg_parity ;
  logic [NUM_PORTS-1:0] [HSSI_NUM_OF_SEG-1:0]      ms_hssi_ss_st_rx_tuser_last_segment   ;
  wire [NUM_PORTS-1:0]                             ms_hssi_ptp_rx_ingrts_tvalid;
  wire [NUM_PORTS-1:0] [RXIGR_TS_DW-1:0]           ms_hssi_ptp_rx_ingrts_tdata;
  
  logic [NUM_PORTS-1:0]                      o_clk_pll;
  logic [DMA_CHS-1:0]                        tx_ts_valid;
  logic [DMA_CHS-1:0] [TS_REQ_FP_WIDTH-1:0]  tx_ts_fp;
  logic [DMA_CHS-1:0] [RXIGR_TS_DW-1:0]      tx_ts_data;

  wire        port0_tx_dma_fifo_0_out_ts_req_valid;
  wire [19:0] port0_tx_dma_fifo_0_out_ts_req_fingerprint;
  wire        port1_tx_dma_fifo_0_out_ts_req_valid;
  wire [19:0] port1_tx_dma_fifo_0_out_ts_req_fingerprint;
  wire        port2_tx_dma_fifo_0_out_ts_req_valid;
  wire [19:0] port2_tx_dma_fifo_0_out_ts_req_fingerprint;
  wire        port3_tx_dma_fifo_0_out_ts_req_valid;
  wire [19:0] port3_tx_dma_fifo_0_out_ts_req_fingerprint;
  wire        port4_tx_dma_fifo_0_out_ts_req_valid;
  wire [19:0] port4_tx_dma_fifo_0_out_ts_req_fingerprint;
  wire        port5_tx_dma_fifo_0_out_ts_req_valid;
  wire [19:0] port5_tx_dma_fifo_0_out_ts_req_fingerprint;
  wire        dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
  wire [95:0] dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;
  wire        dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
  wire [95:0] dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;  
  wire        dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
  wire [95:0] dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;  
  wire        dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
  wire [95:0] dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;  
  wire        dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
  wire [95:0] dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;  
  wire        dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
  wire [95:0] dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;  
  wire [NUM_PORTS-1:0] hssi_ptp_tx_tod_tvalid;
  wire [NUM_PORTS-1:0] [95:0] hssi_ptp_tx_tod_tdata;
  wire [NUM_PORTS-1:0] hssi_ptp_rx_tod_tvalid;
  wire [NUM_PORTS-1:0] [95:0] hssi_ptp_rx_tod_tdata;
  
  wire        ninit_done;
  wire        system_reset_n;
  wire [19:0] ftile_debug_status;
  reg  [6:0]  ftile_debug_status_0_reg;
  reg  [6:0]  ftile_debug_status_1_reg;
  wire [6:0]  status_vector_0_sync;
  wire [6:0]  status_vector_1_sync;
  wire [1:0]  hssi_cold_boot_rstackn_sync;
  wire  [(NUM_PORTS*10)-1:0]  status_vector;// {10 status bits for each port}
  reg [1:0]   hssi_cold_boot_reg;
  wire        axi4lite_clk_clk;
  wire        axi4lite_rst_reset_n;
  wire        clk_ptp_sample_clk, clk_ptp_sample_clk_1;

  wire [NUM_PORTS-1:0]                   hssi_ptp_tx_egrts_tvalid;
  wire [NUM_PORTS-1:0] [TXEGR_TS_DW-1:0] hssi_ptp_tx_egrts_tdata;
  wire [DMA_CHS-1:0]                     dma_axi_st_txegrts0_tvalid_o;
  wire [DMA_CHS-1:0]   [TXEGR_TS_DW-1:0] dma_axi_st_txegrts0_tdata_o;
  wire [DMA_CHS-1:0]                     dma_gbx_ptpb_axi_st_txegrts0_tvalid_o;
  wire [DMA_CHS-1:0]   [TXEGR_TS_DW-1:0] dma_gbx_ptpb_axi_st_txegrts0_tdata_o;
  wire [NUM_PORTS-1:0]                   hssi_ptp_rx_ingrts_tvalid ;
  wire [NUM_PORTS-1:0] [RXIGR_TS_DW-1:0] hssi_ptp_rx_ingrts_tdata;
  wire [DMA_CHS-1:0]                     dma_axi_st_rxigrts0_tvalid;
  wire [DMA_CHS-1:0]   [RXIGR_TS_DW-1:0] dma_axi_st_rxigrts0_tdata;
  wire [DMA_CHS-1:0]                     dma_gbx_ptpb_axi_st_rxigrts0_tvalid;
  wire [DMA_CHS-1:0]   [RXIGR_TS_DW-1:0] dma_gbx_ptpb_axi_st_rxigrts0_tdata;
  wire [NUM_PORTS-1:0]                   gbx_hssi_ptp_tx_egrts_tvalid;
  wire [NUM_PORTS-1:0] [TXEGR_TS_DW-1:0] gbx_hssi_ptp_tx_egrts_tdata;
  wire [NUM_PORTS-1:0]                   gbx_hssi_ptp_rx_ingrts_tvalid;
  wire [NUM_PORTS-1:0] [RXIGR_TS_DW-1:0] gbx_hssi_ptp_rx_ingrts_tdata;

  wire        tod_slave_subsys_port_0_tod_stack_tx_pll_locked_lock;
  wire        tod_slave_subsys_port_1_tod_stack_tx_pll_locked_lock;
  wire        tod_slave_subsys_port_2_tod_stack_tx_pll_locked_lock;
  wire        tod_slave_subsys_port_3_tod_stack_tx_pll_locked_lock;
  wire        tod_slave_subsys_port_4_tod_stack_tx_pll_locked_lock;
  wire        tod_slave_subsys_port_5_tod_stack_tx_pll_locked_lock;

  wire  [NUM_PORTS-1:0] hssi_pll_rst;
  logic [NUM_PORTS-1:0] [USER_NUM_OF_SEG-1:0] user_axi_st_tx_tuser_last_segment_i;
  logic [NUM_PORTS-1:0] user_axi_st_tx_tready_o;
  wire  [NUM_PORTS-1:0] ss_app_cold_rst_ack_n, ss_app_warm_rst_ack_n, ss_app_cold_rst_ack_n_sync, ss_app_warm_rst_ack_n_sync;
  reg   [NUM_PORTS-1:0] tcam_cold_rst_n, tcam_warm_rst_n;
  wire  [NUM_PORTS-1:0] ss_app_rst_rdy, app_ss_rst_req, app_ss_st_areset_n;
  wire  [31:0]          f2h_irq1_irq;
  wire                  qsfpdd_0_i2c_scl_oe;
  wire                  qsfpdd_0_i2c_sda_oe;
  wire                  qsfpdd_1_i2c_scl_oe;
  wire                  qsfpdd_1_i2c_sda_oe;
  wire                  qsfpdd_1_i2c_sda_in;
  wire                  qsfpdd_1_i2c_scl_in;
  wire                  zl_i2c_scl_oe;
  wire                  zl_i2c_sda_oe;
  wire  [1:0]           qsfpdd_status_pio;
  wire  [5:0]           qsfpdd_spi_ctrl_pio;
  wire  [1:0]           glitch_free_cmux_sel;
  wire  [1:0]           dr_speed_10g_25g;
  wire                  o_p8_clk_rec_div_clk;
  
  // Traffic generator module instantiation
  wire  [NUM_PORTS-1:0]                              avst_tx_ready_int;
  wire  [NUM_PORTS-1:0]                              avst_tx_valid_int;
  wire  [NUM_PORTS-1:0]                              avst_tx_sop_int;
  wire  [NUM_PORTS-1:0]                              avst_tx_eop_int;
  wire  [NUM_PORTS-1:0] [EMPTY_WIDTH-1:0]            avst_tx_empty_int;
  wire  [NUM_PORTS-1:0] [WORDS*DATA_WIDTH-1:0]       avst_tx_data_int;
  wire  [NUM_PORTS-1:0]                              avst_tx_error_int;
  wire  [NUM_PORTS-1:0]                              avst_tx_skip_crc_int;
  logic [NUM_PORTS-1:0]                              avst_rx_valid_int;
  wire  [NUM_PORTS-1:0] [WORDS*DATA_WIDTH-1:0]       avst_rx_tdata_int;
  wire  [NUM_PORTS-1:0] [EMPTY_WIDTH*WORDS-1:0]      avst_rx_empty_int;
  logic [NUM_PORTS-1:0]                              avst_rx_sop_int;
  logic [NUM_PORTS-1:0]                              avst_rx_eop_int;
  logic [NUM_PORTS-1:0] [3:0]                        trafficgen_system_status;

  logic [NUM_PORTS-1:0] [DMA_NUM_OF_SEG-1:0] [1:0]  axi_st_tx_tuser_client_o          ;
  logic [NUM_PORTS-1:0] [HSSI_NUM_OF_SEG-1:0] [6:0]  axi_st_rx_tuser_client_i          ;
  logic [NUM_PORTS-1:0] [HSSI_NUM_OF_SEG-1:0] [4:0]  axi_st_rx_tuser_sts_i             ;
  
  ofs_fim_hssi_ptp_tx_egrts_if      hssi_ptp_tx_egrts  [NUM_PORTS-1:0]();
  ofs_fim_hssi_ptp_rx_ingrts_if     hssi_ptp_rx_ingrts [NUM_PORTS-1:0]();
  ofs_fim_hssi_ptp_tx_tod_if        hssi_ptp_tx_tod    [NUM_PORTS-1:0]();
  ofs_fim_hssi_ptp_rx_tod_if        hssi_ptp_rx_tod    [NUM_PORTS-1:0]();
  
  ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .WDATA_WIDTH(32), .ARADDR_WIDTH(16), .RDATA_WIDTH(32)) axi4lite_ptpb();
  ofs_fim_axi_lite_if #(.AWADDR_WIDTH(26), .WDATA_WIDTH(32), .ARADDR_WIDTH(26), .RDATA_WIDTH(32)) axi4lite_hssi();
  ofs_fim_axi_lite_if #(.AWADDR_WIDTH(26), .WDATA_WIDTH(32), .ARADDR_WIDTH(26), .RDATA_WIDTH(32)) axi4lite_hssi_1();
  axi4lite_if #(.AWADDR_WIDTH(16), .WDATA_WIDTH(32), .ARADDR_WIDTH(16), .RDATA_WIDTH(32))  axi4lite_pktcli [NUM_PORTS-1:0]();
  ofs_fim_axi_lite_if #(.AWADDR_WIDTH(12), .WDATA_WIDTH(64), .ARADDR_WIDTH(12), .RDATA_WIDTH(64)) axi4lite_qsfp_mem_cntrl();
  axis_if #(.DATA_W(HSSI_TDATA_WIDTH),.USER_W(10),.USER_STS_W(RX_USER_STS_WIDTH),.USER_CLIENT_W(RX_USER_CLIENT_WIDTH), .USER_TS_IGR_W(RXIGR_TS_DW)) axis_rx_if [NUM_PORTS-1:0]();
  axis_if #(.DATA_W(HSSI_TDATA_WIDTH),.USER_W(10),.USER_STS_W(RX_USER_STS_WIDTH),.USER_CLIENT_W(RX_USER_CLIENT_WIDTH), .USER_TS_IGR_W(RXIGR_TS_DW)) axis_tx_if [NUM_PORTS-1:0]();

`ifdef SIM_MODE
   assign system_reset_n = ~ninit_done;
`else
   defparam rd1.CNTR_BITS = 28;//TODO check 16bits
   alt_reset_delay rd1 (.clk(fpga_clk_100), .ready_in(~ninit_done), .ready_out(system_reset_n) );
`endif

  logic hssi_cdr_clk_out_sig;
  assign hssi_cdr_clk_out = hssi_cdr_clk_out_sig;
  //assign hssi_cdr_clk_out[0] = hssi_cdr_clk_out_sig;
  //assign hssi_cdr_clk_out[1] = o_p8_clk_rec_div_clk;
  
  logic p8_tx_rst_n_eth_p0, p8_rx_rst_n_eth_p0, p8_tx_rst_n_eth_p1, p8_rx_rst_n_eth_p1;
  logic [1:0] rst_n_eth_p, rst_n_eth_p_sync, reset_eth_p, reset_eth_p_sync;
   
always @(posedge fpga_clk_100 or negedge system_reset_n)
  if(~system_reset_n) begin
      rst_n_eth_p[0]  <= 1'b0;
      rst_n_eth_p[1]  <= 1'b0;
    end
  else begin
      rst_n_eth_p[0]  <= !reset_eth_p_sync[0];
      rst_n_eth_p[1]  <= !reset_eth_p_sync[0];
  end  
	 

for (genvar i=0; i < NUM_PORTS; i++) begin : rst_eth_port
	   eth_f_altera_std_synchronizer_nocut rst_n_eth_port_100M (
        .clk        (fpga_clk_100),
        .reset_n    (1'b1),
        .din        (reset_eth_p[i]),
        .dout       (reset_eth_p_sync[i])
    );
end
 
	
always @(posedge o_clk_pll[0] or negedge rst_n_eth_p_sync[0])
  if(~rst_n_eth_p_sync[0])
    p8_tx_rst_n_eth_p0 <= 1'b0;
  else
    p8_tx_rst_n_eth_p0 <= 1'b1;
	 
always @(posedge o_clk_pll[0] or negedge rst_n_eth_p_sync[0])
  if(~rst_n_eth_p_sync[0])
    p8_rx_rst_n_eth_p0 <= 1'b0;
  else
    p8_rx_rst_n_eth_p0 <= 1'b1;
	 
always @(posedge o_clk_pll[1] or negedge rst_n_eth_p_sync[1])
  if(~rst_n_eth_p_sync[1])
    p8_tx_rst_n_eth_p1 <= 1'b0;
  else 
    p8_tx_rst_n_eth_p1 <= 1'b1;
	 
always @(posedge o_clk_pll[1] or negedge rst_n_eth_p_sync[1])
  if(~rst_n_eth_p_sync[1])
    p8_rx_rst_n_eth_p1 <= 1'b0;
  else 
    p8_rx_rst_n_eth_p1 <= 1'b1;

for (genvar i=0; i < NUM_PORTS; i++) begin : rst_port
	   eth_f_altera_std_synchronizer_nocut rst_n_eth_port (
        .clk        (o_clk_pll[i]),
        .reset_n    (1'b1),
        .din        (rst_n_eth_p[i]),
        .dout       (rst_n_eth_p_sync[i])
    );
end

// cold boot reset logic
    eth_f_altera_std_synchronizer_nocut cold_boot_rstackn_sync_inst1 (
        .clk        (fpga_clk_100),
        .reset_n    (1'b1),
        .din        (status_vector[0]),
        .dout       (hssi_cold_boot_rstackn_sync[0])
    );

always @(posedge fpga_clk_100 or negedge system_reset_n)
  if(~system_reset_n)
    hssi_cold_boot_reg[0] <= 1'b0;
  else if(~hssi_cold_boot_rstackn_sync[0])
    hssi_cold_boot_reg[0] <= 1'b1;

// cold boot reset logic
    eth_f_altera_std_synchronizer_nocut cold_boot_rstackn_sync_inst2 (
        .clk        (fpga_clk_100),
        .reset_n    (1'b1),
        .din        (status_vector[10]),
        .dout       (hssi_cold_boot_rstackn_sync[1])
    );

always @(posedge fpga_clk_100 or negedge system_reset_n)
  if(~system_reset_n)
    hssi_cold_boot_reg[1] <= 1'b0;
  else if(~hssi_cold_boot_rstackn_sync[1])
    hssi_cold_boot_reg[1] <= 1'b1;

for (genvar nump=0; nump < NUM_PORTS; nump++) begin : GenClkRst
   
   fim_resync #(
    .SYNC_CHAIN_LENGTH  (2),
    .WIDTH              (1),
    .INIT_VALUE         (1),
    .NO_CUT             (0)
   ) st_tx_rst_sync(
    .clk                (o_clk_pll[nump]),
    .reset              (~system_reset_n),
    .d                  (1'b0),
    .q                  (hssi_pll_rst[nump])
);
end

// cold boot reset logic
  eth_f_altera_std_synchronizer_nocut cold_boot_rstack_tcam_inst_1 (
    .clk        (axi4lite_clk_clk),
    .reset_n    (1'b1),
    .din        (ss_app_cold_rst_ack_n[0]),
    .dout       (ss_app_cold_rst_ack_n_sync[0])
  );

// cold boot reset logic
  eth_f_altera_std_synchronizer_nocut cold_boot_rstack_tcam_inst_2 (
    .clk        (axi4lite_clk_clk),
    .reset_n    (1'b1),
    .din        (ss_app_cold_rst_ack_n[1]),
    .dout       (ss_app_cold_rst_ack_n_sync[1])
  );

always @(posedge axi4lite_clk_clk or negedge axi4lite_rst_reset_n) 
  if(~axi4lite_rst_reset_n)
    tcam_cold_rst_n[0] <= 1'b0;
  else if(~ss_app_cold_rst_ack_n_sync[0])
    tcam_cold_rst_n[0] <= 1'b1;

always @(posedge axi4lite_clk_clk or negedge axi4lite_rst_reset_n) 
  if(~axi4lite_rst_reset_n)
    tcam_cold_rst_n[1] <= 1'b0;
  else if(~ss_app_cold_rst_ack_n_sync[1])
    tcam_cold_rst_n[1] <= 1'b1;

// warm boot reset logic
  eth_f_altera_std_synchronizer_nocut warm_boot_rstack_tcam_inst_1 (
    .clk        (axi4lite_clk_clk),	
    .reset_n    (1'b1),
    .din        (ss_app_warm_rst_ack_n[0]),
    .dout       (ss_app_warm_rst_ack_n_sync[0])
  );

// warm boot reset logic
  eth_f_altera_std_synchronizer_nocut warm_boot_rstack_tcam_inst_2 (
    .clk        (axi4lite_clk_clk),	
    .reset_n    (1'b1),
    .din        (ss_app_warm_rst_ack_n[1]),
    .dout       (ss_app_warm_rst_ack_n_sync[1])
  );

always @(posedge axi4lite_clk_clk or negedge axi4lite_rst_reset_n)
  if(~axi4lite_rst_reset_n)
    tcam_warm_rst_n[0] <= 1'b0;
  else if(~ss_app_warm_rst_ack_n_sync[0])
    tcam_warm_rst_n[0] <= 1'b1;

always @(posedge axi4lite_clk_clk or negedge axi4lite_rst_reset_n)
  if(~axi4lite_rst_reset_n)
    tcam_warm_rst_n[1] <= 1'b0;
  else if(~ss_app_warm_rst_ack_n_sync[1])
    tcam_warm_rst_n[1] <= 1'b1;

for (genvar i=0; i < 7; i++) begin : sts_gen_3_9
// Ftile debug status logic
    eth_f_altera_std_synchronizer_nocut ftile_debug_status_3_9 (
        .clk        (fpga_clk_100),
        .reset_n    (1'b1),
        .din        (status_vector[3+i]),
        .dout       (status_vector_0_sync[i])
    );
end

for (genvar j=0; j < 7; j++) begin : sts_gen_10_16
// Ftile debug status logic
    eth_f_altera_std_synchronizer_nocut ftile_debug_status_13_19 (
        .clk        (fpga_clk_100),
        .reset_n    (1'b1),
        .din        (status_vector[13+j]),
        .dout       (status_vector_1_sync[j])
    );
end

always @(posedge fpga_clk_100 or negedge system_reset_n)
  if(~system_reset_n)
    begin
      ftile_debug_status_0_reg <= 7'b0;
      ftile_debug_status_1_reg <= 7'b0;
	end
  else 
    begin
      ftile_debug_status_0_reg <= status_vector_0_sync;
      ftile_debug_status_1_reg <= status_vector_1_sync;
	end

assign ftile_debug_status[6:0]   = ftile_debug_status_0_reg;       
assign ftile_debug_status[16:10] = ftile_debug_status_1_reg;     

assign system_clk_100           = fpga_clk_100;
assign system_clk_100_internal  = system_clk_100;


assign qsfpdd_0_resetn            = qsfpdd_spi_ctrl_pio[0]; //1'b1;
assign qsfpdd_0_initmode          = qsfpdd_spi_ctrl_pio[1]; //1'b1;	//known as LPMode in QSFPDD
assign qsfpdd_0_modseln           = qsfpdd_spi_ctrl_pio[2]; //1'b0;

//assign qsfpdd_1_resetn            = qsfpdd_spi_ctrl_pio[3]; 
//assign qsfpdd_1_initmode          = qsfpdd_spi_ctrl_pio[4]; 
//assign qsfpdd_1_modseln           = qsfpdd_spi_ctrl_pio[5]; 

assign qsfpdd_0_i2c_scl           = qsfpdd_0_i2c_scl_oe ? 1'b0 : 1'bz;
assign qsfpdd_0_i2c_sda           = qsfpdd_0_i2c_sda_oe ? 1'b0 : 1'bz;

assign qsfpdd_1_i2c_scl           = qsfpdd_1_i2c_scl_oe ? 1'b0 : 1'bz;
assign qsfpdd_1_i2c_sda           = qsfpdd_1_i2c_sda_oe ? 1'b0 : 1'bz;
assign qsfpdd_1_i2c_scl_in        = qsfpdd_1_i2c_scl;
assign qsfpdd_1_i2c_sda_in        = qsfpdd_1_i2c_sda;

assign zl_i2c_scl                 = zl_i2c_scl_oe ? 1'b0 : 1'bz;
assign zl_i2c_sda                 = zl_i2c_sda_oe ? 1'b0 : 1'bz;

assign qsfpdd_status_pio = {qsfpdd_0_intn, qsfpdd_0_modprsn};

assign f2h_irq1_irq    = {32'b0};


assign dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[5];
assign dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[4];
assign dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[3];
assign dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[2];
assign dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[1];
assign dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[0];
 
assign dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[5][95:0];
assign dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[4][95:0];
assign dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[3][95:0];
assign dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[2][95:0];
assign dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[1][95:0];
assign dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[0][95:0];


  assign trafficgen_system_status[0] = {status_vector_0_sync[2], status_vector_0_sync[1], status_vector_0_sync[0], system_reset_n};
  assign trafficgen_system_status[1] = {status_vector_1_sync[2], status_vector_1_sync[1], status_vector_1_sync[0], system_reset_n};

for(genvar i = 0; i < DMA_CHS; i++) begin : tx_ts_assign
    always_comb begin
       tx_ts_valid[i] = dma_axi_st_txegrts0_tvalid_o[i];
       tx_ts_fp[i]    = dma_axi_st_txegrts0_tdata_o[i][115:96];
       tx_ts_data[i]  = dma_axi_st_txegrts0_tdata_o[i][95:0];
    end
end

for(genvar i = 0; i < DMA_CHS; i++) begin : last_segment_assign
  assign axi_st_tx_tuser_last_segment_i[i][0]      = axi_st_tx_tlast_i[i];
  assign axi_st_tx_tuser_pkt_seg_parity_i[i]       = 1'b0;
end

for(genvar i = 0; i < NUM_PORTS; i++) begin : user_last_segment_assign
  assign user_axi_st_tx_tuser_last_segment_i[i][0] = user_axi_st_tx_tlast_i[i];
  assign user_axi_st_tx_tuser_pkt_seg_parity_i[i]  = 1'b0;
end

for(genvar i = 0; i < NUM_PORTS; i++) begin : hssi_tlast_segment_assign
   case (HSSI_NUM_OF_SEG)
   'd1: begin
      assign hssi_ss_st_tx_tuser_last_segment[i] = hssi_ss_st_tx_tlast[i];
	end
   'd2: begin
      assign hssi_ss_st_tx_tuser_last_segment[i] = (hssi_ss_st_tx_tlast[i] & hssi_ss_st_tx_tkeep[i][8]) ? 2'b10 : (hssi_ss_st_tx_tlast[i] & hssi_ss_st_tx_tkeep[i][0]) ? 2'b01 : 2'b00;
	end
   'd4: begin
      assign hssi_ss_st_tx_tuser_last_segment[i] = (hssi_ss_st_tx_tlast[i] & hssi_ss_st_tx_tkeep[i][24]) ? 4'b1000 : (hssi_ss_st_tx_tlast[i] & hssi_ss_st_tx_tkeep[i][16]) ? 4'b0100 : (hssi_ss_st_tx_tlast[i] & hssi_ss_st_tx_tkeep[i][8]) ? 4'b0010 : (hssi_ss_st_tx_tlast[i] & hssi_ss_st_tx_tkeep[i][0]) ? 4'b0001 : 4'b0000;
    end
    default: begin
	  assign hssi_ss_st_tx_tuser_last_segment[i] = '0;
	end
	endcase
end

//--------------------------------------------------
//the todclk_ref is used as a core refclk signal for several IOPLLs.  This results in a
// critical warning from Quartus: "Signal ftile_master_todclk_ref has been promoted to use the global 
// clock network, but is placed on a non-dedicated clock pin location. To minimize clock uncertainty, 
//Intel recommends placing all pin clocks on dedicated clock pin locations". In order to be explicit that
//the user intent is to have the signal come from core logic and prevent the warning, the lcell below is inserted
lcell lcell_i
(
    .in         (ftile_master_todclk_ref),
    .out        (ftile_master_todclk_ref_lcell)
);

qsys_top #(
  .FP_WIDTH  (FP_WIDTH)
   ) inst_qsys_top (
      .axi4lite_clk_clk            (axi4lite_clk_clk             ),
      .axi4lite_hssi_awaddr        (axi4lite_hssi.awaddr         ),
      .axi4lite_hssi_awprot        (axi4lite_hssi.awprot         ),
      .axi4lite_hssi_awvalid       (axi4lite_hssi.awvalid        ),
      .axi4lite_hssi_awready       (axi4lite_hssi.awready        ),
      .axi4lite_hssi_wdata         (axi4lite_hssi.wdata          ),
      .axi4lite_hssi_wstrb         (axi4lite_hssi.wstrb          ),
      .axi4lite_hssi_wvalid        (axi4lite_hssi.wvalid         ),
      .axi4lite_hssi_wready        (axi4lite_hssi.wready         ),
      .axi4lite_hssi_bresp         (axi4lite_hssi.bresp          ),
      .axi4lite_hssi_bvalid        (axi4lite_hssi.bvalid         ),
      .axi4lite_hssi_bready        (axi4lite_hssi.bready         ),
      .axi4lite_hssi_araddr        (axi4lite_hssi.araddr         ),
      .axi4lite_hssi_arprot        (axi4lite_hssi.arprot         ),
      .axi4lite_hssi_arvalid       (axi4lite_hssi.arvalid        ),
      .axi4lite_hssi_arready       (axi4lite_hssi.arready        ),
      .axi4lite_hssi_rdata         (axi4lite_hssi.rdata          ),
      .axi4lite_hssi_rresp         (axi4lite_hssi.rresp          ),
      .axi4lite_hssi_rvalid        (axi4lite_hssi.rvalid         ),
      .axi4lite_hssi_rready        (axi4lite_hssi.rready         ),
                
      .axi4lite_hssi_1_awaddr      (axi4lite_hssi_1.awaddr       ),
      .axi4lite_hssi_1_awprot      (axi4lite_hssi_1.awprot       ),
      .axi4lite_hssi_1_awvalid     (axi4lite_hssi_1.awvalid      ),
      .axi4lite_hssi_1_awready     (axi4lite_hssi_1.awready      ),
      .axi4lite_hssi_1_wdata       (axi4lite_hssi_1.wdata        ),
      .axi4lite_hssi_1_wstrb       (axi4lite_hssi_1.wstrb        ),
      .axi4lite_hssi_1_wvalid      (axi4lite_hssi_1.wvalid       ),
      .axi4lite_hssi_1_wready      (axi4lite_hssi_1.wready       ),
      .axi4lite_hssi_1_bresp       (axi4lite_hssi_1.bresp        ),
      .axi4lite_hssi_1_bvalid      (axi4lite_hssi_1.bvalid       ),
      .axi4lite_hssi_1_bready      (axi4lite_hssi_1.bready       ),
      .axi4lite_hssi_1_araddr      (axi4lite_hssi_1.araddr       ),
      .axi4lite_hssi_1_arprot      (axi4lite_hssi_1.arprot       ),
      .axi4lite_hssi_1_arvalid     (axi4lite_hssi_1.arvalid      ),
      .axi4lite_hssi_1_arready     (axi4lite_hssi_1.arready      ),
      .axi4lite_hssi_1_rdata       (axi4lite_hssi_1.rdata        ),
      .axi4lite_hssi_1_rresp       (axi4lite_hssi_1.rresp        ),
      .axi4lite_hssi_1_rvalid      (axi4lite_hssi_1.rvalid       ),
      .axi4lite_hssi_1_rready      (axi4lite_hssi_1.rready       ),
      
      .axi4lite_pktcli_0_awaddr    (axi4lite_pktcli[0].awaddr    ),
      .axi4lite_pktcli_0_awprot    (axi4lite_pktcli[0].awprot    ),
      .axi4lite_pktcli_0_awvalid   (axi4lite_pktcli[0].awvalid   ),
      .axi4lite_pktcli_0_awready   (axi4lite_pktcli[0].awready   ),
      .axi4lite_pktcli_0_wdata     (axi4lite_pktcli[0].wdata     ),
      .axi4lite_pktcli_0_wstrb     (axi4lite_pktcli[0].wstrb     ),
      .axi4lite_pktcli_0_wvalid    (axi4lite_pktcli[0].wvalid    ),
      .axi4lite_pktcli_0_wready    (axi4lite_pktcli[0].wready    ),
      .axi4lite_pktcli_0_bresp     (axi4lite_pktcli[0].bresp     ),
      .axi4lite_pktcli_0_bvalid    (axi4lite_pktcli[0].bvalid    ),
      .axi4lite_pktcli_0_bready    (axi4lite_pktcli[0].bready    ),
      .axi4lite_pktcli_0_araddr    (axi4lite_pktcli[0].araddr    ),
      .axi4lite_pktcli_0_arprot    (axi4lite_pktcli[0].arprot    ),
      .axi4lite_pktcli_0_arvalid   (axi4lite_pktcli[0].arvalid   ),
      .axi4lite_pktcli_0_arready   (axi4lite_pktcli[0].arready   ),
      .axi4lite_pktcli_0_rdata     (axi4lite_pktcli[0].rdata     ),
      .axi4lite_pktcli_0_rresp     (axi4lite_pktcli[0].rresp     ),
      .axi4lite_pktcli_0_rvalid    (axi4lite_pktcli[0].rvalid    ),
      .axi4lite_pktcli_0_rready    (axi4lite_pktcli[0].rready    ),
      .axi4lite_pktcli_1_awaddr    (axi4lite_pktcli[1].awaddr    ),
      .axi4lite_pktcli_1_awprot    (axi4lite_pktcli[1].awprot    ),
      .axi4lite_pktcli_1_awvalid   (axi4lite_pktcli[1].awvalid   ),
      .axi4lite_pktcli_1_awready   (axi4lite_pktcli[1].awready   ),
      .axi4lite_pktcli_1_wdata     (axi4lite_pktcli[1].wdata     ),
      .axi4lite_pktcli_1_wstrb     (axi4lite_pktcli[1].wstrb     ),
      .axi4lite_pktcli_1_wvalid    (axi4lite_pktcli[1].wvalid    ),
      .axi4lite_pktcli_1_wready    (axi4lite_pktcli[1].wready    ),
      .axi4lite_pktcli_1_bresp     (axi4lite_pktcli[1].bresp     ),
      .axi4lite_pktcli_1_bvalid    (axi4lite_pktcli[1].bvalid    ),
      .axi4lite_pktcli_1_bready    (axi4lite_pktcli[1].bready    ),
      .axi4lite_pktcli_1_araddr    (axi4lite_pktcli[1].araddr    ),
      .axi4lite_pktcli_1_arprot    (axi4lite_pktcli[1].arprot    ),
      .axi4lite_pktcli_1_arvalid   (axi4lite_pktcli[1].arvalid   ),
      .axi4lite_pktcli_1_arready   (axi4lite_pktcli[1].arready   ),
      .axi4lite_pktcli_1_rdata     (axi4lite_pktcli[1].rdata     ),
      .axi4lite_pktcli_1_rresp     (axi4lite_pktcli[1].rresp     ),
      .axi4lite_pktcli_1_rvalid    (axi4lite_pktcli[1].rvalid    ),
      .axi4lite_pktcli_1_rready    (axi4lite_pktcli[1].rready    ),
      .axi4lite_ptpb_awaddr        (axi4lite_ptpb.awaddr         ),
      .axi4lite_ptpb_awprot        (axi4lite_ptpb.awprot         ),
      .axi4lite_ptpb_awvalid       (axi4lite_ptpb.awvalid        ),
      .axi4lite_ptpb_awready       (axi4lite_ptpb.awready        ),
      .axi4lite_ptpb_wdata         (axi4lite_ptpb.wdata          ),
      .axi4lite_ptpb_wstrb         (axi4lite_ptpb.wstrb          ),
      .axi4lite_ptpb_wvalid        (axi4lite_ptpb.wvalid         ),
      .axi4lite_ptpb_wready        (axi4lite_ptpb.wready         ),
      .axi4lite_ptpb_bresp         (axi4lite_ptpb.bresp          ),
      .axi4lite_ptpb_bvalid        (axi4lite_ptpb.bvalid         ),
      .axi4lite_ptpb_bready        (axi4lite_ptpb.bready         ),
      .axi4lite_ptpb_araddr        (axi4lite_ptpb.araddr         ),
      .axi4lite_ptpb_arprot        (axi4lite_ptpb.arprot         ),
      .axi4lite_ptpb_arvalid       (axi4lite_ptpb.arvalid        ),
      .axi4lite_ptpb_arready       (axi4lite_ptpb.arready        ),
      .axi4lite_ptpb_rdata         (axi4lite_ptpb.rdata          ),
      .axi4lite_ptpb_rresp         (axi4lite_ptpb.rresp          ),
      .axi4lite_ptpb_rvalid        (axi4lite_ptpb.rvalid         ),
      .axi4lite_ptpb_rready        (axi4lite_ptpb.rready         ),
      .axi4lite_rst_reset_n        (axi4lite_rst_reset_n         ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_valid                      (port0_tx_dma_fifo_0_out_ts_req_valid),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port0_tx_dma_fifo_0_out_ts_req_fingerprint),

      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[0][0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port0_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[0]),
      .dma_subsys_dma_subsys_port0_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[0],tx_ts_data[0]}),
      .dma_subsys_dma_subsys_port0_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[0]),
      .dma_subsys_dma_subsys_port0_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[0]),
      .dma_subsys_dma_subsys_port0_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port0_tx_dma_fifo_0_out_ts_req_valid), 
      .dma_subsys_dma_subsys_port0_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port0_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ), 
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0), 
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0), 
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0), 
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0), 
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_valid                      (port1_tx_dma_fifo_0_out_ts_req_valid),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port1_tx_dma_fifo_0_out_ts_req_fingerprint),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[1][0]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port1_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[1]),
      .dma_subsys_dma_subsys_port1_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[1],tx_ts_data[1]}),
      .dma_subsys_dma_subsys_port1_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[0]),
      .dma_subsys_dma_subsys_port1_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[0]),
      .dma_subsys_dma_subsys_port1_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port1_tx_dma_fifo_0_out_ts_req_valid),
      .dma_subsys_dma_subsys_port1_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port1_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ), 
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0), 
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0), 
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0), 
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0), 
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_valid                      (port2_tx_dma_fifo_0_out_ts_req_valid),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port2_tx_dma_fifo_0_out_ts_req_fingerprint),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[2][0]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port2_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[2]),
      .dma_subsys_dma_subsys_port2_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[2],tx_ts_data[2]}),
      .dma_subsys_dma_subsys_port2_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[0]),
      .dma_subsys_dma_subsys_port2_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[0]),
      .dma_subsys_dma_subsys_port2_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port2_tx_dma_fifo_0_out_ts_req_valid), 
      .dma_subsys_dma_subsys_port2_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port2_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ), 
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0), 
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0), 
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0), 
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0), 
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_valid                      (port3_tx_dma_fifo_0_out_ts_req_valid),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port3_tx_dma_fifo_0_out_ts_req_fingerprint),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[3][0]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port3_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[3]),
      .dma_subsys_dma_subsys_port3_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[3],tx_ts_data[3]}),
      .dma_subsys_dma_subsys_port3_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[1]),
      .dma_subsys_dma_subsys_port3_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[1]),
      .dma_subsys_dma_subsys_port3_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port3_tx_dma_fifo_0_out_ts_req_valid),
      .dma_subsys_dma_subsys_port3_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port3_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0), 
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0), 
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0), 
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0), 
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_valid                      (port4_tx_dma_fifo_0_out_ts_req_valid),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port4_tx_dma_fifo_0_out_ts_req_fingerprint),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[4][0]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port4_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[4]),
      .dma_subsys_dma_subsys_port4_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[4],tx_ts_data[4]}),
      .dma_subsys_dma_subsys_port4_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[1]),
      .dma_subsys_dma_subsys_port4_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[1]),
      .dma_subsys_dma_subsys_port4_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port4_tx_dma_fifo_0_out_ts_req_valid), 
      .dma_subsys_dma_subsys_port4_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port4_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ), 
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0), 
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0), 
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0), 
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0), 
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_valid                      (port5_tx_dma_fifo_0_out_ts_req_valid),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port5_tx_dma_fifo_0_out_ts_req_fingerprint),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[5][0]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port5_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[5]),
      .dma_subsys_dma_subsys_port5_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[5],tx_ts_data[5]}),
      .dma_subsys_dma_subsys_port5_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[1]),
      .dma_subsys_dma_subsys_port5_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[1]),
      .dma_subsys_dma_subsys_port5_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port5_tx_dma_fifo_0_out_ts_req_valid),
      .dma_subsys_dma_subsys_port5_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port5_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .hps_sub_sys_agilex_hps_uart1_cts_n                                                     (1'b0),
      .hps_sub_sys_agilex_hps_uart1_dcd_n                                                     (1'b0),
      .hps_sub_sys_agilex_hps_uart1_dsr_n                                                     (1'b0),
      .hps_sub_sys_agilex_hps_uart1_dtr_n                                                     (),
      .hps_sub_sys_agilex_hps_uart1_out1_n                                                    (),
      .hps_sub_sys_agilex_hps_uart1_out2_n                                                    (),
      .hps_sub_sys_agilex_hps_uart1_ri_n                                                      (1'b1),
      .hps_sub_sys_agilex_hps_uart1_rts_n                                                     (),
      .hps_sub_sys_agilex_hps_uart1_rx                                                        (uart1_RX),
      .hps_sub_sys_agilex_hps_uart1_tx                                                        (uart1_TX),
      
      .qsfpdd_i2c_scl_in_clk                                                                  (qsfpdd_0_i2c_scl),
      .qsfpdd_i2c_clk_clk                                                                     (qsfpdd_0_i2c_scl_oe),
      .qsfpdd_i2c_sda_i                                                                       (qsfpdd_0_i2c_sda),
      .qsfpdd_i2c_sda_oe                                                                      (qsfpdd_0_i2c_sda_oe),
      .axi4lite_qsfp_mem_cntrl_m0_awaddr                                                      (axi4lite_qsfp_mem_cntrl.awaddr),
      .axi4lite_qsfp_mem_cntrl_m0_awprot                                                      (axi4lite_qsfp_mem_cntrl.awprot),
      .axi4lite_qsfp_mem_cntrl_m0_awvalid                                                     (axi4lite_qsfp_mem_cntrl.awvalid),
      .axi4lite_qsfp_mem_cntrl_m0_awready                                                     (axi4lite_qsfp_mem_cntrl.awready),
      .axi4lite_qsfp_mem_cntrl_m0_wdata                                                       (axi4lite_qsfp_mem_cntrl.wdata),
      .axi4lite_qsfp_mem_cntrl_m0_wstrb                                                       (axi4lite_qsfp_mem_cntrl.wstrb),
      .axi4lite_qsfp_mem_cntrl_m0_wvalid                                                      (axi4lite_qsfp_mem_cntrl.wvalid),
      .axi4lite_qsfp_mem_cntrl_m0_wready                                                      (axi4lite_qsfp_mem_cntrl.wready),
      .axi4lite_qsfp_mem_cntrl_m0_bresp                                                       (axi4lite_qsfp_mem_cntrl.bresp),
      .axi4lite_qsfp_mem_cntrl_m0_bvalid                                                      (axi4lite_qsfp_mem_cntrl.bvalid),
      .axi4lite_qsfp_mem_cntrl_m0_bready                                                      (axi4lite_qsfp_mem_cntrl.bready),
      .axi4lite_qsfp_mem_cntrl_m0_araddr                                                      (axi4lite_qsfp_mem_cntrl.araddr),
      .axi4lite_qsfp_mem_cntrl_m0_arprot                                                      (axi4lite_qsfp_mem_cntrl.arprot),
      .axi4lite_qsfp_mem_cntrl_m0_arvalid                                                     (axi4lite_qsfp_mem_cntrl.arvalid),
      .axi4lite_qsfp_mem_cntrl_m0_arready                                                     (axi4lite_qsfp_mem_cntrl.arready),
      .axi4lite_qsfp_mem_cntrl_m0_rdata                                                       (axi4lite_qsfp_mem_cntrl.rdata),
      .axi4lite_qsfp_mem_cntrl_m0_rresp                                                       (axi4lite_qsfp_mem_cntrl.rresp),
      .axi4lite_qsfp_mem_cntrl_m0_rvalid                                                      (axi4lite_qsfp_mem_cntrl.rvalid),
      .axi4lite_qsfp_mem_cntrl_m0_rready                                                      (axi4lite_qsfp_mem_cntrl.rready),

      .hps_sub_sys_agilex_hps_i2c1_scl_in_clk                                                 (zl_i2c_scl),
      .hps_sub_sys_agilex_hps_i2c1_clk_clk                                                    (zl_i2c_scl_oe),
      .hps_sub_sys_agilex_hps_i2c1_sda_i                                                      (zl_i2c_sda),
      .hps_sub_sys_agilex_hps_i2c1_sda_oe                                                     (zl_i2c_sda_oe),
      .hps_io_EMAC0_TX_CLK                                                                    (hps_emac0_TX_CLK),
      .hps_io_EMAC0_RX_CLK                                                                    (hps_emac0_RX_CLK),
      .hps_io_EMAC0_TX_CTL                                                                    (hps_emac0_TX_CTL),
      .hps_io_EMAC0_RX_CTL                                                                    (hps_emac0_RX_CTL),
      .hps_io_EMAC0_TXD0                                                                      (hps_emac0_TXD0),
      .hps_io_EMAC0_TXD1                                                                      (hps_emac0_TXD1),
      .hps_io_EMAC0_RXD0                                                                      (hps_emac0_RXD0),
      .hps_io_EMAC0_RXD1                                                                      (hps_emac0_RXD1),
      .hps_io_EMAC0_TXD2                                                                      (hps_emac0_TXD2),
      .hps_io_EMAC0_TXD3                                                                      (hps_emac0_TXD3),
      .hps_io_EMAC0_RXD2                                                                      (hps_emac0_RXD2),
      .hps_io_EMAC0_RXD3                                                                      (hps_emac0_RXD3),
      .hps_io_EMAC0_MDIO                                                                      (hps_emac0_MDIO),
      .hps_io_EMAC0_MDC                                                                       (hps_emac0_MDC), 
      .hps_io_SDMMC_CCLK                                                                      (hps_sdmmc_CCLK),
      .hps_io_SDMMC_CMD                                                                       (hps_sdmmc_CMD), 
      .hps_io_SDMMC_D0                                                                        (hps_sdmmc_D0),
      .hps_io_SDMMC_D1                                                                        (hps_sdmmc_D1),
      .hps_io_SDMMC_D2                                                                        (hps_sdmmc_D2),
      .hps_io_SDMMC_D3                                                                        (hps_sdmmc_D3),
      .hps_io_USB0_CLK                                                                        (hps_usb0_CLK),
      .hps_io_USB0_STP                                                                        (hps_usb0_STP),
      .hps_io_USB0_DIR                                                                        (hps_usb0_DIR),
      .hps_io_USB0_NXT                                                                        (hps_usb0_NXT),
      .hps_io_USB0_DATA0                                                                      (hps_usb0_DATA0),
      .hps_io_USB0_DATA1                                                                      (hps_usb0_DATA1),
      .hps_io_USB0_DATA2                                                                      (hps_usb0_DATA2),
      .hps_io_USB0_DATA3                                                                      (hps_usb0_DATA3),
      .hps_io_USB0_DATA4                                                                      (hps_usb0_DATA4),
      .hps_io_USB0_DATA5                                                                      (hps_usb0_DATA5),
      .hps_io_USB0_DATA6                                                                      (hps_usb0_DATA6), 
      .hps_io_USB0_DATA7                                                                      (hps_usb0_DATA7),

      .hps_io_UART0_RX                                                                        (hps_uart0_RX),
      .hps_io_UART0_TX                                                                        (hps_uart0_TX),
      .hps_io_jtag_tck                                                                        (hps_jtag_tck),
      .hps_io_jtag_tms                                                                        (hps_jtag_tms),
      .hps_io_jtag_tdo                                                                        (hps_jtag_tdo),
      .hps_io_jtag_tdi                                                                        (hps_jtag_tdi),
      .hps_io_gpio1_io0                                                                       (hps_gpio1_io0),
      .hps_io_gpio1_io1                                                                       (hps_gpio1_io1),
      .hps_io_gpio1_io4                                                                       (hps_gpio1_io4),
      .hps_io_gpio1_io5                                                                       (hps_gpio1_io5),
      .hps_io_gpio1_io6                                                                       (hps_gpio1_io6),
      .hps_io_gpio1_io7                                                                       (hps_gpio1_io7),
      .hps_io_gpio1_io19                                                                      (hps_gpio1_io19),
      .hps_io_gpio1_io20                                                                      (hps_gpio1_io20),
      .hps_io_gpio1_io21                                                                      (hps_gpio1_io21),
      
      .emif_hps_mem_mem_ck                                                                    (emif_hps_mem_mem_ck),
      .emif_hps_mem_mem_ck_n                                                                  (emif_hps_mem_mem_ck_n),
      .emif_hps_mem_mem_a                                                                     (emif_hps_mem_mem_a),
      .emif_hps_mem_mem_act_n                                                                 (emif_hps_mem_mem_act_n),
      .emif_hps_mem_mem_ba                                                                    (emif_hps_mem_mem_ba),
      .emif_hps_mem_mem_bg                                                                    (emif_hps_mem_mem_bg),
      .emif_hps_mem_mem_cke                                                                   (emif_hps_mem_mem_cke),
      .emif_hps_mem_mem_cs_n                                                                  (emif_hps_mem_mem_cs_n),
      .emif_hps_mem_mem_odt                                                                   (emif_hps_mem_mem_odt),
      .emif_hps_mem_mem_reset_n                                                               (emif_hps_mem_mem_reset_n),
      .emif_hps_mem_mem_par                                                                   (emif_hps_mem_mem_par),
      .emif_hps_mem_mem_alert_n                                                               (emif_hps_mem_mem_alert_n),
      .emif_hps_mem_mem_dqs                                                                   (emif_hps_mem_mem_dqs),
      .emif_hps_mem_mem_dqs_n                                                                 (emif_hps_mem_mem_dqs_n),
      .emif_hps_mem_mem_dq                                                                    (emif_hps_mem_mem_dq),
      .emif_hps_mem_mem_dbi_n                                                                 (emif_hps_mem_mem_dbi_n),
      .emif_hps_oct_oct_rzqin                                                                 (emif_hps_oct_oct_rzqin),
      
      .clk_ptp_sample_clk                                                                     (clk_ptp_sample_clk),
      .clk_ptp_sample_1_clk                                                                   (clk_ptp_sample_clk_1),

      .o_p0_clk_tx_div_clk                                                                    (o_p8_clk_tx_div_clk),
      .o_p0_clk_rec_div_clk                                                                   (o_p8_clk_rec_div_clk),
      .o_p1_clk_tx_div_clk                                                                    (o_p9_clk_tx_div_clk),
      .o_p1_clk_rec_div_clk                                                                   (o_p9_clk_rec_div_clk),
      .o_p0_clk_pll_clk                                                                       (o_clk_pll[0]),
      .o_p1_clk_pll_clk                                                                       (o_clk_pll[0]),
      .o_p2_clk_pll_clk                                                                       (o_clk_pll[0]),
      .o_p3_clk_pll_clk                                                                       (o_clk_pll[1]),
      .o_p4_clk_pll_clk                                                                       (o_clk_pll[1]),
      .o_p5_clk_pll_clk                                                                       (o_clk_pll[1]),
      .pio_subsystem_0_pio_subsystem_status_export                                            (qsfpdd_status_pio),
      .pio_subsystem_0_sys_ctrl_pio_export                                                    (qsfpdd_spi_ctrl_pio),
		.pio_subsystem_0_eth_speed_pio_p0_export                                                (dr_speed_10g_25g[0]),
		.pio_subsystem_0_eth_speed_pio_p1_export                                                (dr_speed_10g_25g[1]),
      .clk_100_clk                                                                            (fpga_clk_100),
      .dma_subsys_port0_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .dma_subsys_port1_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .dma_subsys_port2_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .dma_subsys_port3_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .dma_subsys_port4_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .dma_subsys_port5_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .ninit_done_ninit_done                                                                  (ninit_done),
      .f2h_irq1_irq                                                                           (f2h_irq1_irq),
      .hps_io_hps_osc_clk                                                                     (hps_ref_clk),
      .agilex_hps_h2f_reset_reset                                                             (           ),
      .reset_reset_n                                                                          (system_reset_n),
      .emif_hps_pll_ref_clk_clk                                                               (emif_hps_pll_ref_clk),
      .mtod_subsys_master_tod_top_0_i_upstr_pll_lock                                          ('b1),
      .qsys_top_master_todclk_0_in_clk_clk                                                    (ftile_master_todclk_ref_lcell),
      .master_tod_top_0_pulse_per_second_pps                                                  (master_tod_top_0_pulse_per_second),
      .mtod_subsys_pps_in_pulse_per_second                                                    (ref_pps_in),
      
      .tod_slave_subsys_port_0_tod_stack_tx_pll_locked_lock                                   (status_vector[4]), 
      .tod_slave_subsys_port_0_tod_stack_tx_tod_interface_tvalid                              (hssi_ptp_tx_tod_tvalid[0]),
      .tod_slave_subsys_port_0_tod_stack_tx_tod_interface_tdata                               (hssi_ptp_tx_tod_tdata[0]),
      .tod_slave_subsys_port_0_tod_stack_rx_tod_interface_tvalid                              (hssi_ptp_rx_tod_tvalid[0]),
      .tod_slave_subsys_port_0_tod_stack_rx_tod_interface_tdata                               (hssi_ptp_rx_tod_tdata[0]),   
//      `ifdef FTILE_PTP_HSSI_10G
//      .tod_slave_subsys_port_0_tod_stack_todsync_sel_todsync_sel                              (1'b1),
//      `elsif FTILE_PTP_HSSI_10G_ANLT
//      .tod_slave_subsys_port_0_tod_stack_todsync_sel_todsync_sel                              (1'b1),
//      `else
//      .tod_slave_subsys_port_0_tod_stack_todsync_sel_todsync_sel                              (1'b0),
//      `endif
      .tod_slave_subsys_port_0_tod_stack_todsync_sel_todsync_sel                              (dr_speed_10g_25g[0]),
      
      .tod_slave_subsys_port_1_tod_stack_tx_pll_locked_lock                                   (status_vector[14]), 
      .tod_slave_subsys_port_1_tod_stack_tx_tod_interface_tvalid                              (hssi_ptp_tx_tod_tvalid[1]),
      .tod_slave_subsys_port_1_tod_stack_tx_tod_interface_tdata                               (hssi_ptp_tx_tod_tdata[1]),
      .tod_slave_subsys_port_1_tod_stack_rx_tod_interface_tvalid                              (hssi_ptp_rx_tod_tvalid[1]),
      .tod_slave_subsys_port_1_tod_stack_rx_tod_interface_tdata                               (hssi_ptp_rx_tod_tdata[1]), 
//     `ifdef FTILE_PTP_HSSI_10G 
//       .tod_slave_subsys_port_1_tod_stack_todsync_sel_todsync_sel                              (1'b1),
//     `elsif FTILE_PTP_HSSI_10G_ANLT 
//       .tod_slave_subsys_port_1_tod_stack_todsync_sel_todsync_sel                              (1'b1),
//     `else                                                                                   
//       .tod_slave_subsys_port_1_tod_stack_todsync_sel_todsync_sel                              (1'b0),
//     `endif
      .tod_slave_subsys_port_1_tod_stack_todsync_sel_todsync_sel                              (dr_speed_10g_25g[1]),
      
      .pio_subsystem_0_ftile_debug_status_pio_export                                          (ftile_debug_status),
      .dma_subsys_ninit_done_reset                                                            (ninit_done),
      .wd_reset_reset_n                                                                       (),
		.pio_subsystem_0_eth_reset_pio_p0_export                                                (reset_eth_p[0]),
		.pio_subsystem_0_eth_reset_pio_p1_export                                                (reset_eth_p[1]),
		.tod_slave_subsys_tod_subsys_rst_100_p0_in_reset_reset_n                                (rst_n_eth_p[0]),
		.tod_slave_subsys_tod_subsys_rst_100_p1_in_reset_reset_n                                (rst_n_eth_p[1]),
		.tod_slave_subsys_port_0_tod_stack_rx_pcs_ready_beginbursttransfer                      (status_vector[5]),
		.tod_slave_subsys_port_1_tod_stack_rx_pcs_ready_beginbursttransfer                      (status_vector[15])
);

// QSFP mem controller
qsfp_top inst_qsfp_top  (

   .clk                     (axi4lite_clk_clk),
   .reset                   (!axi4lite_rst_reset_n),
   .modprsl                 (qsfpdd_1_modprsn),
   .int_qsfp                (!qsfpdd_1_intn),
   .i2c_0_i2c_serial_sda_in (qsfpdd_1_i2c_sda_in),
   .i2c_0_i2c_serial_scl_in (qsfpdd_1_i2c_scl_in),
   .i2c_0_i2c_serial_sda_oe (qsfpdd_1_i2c_sda_oe),
   .i2c_0_i2c_serial_scl_oe (qsfpdd_1_i2c_scl_oe),
   .modesel                 (qsfp_mem_modsel),
   .lpmode                  (qsfpdd_1_initmode),
   .softresetqsfpm          (qsfp_mem_rst),
   .csr_lite_if             (axi4lite_qsfp_mem_cntrl)
);


generate for(genvar i=0;i<DMA_CHS>>1;i++) begin : gen_dma_gbx_ptpb_inst_1

  ptp_gbx_top
    #(
    .ETHERNET_RATE     (ETHERNET_RATE ), // supports 10/25/50/100/200/400   
    .DMA_TDATA_WIDTH   (DMA_TDATA_WIDTH), // supports only 64b
    .HSSI_TDATA_WIDTH  (HSSI_TDATA_WIDTH),  // supports 64/128/256/512/1024
    .DMA_NUM_OF_SEG    (DMA_NUM_OF_SEG), // supports only 1
    .DMA_NUM_OF_SOP    (DMA_NUM_OF_SOP), // supports only 1 	
    .HSSI_NUM_OF_SEG   (HSSI_NUM_OF_SEG),  // supports 1/2/4/8/16
    .HSSI_NUM_OF_SOP   (HSSI_NUM_OF_SOP), // supports only 1
    .TXEGR_TS_DW       (TXEGR_TS_DW),
    .RXIGR_TS_DW       (RXIGR_TS_DW),
    .PTP_WIDTH         (PTP_WIDTH),
    .PTP_EXT_WIDTH     (PTP_EXT_WIDTH)
    )
    inst_dma_gbx_ptpb_1
   ( 
    .tx_clk_i                          (o_clk_pll[0]),                                          
    .rx_clk_i                          (o_clk_pll[0]),                                          
    .tx_areset_n_i                     (system_reset_n),                                     
    .rx_areset_n_i                     (system_reset_n),                                     

    //=========================================================================================
    // TX Interface:  Inputs from DMA
    //-----------------------------------------------------------------------------------------
    // tx ingress interface
    .axi_st_tx_tvalid_i                (axi_st_tx_tvalid_i               [i]),   
    .axi_st_tx_tdata_i                 (axi_st_tx_tdata_i                [i]),   
    .axi_st_tx_tkeep_i                 (axi_st_tx_tkeep_i                [i]),   
    .axi_st_tx_tlast_i                 (axi_st_tx_tlast_i                [i]),   
    .axi_st_tx_tuser_ptp_i             (axi_st_tx_tuser_ptp_i            [i]),   
    .axi_st_tx_tuser_ptp_extended_i    (axi_st_tx_tuser_ptp_extended_i   [i]),   
    .axi_st_tx_tuser_client_i          (axi_st_tx_tuser_client_i         [i]),   
    .axi_st_tx_tuser_pkt_seg_parity_i  (axi_st_tx_tuser_pkt_seg_parity_i [i]),   
    .axi_st_tx_tuser_last_segment_i    (axi_st_tx_tuser_last_segment_i   [i]),   
    .axi_st_tx_tready_o                (axi_st_tx_tready_o               [i]),   

    //-----------------------------------------------------------------------------------------
    // tx egress interface: Outputs to PTP bridge                                                      
    .axi_st_tx_tvalid_o                (dma_gbx_ptpb_axi_st_tx_tvalid            [i]),                                
    .axi_st_tx_tdata_o                 (dma_gbx_ptpb_axi_st_tx_tdata             [i]),                                 
    .axi_st_tx_tkeep_o                 (dma_gbx_ptpb_axi_st_tx_tkeep             [i]),                                 
    .axi_st_tx_tlast_o                 (dma_gbx_ptpb_axi_st_tx_tlast             [i]),                                 
    .axi_st_tx_tuser_ptp_o             (dma_gbx_ptpb_axi_st_tx_tuser_ptp         [i]),                             
    .axi_st_tx_tuser_ptp_extended_o    (dma_gbx_ptpb_axi_st_tx_tuser_ptp_extended[i]),                    
    .axi_st_tx_tuser_client_o          (dma_gbx_ptpb_axi_st_tx_tuser_client      [i]),                   
    .axi_st_tx_tuser_pkt_seg_parity_o  (dma_gbx_ptpb_axi_st_tx_tuser_pkt_seg_parity[i]),                                                       
    .axi_st_tx_tuser_last_segment_o    (dma_gbx_ptpb_axi_st_tx_tuser_last_segment[i]),                    
    .axi_st_tx_tready_i                (dma_gbx_ptpb_axi_st_tx_tready            [i]),                                

    //=========================================================================================
    // RX Interface
    //-----------------------------------------------------------------------------------------
    // rx ingress interface:  Inputs from PTP bridge

    .axi_st_rx_tvalid_i                (dma_gbx_ptpb_axi_st_rx_tvalid              [i]),        
    .axi_st_rx_tdata_i                 (dma_gbx_ptpb_axi_st_rx_tdata               [i]),         
    .axi_st_rx_tkeep_i                 (dma_gbx_ptpb_axi_st_rx_tkeep               [i]),         
    .axi_st_rx_tlast_i                 (dma_gbx_ptpb_axi_st_rx_tlast               [i]),         
    .axi_st_rx_tuser_client_i          (dma_gbx_ptpb_axi_st_rx_tuser_client        [i]),    
    .axi_st_rx_tuser_sts_i             (dma_gbx_ptpb_axi_st_rx_tuser_sts           [i]),       
    .axi_st_rx_tuser_sts_extended_i    ('{default:0}),                   
    .axi_st_rx_tuser_pkt_seg_parity_i  ('0),                             
    .axi_st_rx_tuser_last_segment_i    (dma_gbx_ptpb_axi_st_rx_tuser_last_segment_conv  [i]), 
    .axi_st_rx_tready_o                (),                                    

    //-----------------------------------------------------------------------------------------
    // rx egress interface: outputs to DMA
    .axi_st_rx_tvalid_o                (axi_st_rx_tvalid_o               [i]),  
    .axi_st_rx_tdata_o                 (axi_st_rx_tdata_o                [i]),  
    .axi_st_rx_tkeep_o                 (axi_st_rx_tkeep_o                [i]),  
    .axi_st_rx_tlast_o                 (axi_st_rx_tlast_o                [i]),  
    .axi_st_rx_tuser_client_o          (axi_st_rx_tuser_client_o         [i]),  
    .axi_st_rx_tuser_sts_o             (axi_st_rx_tuser_sts_o            [i]),  
    .axi_st_rx_tuser_sts_extended_o    (                                    ),  
    .axi_st_rx_tuser_pkt_seg_parity_o  (                                    ),  
    .axi_st_rx_tuser_last_segment_o    (                                    ),  
    .axi_st_rx_tready_i                (6'h3F)                                      ,  

    // tx egress timestamp from PTP Bridge interface

    .axi_st_txegrts0_tvalid_i (dma_gbx_ptpb_axi_st_txegrts0_tvalid_o[i]),           
    .axi_st_txegrts0_tdata_i  (dma_gbx_ptpb_axi_st_txegrts0_tdata_o[i]),            
    .axi_st_txegrts1_tvalid_i (),                                      
    .axi_st_txegrts1_tdata_i  (),                                      

    // tx egress timestamp to DMA interface                     
    .axi_st_txegrts0_tvalid_o  (dma_axi_st_txegrts0_tvalid_o[i]),      
    .axi_st_txegrts0_tdata_o   (dma_axi_st_txegrts0_tdata_o [i]),      
    .axi_st_txegrts1_tvalid_o  (),                                     
    .axi_st_txegrts1_tdata_o   (),                                     

    //-----------------------------------------------------------------------------------------
    // rx ingress timestamp from PTP bridge interface
    
    .axi_st_rxegrts0_tvalid_i (dma_gbx_ptpb_axi_st_rxigrts0_tvalid[i]),        
    .axi_st_rxegrts0_tdata_i  (dma_gbx_ptpb_axi_st_rxigrts0_tdata[i]),         
    .axi_st_rxegrts1_tvalid_i (),                                    
    .axi_st_rxegrts1_tdata_i  (),                                    

    // tx ingress timestamp to DMA interface                  
    .axi_st_rxegrts0_tvalid_o  (dma_axi_st_rxigrts0_tvalid[i]),   
    .axi_st_rxegrts0_tdata_o   (dma_axi_st_rxigrts0_tdata [i]),   
    .axi_st_rxegrts1_tvalid_o  (),                                   
    .axi_st_rxegrts1_tdata_o   ()                                    
     );                                                              
end endgenerate


generate for(genvar i=DMA_CHS>>1;i<DMA_CHS;i++) begin : gen_dma_gbx_ptpb_inst_2

  ptp_gbx_top
    #(
    .ETHERNET_RATE     (ETHERNET_RATE ), // supports 10/25/50/100/200/400   
    .DMA_TDATA_WIDTH   (DMA_TDATA_WIDTH), // supports only 64b
    .HSSI_TDATA_WIDTH  (HSSI_TDATA_WIDTH),  // supports 64/128/256/512/1024
    .DMA_NUM_OF_SEG    (DMA_NUM_OF_SEG), // supports only 1
    .DMA_NUM_OF_SOP    (DMA_NUM_OF_SOP), // supports only 1 	
    .HSSI_NUM_OF_SEG   (HSSI_NUM_OF_SEG),  // supports 1/2/4/8/16
    .HSSI_NUM_OF_SOP   (HSSI_NUM_OF_SOP), // supports only 1
    .TXEGR_TS_DW       (TXEGR_TS_DW),
    .RXIGR_TS_DW       (RXIGR_TS_DW),
    .PTP_WIDTH         (PTP_WIDTH),
    .PTP_EXT_WIDTH     (PTP_EXT_WIDTH)
    )
    inst_dma_gbx_ptpb_2
   ( 
    .tx_clk_i                          (o_clk_pll[1]),                                          
    .rx_clk_i                          (o_clk_pll[1]),                                          
    .tx_areset_n_i                     (system_reset_n),                                     
    .rx_areset_n_i                     (system_reset_n),                                     

    //=========================================================================================
    // TX Interface:  Inputs from DMA
    //-----------------------------------------------------------------------------------------
    // tx ingress interface
    .axi_st_tx_tvalid_i                (axi_st_tx_tvalid_i               [i]),   
    .axi_st_tx_tdata_i                 (axi_st_tx_tdata_i                [i]),   
    .axi_st_tx_tkeep_i                 (axi_st_tx_tkeep_i                [i]),   
    .axi_st_tx_tlast_i                 (axi_st_tx_tlast_i                [i]),   
    .axi_st_tx_tuser_ptp_i             (axi_st_tx_tuser_ptp_i            [i]),   
    .axi_st_tx_tuser_ptp_extended_i    (axi_st_tx_tuser_ptp_extended_i   [i]),   
    .axi_st_tx_tuser_client_i          (axi_st_tx_tuser_client_i         [i]),   
    .axi_st_tx_tuser_pkt_seg_parity_i  (axi_st_tx_tuser_pkt_seg_parity_i [i]),   
    .axi_st_tx_tuser_last_segment_i    (axi_st_tx_tuser_last_segment_i   [i]),   
    .axi_st_tx_tready_o                (axi_st_tx_tready_o               [i]),   

    //-----------------------------------------------------------------------------------------
    // tx egress interface: Outputs to PTP bridge                                                      
    .axi_st_tx_tvalid_o                (dma_gbx_ptpb_axi_st_tx_tvalid            [i]),                                
    .axi_st_tx_tdata_o                 (dma_gbx_ptpb_axi_st_tx_tdata             [i]),                                 
    .axi_st_tx_tkeep_o                 (dma_gbx_ptpb_axi_st_tx_tkeep             [i]),                                 
    .axi_st_tx_tlast_o                 (dma_gbx_ptpb_axi_st_tx_tlast             [i]),                                 
    .axi_st_tx_tuser_ptp_o             (dma_gbx_ptpb_axi_st_tx_tuser_ptp         [i]),                             
    .axi_st_tx_tuser_ptp_extended_o    (dma_gbx_ptpb_axi_st_tx_tuser_ptp_extended[i]),                    
    .axi_st_tx_tuser_client_o          (dma_gbx_ptpb_axi_st_tx_tuser_client      [i]),                   
    .axi_st_tx_tuser_pkt_seg_parity_o  (dma_gbx_ptpb_axi_st_tx_tuser_pkt_seg_parity[i]),                                                       
    .axi_st_tx_tuser_last_segment_o    (dma_gbx_ptpb_axi_st_tx_tuser_last_segment[i]),                    
    .axi_st_tx_tready_i                (dma_gbx_ptpb_axi_st_tx_tready            [i]),                                

    //=========================================================================================
    // RX Interface
    //-----------------------------------------------------------------------------------------
    // rx ingress interface:  Inputs from PTP bridge

    .axi_st_rx_tvalid_i                (dma_gbx_ptpb_axi_st_rx_tvalid              [i]),        
    .axi_st_rx_tdata_i                 (dma_gbx_ptpb_axi_st_rx_tdata               [i]),         
    .axi_st_rx_tkeep_i                 (dma_gbx_ptpb_axi_st_rx_tkeep               [i]),         
    .axi_st_rx_tlast_i                 (dma_gbx_ptpb_axi_st_rx_tlast               [i]),         
    .axi_st_rx_tuser_client_i          (dma_gbx_ptpb_axi_st_rx_tuser_client        [i]),    
    .axi_st_rx_tuser_sts_i             (dma_gbx_ptpb_axi_st_rx_tuser_sts           [i]),       
    .axi_st_rx_tuser_sts_extended_i    ('{default:0}),                   
    .axi_st_rx_tuser_pkt_seg_parity_i  ('0),                             
    .axi_st_rx_tuser_last_segment_i    (dma_gbx_ptpb_axi_st_rx_tuser_last_segment_conv  [i]), 
    .axi_st_rx_tready_o                (),                                    

    //-----------------------------------------------------------------------------------------
    // rx egress interface: outputs to DMA
    .axi_st_rx_tvalid_o                (axi_st_rx_tvalid_o               [i]),  
    .axi_st_rx_tdata_o                 (axi_st_rx_tdata_o                [i]),  
    .axi_st_rx_tkeep_o                 (axi_st_rx_tkeep_o                [i]),  
    .axi_st_rx_tlast_o                 (axi_st_rx_tlast_o                [i]),  
    .axi_st_rx_tuser_client_o          (axi_st_rx_tuser_client_o         [i]),  
    .axi_st_rx_tuser_sts_o             (axi_st_rx_tuser_sts_o            [i]),  
    .axi_st_rx_tuser_sts_extended_o    (                                    ),  
    .axi_st_rx_tuser_pkt_seg_parity_o  (                                    ),  
    .axi_st_rx_tuser_last_segment_o    (                                    ),  
    .axi_st_rx_tready_i                (6'h3F)                                      ,  

    // tx egress timestamp from PTP Bridge interface

    .axi_st_txegrts0_tvalid_i (dma_gbx_ptpb_axi_st_txegrts0_tvalid_o[i]),           
    .axi_st_txegrts0_tdata_i  (dma_gbx_ptpb_axi_st_txegrts0_tdata_o[i]),            
    .axi_st_txegrts1_tvalid_i (),                                      
    .axi_st_txegrts1_tdata_i  (),                                      

    // tx egress timestamp to DMA interface                     
    .axi_st_txegrts0_tvalid_o  (dma_axi_st_txegrts0_tvalid_o[i]),      
    .axi_st_txegrts0_tdata_o   (dma_axi_st_txegrts0_tdata_o [i]),      
    .axi_st_txegrts1_tvalid_o  (),                                     
    .axi_st_txegrts1_tdata_o   (),                                     

    //-----------------------------------------------------------------------------------------
    // rx ingress timestamp from PTP bridge interface
    
    .axi_st_rxegrts0_tvalid_i (dma_gbx_ptpb_axi_st_rxigrts0_tvalid[i]),        
    .axi_st_rxegrts0_tdata_i  (dma_gbx_ptpb_axi_st_rxigrts0_tdata[i]),         
    .axi_st_rxegrts1_tvalid_i (),                                    
    .axi_st_rxegrts1_tdata_i  (),                                    

    // tx ingress timestamp to DMA interface                  
    .axi_st_rxegrts0_tvalid_o  (dma_axi_st_rxigrts0_tvalid[i]),   
    .axi_st_rxegrts0_tdata_o   (dma_axi_st_rxigrts0_tdata [i]),   
    .axi_st_rxegrts1_tvalid_o  (),                                   
    .axi_st_rxegrts1_tdata_o   ()                                    
     );                                                              
end endgenerate


//---------------------------------------------------------------------------------------------
//  - Supports the following valid combination
//    - 10/25G:  DMA_TDATA_WIDTH  = 64;   DMA_NUM_OF_SEG =  1; DMA_NUM_OF_SOP  = 1;
//               HSSI_TDATA_WIDTH = 64;  HSSI_NUM_OF_SEG =  1; HSSI_NUM_OF_SOP = 1;
//
//    - 50G:     DMA_TDATA_WIDTH  =  64;  DMA_NUM_OF_SEG =  1; DMA_NUM_OF_SOP  = 1;
//               HSSI_TDATA_WIDTH = 128; HSSI_NUM_OF_SEG =  2; HSSI_NUM_OF_SOP = 1;
//
//    - 100G:    DMA_TDATA_WIDTH  =  64;  DMA_NUM_OF_SEG =  1; DMA_NUM_OF_SOP  = 1;
//               HSSI_TDATA_WIDTH = 256; HSSI_NUM_OF_SEG =  4; HSSI_NUM_OF_SOP = 1;
//
//    - 200G:    DMA_TDATA_WIDTH  =  64;  DMA_NUM_OF_SEG =  1; DMA_NUM_OF_SOP  = 1;
//               HSSI_TDATA_WIDTH = 512; HSSI_NUM_OF_SEG =  8; HSSI_NUM_OF_SOP = 1;
//
//    - 400G:    DMA_TDATA_WIDTH  =  64;  DMA_NUM_OF_SEG =  1; DMA_NUM_OF_SOP  = 1;
//               HSSI_TDATA_WIDTH = 1024;HSSI_NUM_OF_SEG = 16; HSSI_NUM_OF_SOP = 1;
//--------------------------------------------------------------------------------------------	
ptp_bridge_subsys
   #(.HSSI_PORT  (NUM_PORTS )
    ,.USER_PORT  (NUM_PORTS )
    ,.DMA_CHNL   (DMA_CHS   )

    ,.DMA_DATA_WIDTH           (HSSI_TDATA_WIDTH        ) // HSSI_TDATA_WIDTH 64b, 128b, 256b
    ,.USER_DATA_WIDTH          (USER_DATA_WIDTH         ) // USER_DATA_WIDTH 64b, 128b, 256b
    ,.HSSI_DATA_WIDTH          (HSSI_TDATA_WIDTH        ) // HSSI_TDATA_WIDTH 64b, 128b, 256b

    ,.DMA_NUM_OF_SEG           (DMA_NUM_OF_SEG         )
    ,.HSSI_NUM_OF_SEG          (DMA_NUM_OF_SEG         )
    ,.USER_NUM_OF_SEG          (USER_NUM_OF_SEG        )

    ,.HSSI_IGR_FIFO_DEPTH      (PTP_BRDG_HSSI_IGR_FIFO_DEPTH)
    ,.USER_IGR_FIFO_DEPTH      (PTP_BRDG_USER_IGR_FIFO_DEPTH)
    ,.DMA_IGR_FIFO_DEPTH       (PTP_BRDG_DMA_IGR_FIFO_DEPTH )

    ,.TX_CLIENT_WIDTH          (TX_CLIENT_WIDTH        )
    ,.RX_CLIENT_WIDTH          (RX_CLIENT_WIDTH        )
 
    ,.TXEGR_TS_DW              (TXEGR_TS_DW            )
    ,.RXIGR_TS_DW              (RXIGR_TS_DW            )
    ,.SYS_FINGERPRINT_WIDTH    (TS_REQ_FP_WIDTH        )

    ,.PTP_WIDTH                (PTP_WIDTH              )
    ,.PTP_EXT_WIDTH            (PTP_EXT_WIDTH          )
    ,.STS_WIDTH                (STS_WIDTH              )
    ,.STS_EXT_WIDTH            (STS_EXT_WIDTH          )

    ,.AWADDR_WIDTH             (PTP_BRDG_AWADDR_WIDTH  )
    ,.WDATA_WIDTH              (PTP_BRDG_WDATA_WIDTH   )

    ,.TCAM_KEY_WIDTH           (TCAM_KEY_WIDTH         )
    ,.TCAM_RESULT_WIDTH        (TCAM_RESULT_WIDTH      )
    ,.TCAM_ENTRIES             (TCAM_ENTRIES           )
    ,.TCAM_USERMETADATA_WIDTH  (TCAM_USERMETADATA_WIDTH)

    // default: IGR HSSI, msgDMA, and User are all little endian
    ,.IGR_DMA_BYTE_ROTATE      (IGR_DMA_BYTE_ROTATE    )
    ,.IGR_USER_BYTE_ROTATE     (IGR_USER_BYTE_ROTATE   )
    ,.IGR_HSSI_BYTE_ROTATE     (IGR_HSSI_BYTE_ROTATE   )

    // default: EGR HSSI, msgDMA, and User are all little endian
    ,.EGR_DMA_BYTE_ROTATE      (EGR_DMA_BYTE_ROTATE    )
    ,.EGR_USER_BYTE_ROTATE     (EGR_USER_BYTE_ROTATE   )
    ,.EGR_HSSI_BYTE_ROTATE     (EGR_HSSI_BYTE_ROTATE   )
    
    ,.DBG_CNTR_EN              (DBG_CNTR_EN            )
   ) ptp_bridge_subsys

  (
   //AXI Streaming Interface     
      // Tx streaming clock
       .tx_clk_i              (o_clk_pll)
      ,.tx_areset_n_i         ({!hssi_pll_rst[1], !hssi_pll_rst[0]})
      // Rx streaming clock & reset                 
      ,.rx_clk_i              (o_clk_pll)
      ,.rx_areset_n_i         ({!hssi_pll_rst[1], !hssi_pll_rst[0]})

      // axi_lite csr clock & reset
      ,.axi_lite_clk_i        (axi4lite_clk_clk  )
      ,.axi_lite_rst_n_i      (axi4lite_rst_reset_n)
    
      // init_done status
      ,.tx_init_done_o        (tx_init_done)
      ,.rx_init_done_o        (rx_init_done)
    
      //TCAM Reset Interface // ID check the connection
      ,.app_ss_cold_rst_n     (tcam_cold_rst_n)
      ,.app_ss_warm_rst_n     (tcam_warm_rst_n)
      ,.app_ss_rst_req        ('0)
      ,.ss_app_rst_rdy        ()
      ,.ss_app_cold_rst_ack_n (ss_app_cold_rst_ack_n)
      ,.ss_app_warm_rst_ack_n (ss_app_warm_rst_ack_n)
      ,.axi_lite_awaddr_i     (axi4lite_ptpb.awaddr )
      ,.axi_lite_awvalid_i    (axi4lite_ptpb.awvalid)
      ,.axi_lite_awready_o    (axi4lite_ptpb.awready)
      ,.axi_lite_wdata_i      (axi4lite_ptpb.wdata )
      ,.axi_lite_wvalid_i     (axi4lite_ptpb.wvalid)
      ,.axi_lite_wready_o     (axi4lite_ptpb.wready)
      ,.axi_lite_wstrb_i      (axi4lite_ptpb.wstrb )
      ,.axi_lite_bresp_o      (axi4lite_ptpb.bresp  )
      ,.axi_lite_bvalid_o     (axi4lite_ptpb.bvalid )
      ,.axi_lite_bready_i     (axi4lite_ptpb.bready )
      ,.axi_lite_araddr_i     (axi4lite_ptpb.araddr )
      ,.axi_lite_arvalid_i    (axi4lite_ptpb.arvalid)
      ,.axi_lite_arready_o    (axi4lite_ptpb.arready)
      ,.axi_lite_rresp_o      (axi4lite_ptpb.rresp )
      ,.axi_lite_rdata_o      (axi4lite_ptpb.rdata )
      ,.axi_lite_rvalid_o     (axi4lite_ptpb.rvalid)
      ,.axi_lite_rready_i     (axi4lite_ptpb.rready)
    
      // TX Interface:  
      //----------------------------------------------------------------------------
      // tx ingress interface - Input from DMA-GBX 
      // inputs
    
      ,.dma_axi_st_tx_tvalid_i                (dma_gbx_ptpb_axi_st_tx_tvalid               )
      ,.dma_axi_st_tx_tdata_i                 (dma_gbx_ptpb_axi_st_tx_tdata                )
      ,.dma_axi_st_tx_tkeep_i                 (dma_gbx_ptpb_axi_st_tx_tkeep                )
      ,.dma_axi_st_tx_tlast_i                 (dma_gbx_ptpb_axi_st_tx_tlast                )
      ,.dma_axi_st_tx_tuser_ptp_i             (dma_gbx_ptpb_axi_st_tx_tuser_ptp            )
      ,.dma_axi_st_tx_tuser_ptp_extended_i    (dma_gbx_ptpb_axi_st_tx_tuser_ptp_extended   )
      ,.dma_axi_st_tx_tuser_client_i          (dma_gbx_ptpb_axi_st_tx_tuser_client)
      ,.dma_axi_st_tx_tuser_pkt_seg_parity_i  (dma_gbx_ptpb_axi_st_tx_tuser_pkt_seg_parity )  
      ,.dma_axi_st_tx_tuser_last_segment_i    (dma_gbx_ptpb_axi_st_tx_tuser_last_segment   )  

      // output
      ,.dma_axi_st_tx_tready_o                (dma_gbx_ptpb_axi_st_tx_tready               )
	  
      //----------------------------------------------------------------------------
      // tx ingress interface - Input from USER
      ,.user_axi_st_tx_tvalid_i               (user_axi_st_tx_tvalid_i              )
      ,.user_axi_st_tx_tdata_i                (user_axi_st_tx_tdata_i               )
      ,.user_axi_st_tx_tkeep_i                (user_axi_st_tx_tkeep_i               )
      ,.user_axi_st_tx_tlast_i                (user_axi_st_tx_tlast_i               )
      ,.user_axi_st_tx_tuser_ptp_i            (user_axi_st_tx_tuser_ptp_i           )
      ,.user_axi_st_tx_tuser_ptp_extended_i   (user_axi_st_tx_tuser_ptp_extended_i  )
      ,.user_axi_st_tx_tuser_client_i         (user_axi_st_tx_tuser_client_i        )
      ,.user_axi_st_tx_tuser_pkt_seg_parity_i (user_axi_st_tx_tuser_pkt_seg_parity_i)
      ,.user_axi_st_tx_tuser_last_segment_i   (user_axi_st_tx_tuser_last_segment_i  )

      ,.user_axi_st_tx_tready_o               (user_axi_st_tx_tready_o              )
   
    //-----------------------------------------------------------------------------
    // tx egress interface - Outputs to Gearbox (ptpb-gbx-hssi)
    // outputs
      ,.hssi_axi_st_tx_tvalid_o               (hssi_ss_st_tx_tvalid             )
      ,.hssi_axi_st_tx_tdata_o                (hssi_ss_st_tx_tdata              )
      ,.hssi_axi_st_tx_tkeep_o                (hssi_ss_st_tx_tkeep              )
      ,.hssi_axi_st_tx_tlast_o                (hssi_ss_st_tx_tlast              )
      ,.hssi_axi_st_tx_tuser_ptp_o            (hssi_ss_st_tx_tuser_ptp          )
      ,.hssi_axi_st_tx_tuser_ptp_extended_o   (hssi_ss_st_tx_tuser_ptp_extended )
      ,.hssi_axi_st_tx_tuser_client_o         (axi_st_tx_tuser_client_o         )
      ,.hssi_axi_st_tx_tuser_pkt_seg_parity_o (                                 ) 
      ,.hssi_axi_st_tx_tuser_last_segment_o   (                                 ) // ptp bridge supports single segment only

    // input                                                                      
      ,.hssi_axi_st_tx_tready_i               (hssi_ss_st_tx_tready             )

    //=============================================================================
    // RX Interface
    //-----------------------------------------------------------------------------
    // rx ingress interface -  Inputs from Gearbox (ptpb-gbx-hssi)
    // inputs
    ,.hssi_axi_st_rx_tvalid_i               (ms_hssi_ss_st_rx_tvalid                 )
    ,.hssi_axi_st_rx_tdata_i                (ms_hssi_ss_st_rx_tdata                  )
    ,.hssi_axi_st_rx_tkeep_i                (ms_hssi_ss_st_rx_tkeep                  )
    ,.hssi_axi_st_rx_tlast_i                (ms_hssi_ss_st_rx_tlast                  )
    //Rx Packet Error Status                                                      
    ,.hssi_axi_st_rx_tuser_client_i         (hssi_axi_st_rx_tuser_client_i           )
    //Rx Packet Status                                                            
    ,.hssi_axi_st_rx_tuser_sts_i            (hssi_axi_st_rx_tuser_sts_i              )
    ,.hssi_axi_st_rx_tuser_sts_extended_i   (ms_hssi_ss_st_rx_tuser_sts_extended     )
    ,.hssi_axi_st_rx_tuser_pkt_seg_parity_i (ms_hssi_ss_st_rx_tuser_pkt_seg_parity   )
    ,.hssi_axi_st_rx_tuser_last_segment_i   (ms_hssi_ss_st_rx_tuser_last_segment     ) // ptp bridge supports single segment only

    // outputs                                                                    
    ,.hssi_axi_st_rx_tready_o               (                                        )
    ,.hssi_axi_st_rx_pause_o                (                                        )

    //--------------------------------------------------------------------------------
    // rx egress interface - Output to DMA - GBX
    // outputs

    ,.dma_axi_st_rx_tvalid_o                (dma_gbx_ptpb_axi_st_rx_tvalid                  )
    ,.dma_axi_st_rx_tdata_o                 (dma_gbx_ptpb_axi_st_rx_tdata                   )
    ,.dma_axi_st_rx_tkeep_o                 (dma_gbx_ptpb_axi_st_rx_tkeep                   )
    ,.dma_axi_st_rx_tlast_o                 (dma_gbx_ptpb_axi_st_rx_tlast                   )
    //Rx Packet Error Status                                                    
    ,.dma_axi_st_rx_tuser_client_o          (dma_axi_st_rx_tuser_client )  //dma_gbx_ptpb_axi_st_rx_tuser_client            )
    //Rx Packet Status                                                          
    ,.dma_axi_st_rx_tuser_sts_o             (dma_axi_st_rx_tuser_sts) //dma_gbx_ptpb_axi_st_rx_tuser_sts               )
    ,.dma_axi_st_rx_tuser_sts_extended_o    (                                               )
    ,.dma_axi_st_rx_tuser_pkt_seg_parity_o  (                                               )
    ,.dma_axi_st_rx_tuser_last_segment_o    (dma_gbx_ptpb_axi_st_rx_tuser_last_segment      )

    // input
    ,.dma_axi_st_rx_tready_i                (6'h3F                                          )

    //---------------------------------------------------------------------------
    // rx egress interface - Output to USER
    ,.user_axi_st_rx_tvalid_o               (user_axi_st_rx_tvalid_o             )
    ,.user_axi_st_rx_tdata_o                (user_axi_st_rx_tdata_o              )
    ,.user_axi_st_rx_tkeep_o                (user_axi_st_rx_tkeep_o              )
    ,.user_axi_st_rx_tlast_o                (user_axi_st_rx_tlast_o              )
    //Rx Packet Error Status                                                     
    ,.user_axi_st_rx_tuser_client_o         (user_axi_st_rx_tuser_client_o       )
    //Rx Packet Status                                                           
    ,.user_axi_st_rx_tuser_sts_o            (                                    )
    ,.user_axi_st_rx_tuser_sts_extended_o   (                                    )
    ,.user_axi_st_rx_tuser_pkt_seg_parity_o (                                    )
    ,.user_axi_st_rx_tuser_last_segment_o   (                                    )

    ,.user_axi_st_rx_tready_i               (user_axi_st_rx_tready_i             )

    //===========================================================================
    // Time Stamp Interface:
    //---------------------------------------------------------------------------
    // tx egress timestamp from GBX
    //inputs
    ,.hssi_axi_st_txegrts0_tvalid_i         (hssi_ptp_tx_egrts_tvalid        )
    ,.hssi_axi_st_txegrts0_tdata_i          (hssi_ptp_tx_egrts_tdata         )
    ,.hssi_axi_st_txegrts1_tvalid_i         ('0)
    ,.hssi_axi_st_txegrts1_tdata_i          ('0)

     // tx egress timestamp to dma_gbx_ptpb                                        
    ,.dma_axi_st_txegrts0_tvalid_o          (dma_gbx_ptpb_axi_st_txegrts0_tvalid_o  )
    ,.dma_axi_st_txegrts0_tdata_o           (dma_gbx_ptpb_axi_st_txegrts0_tdata_o   )
    ,.dma_axi_st_txegrts1_tvalid_o          (                                    )
    ,.dma_axi_st_txegrts1_tdata_o           (                                    )

    // tx egress timestamp to USER                               
    ,.user_axi_st_txegrts0_tvalid_o         (                                    )
    ,.user_axi_st_txegrts0_tdata_o          (                                    )
    ,.user_axi_st_txegrts1_tvalid_o         (                                    )
    ,.user_axi_st_txegrts1_tdata_o          (                                    )


    //-----------------------------------------------------------------------------------------
    // rx ingress timestamp from GBX
    // inputs
    ,.hssi_axi_st_rxigrts0_tvalid_i        (ms_hssi_ptp_rx_ingrts_tvalid ) 
    ,.hssi_axi_st_rxigrts0_tdata_i         (ms_hssi_ptp_rx_ingrts_tdata  ) 
    ,.hssi_axi_st_rxigrts1_tvalid_i        ('0)
    ,.hssi_axi_st_rxigrts1_tdata_i         ('0)

    // rx ingress timestamp to dma_gbx_ptpb  
    // outputs                              
    ,.dma_axi_st_rxigrts0_tvalid_o         (dma_gbx_ptpb_axi_st_rxigrts0_tvalid           )
    ,.dma_axi_st_rxigrts0_tdata_o          (dma_gbx_ptpb_axi_st_rxigrts0_tdata            )
    ,.dma_axi_st_rxigrts1_tvalid_o         (                                     )
    ,.dma_axi_st_rxigrts1_tdata_o          (                                     )

    // rx ingress timestamp to USER                               
    ,.user_axi_st_rxigrts0_tvalid_o        (                                     )
    ,.user_axi_st_rxigrts0_tdata_o         (                                     )
    ,.user_axi_st_rxigrts1_tvalid_o        (                                     )
    ,.user_axi_st_rxigrts1_tdata_o         (                                     )
   );

generate for(genvar i=0;i<NUM_PORTS;i++) begin : gen_mulit_inst

  eth_f_packet_client_top_axi_adaptor #(
      .WIDTH                                 (DATA_WIDTH),
      .WORDS                                 (WORDS),
      .EMPTY_WIDTH                           (EMPTY_WIDTH)
  ) packet_client_axi_adaptor_top_0(
      .i_arst                                (!hssi_pll_rst[i]), // active low reset
      .i_clk_tx                              (o_clk_pll[i] ),
      .i_clk_rx                              (o_clk_pll[i] ),
	  
      //from packet client tx
      .o_avst_tx_ready                       (avst_tx_ready_int            [i]),
      .i_avst_tx_valid                       (avst_tx_valid_int            [i]),
      .i_avst_tx_sop                         (avst_tx_sop_int              [i]),
      .i_avst_tx_eop                         (avst_tx_eop_int              [i]),
      .i_avst_tx_empty                       (avst_tx_empty_int            [i]),
      .i_avst_tx_data                        (avst_tx_data_int             [i]),
      .i_avst_tx_error                       (avst_tx_error_int            [i]),
      .i_avst_tx_skip_crc                    (avst_tx_skip_crc_int         [i]),
	  
      // to ptp_bridge                                                         
      .i_axis_tx_ready                       (user_axi_st_tx_tready_o      [i]),
      .o_axis_tx_valid                       (user_axi_st_tx_tvalid_i      [i]),
      .o_axis_tx_tdata                       (user_axi_st_tx_tdata_i       [i]),
      .o_axis_tx_tkeep                       (user_axi_st_tx_tkeep_i       [i]),
      .o_axis_tx_tlast                       (user_axi_st_tx_tlast_i       [i]),
      .o_axis_tx_tuser                       (user_axi_st_tx_tuser_ptp_i   [i]),
	  
      // from ptp_bridge
      .o_axis_rx_ready                       (user_axi_st_rx_tready_i      [i]),
      .i_axis_rx_valid                       (user_axi_st_rx_tvalid_o      [i]),
      .i_axis_rx_tdata                       (user_axi_st_rx_tdata_o       [i]),
      .i_axis_rx_tlast                       (user_axi_st_rx_tlast_o       [i]),
      .i_axis_rx_tkeep                       (user_axi_st_rx_tkeep_o       [i]),
      .i_axis_rx_tuser                       (user_axi_st_rx_tuser_client_o[i]),
	  
      // to packet client rx
      .i_avst_rx_ready                       (1'b1),
      .o_avst_rx_valid                       (avst_rx_valid_int            [i]),
      .o_avst_rx_tdata                       (avst_rx_tdata_int            [i]),
      .o_avst_rx_empty                       (avst_rx_empty_int            [i]),
      .o_avst_rx_sop                         (avst_rx_sop_int              [i]),
      .o_avst_rx_eop                         (avst_rx_eop_int              [i]),
      .o_tx_st_eop_sync_with_macsec_tuser_error ()
  );
  
 eth_f_packet_client_top #(
       .PKT_CYL          (PKT_CYL          ) 
      ,.CLIENT_IF_TYPE   (CLIENT_IF_TYPE   ) 
      ,.READY_LATENCY    (READY_LATENCY    ) 
      ,.DATA_WIDTH       (DATA_WIDTH       ) 
      ,.WORDS            (WORDS            ) 
      ,.EMPTY_WIDTH      (EMPTY_WIDTH      ) 
    ) i_eth_f_packet_client_top (
      .i_arst                                (hssi_pll_rst[i]) , //active high reset
      .i_clk_tx                              (o_clk_pll   [i] ),
      .i_clk_rx                              (o_clk_pll   [i] ),
      .i_clk_status                          (axi4lite_clk_clk),
      .i_clk_status_rst                      (!axi4lite_rst_reset_n),
     
       //AVST TX IF -done
      .i_tx_ready                            (avst_tx_ready_int     [i]),
      .o_tx_valid                            (avst_tx_valid_int     [i]),
      .o_tx_sop                              (avst_tx_sop_int       [i]),
      .o_tx_eop                              (avst_tx_eop_int       [i]),
      .o_tx_empty                            (avst_tx_empty_int     [i]),
      .o_tx_data                             (avst_tx_data_int      [i]),
      .o_tx_error                            (avst_tx_error_int     [i]),
      .o_tx_skip_crc                         (avst_tx_skip_crc_int  [i]),
      .i_rx_valid                            (avst_rx_valid_int     [i]),
      .i_rx_sop                              (avst_rx_sop_int       [i]),
      .i_rx_eop                              (avst_rx_eop_int       [i]),
      .i_rx_empty                            (avst_rx_empty_int     [i]),
      .i_rx_data                             (avst_rx_tdata_int     [i]),
      .i_rx_error                            (7'b0),    
      .i_rxstatus_valid                      (1'b0),
      .i_rxstatus_data                       (40'd0),
      .i_rx_preamble                         (64'b0),
      .o_tx_preamble                         (),
     
      .pktcli_csr_if_slv                     (axi4lite_pktcli       [i]),
      .o_cold_rst_csr                        (),  
      .i_sadb_config_done                    (0),
      .i_system_status                       (trafficgen_system_status[i])
);
end endgenerate


`ifdef FTILE_PTP_HSSI_10G_25G  
  `ifdef FTILE_PTP_HSSI_25G
     hssi_ss_25G #( 
      `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port1_hssi_25G 
  `elsif  FTILE_PTP_HSSI_25G_ANLT
     hssi_ss_25G_anlt #( 
      `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port1_hssi_25G_anlt 	
  `elsif  FTILE_PTP_HSSI_10G_25G_NON_ANLT_DR
     hssi_ss_10G_25G_non_anlt_dr #( 
      `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port1_hssi_10G_25G_non_anlt_dr 	
  `elsif FTILE_PTP_HSSI_10G 
     hssi_ss_10G #( 
      `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port1_hssi_10G 	
  `elsif FTILE_PTP_HSSI_10G_ANLT 
     hssi_ss_10G_anlt #( 
      `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port1_hssi_10G_anlt 	
   `endif
   
   (
      .app_ss_lite_clk                    (axi4lite_clk_clk),       
      .app_ss_lite_areset_n               (axi4lite_rst_reset_n),   
      .app_ss_lite_awaddr                 (axi4lite_hssi.awaddr),   
      .app_ss_lite_awprot                 (axi4lite_hssi.awprot),   
      .app_ss_lite_awvalid                (axi4lite_hssi.awvalid),  
      .ss_app_lite_awready                (axi4lite_hssi.awready),  
      .app_ss_lite_wdata                  (axi4lite_hssi.wdata),    
      .app_ss_lite_wstrb                  (axi4lite_hssi.wstrb),    
      .app_ss_lite_wvalid                 (axi4lite_hssi.wvalid),   
      .ss_app_lite_wready                 (axi4lite_hssi.wready),   
      .ss_app_lite_bresp                  (axi4lite_hssi.bresp),    
      .ss_app_lite_bvalid                 (axi4lite_hssi.bvalid),   
      .app_ss_lite_bready                 (axi4lite_hssi.bready),   
      .app_ss_lite_araddr                 (axi4lite_hssi.araddr),   
      .app_ss_lite_arprot                 (axi4lite_hssi.arprot),   
      .app_ss_lite_arvalid                (axi4lite_hssi.arvalid),  
      .ss_app_lite_arready                (axi4lite_hssi.arready),  
      .ss_app_lite_rdata                  (axi4lite_hssi.rdata),    
      .ss_app_lite_rvalid                 (axi4lite_hssi.rvalid),   
      .app_ss_lite_rready                 (axi4lite_hssi.rready),   
      .ss_app_lite_rresp                  (axi4lite_hssi.rresp),    
      .p8_app_ss_st_tx_clk                (o_clk_pll[0]),           
      .p8_app_ss_st_tx_areset_n           (rst_n_eth_p[0]),                      
      .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[0] ),            
      .p8_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[0] ),            
      .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[0] ),             
      .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[0] ),             
      .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[0] ),             
      .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[0]),       
      .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[0]),          
      .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[0]), 
      .p8_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[0]), 
      .p8_app_ss_st_rx_clk                (o_clk_pll[0]),                        
      .p8_app_ss_st_rx_areset_n           (rst_n_eth_p[0]),                      
      .p8_ss_app_st_rx_tvalid             (hssi_ss_st_rx_tvalid[0]),             
      .p8_ss_app_st_rx_tdata              (hssi_ss_st_rx_tdata[0]),              
      .p8_ss_app_st_rx_tkeep              (hssi_ss_st_rx_tkeep[0]),              
      .p8_ss_app_st_rx_tlast              (hssi_ss_st_rx_tlast[0]),              
      .p8_ss_app_st_rx_tuser_client       (hssi_ss_st_rx_tuser_client[0]),       
      .p8_ss_app_st_rx_tuser_last_segment (hssi_ss_st_rx_tuser_last_segment[0]), 
      .p8_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx_tuser_sts[0]),      
      .p8_app_ss_st_txtod_tvalid          (hssi_ptp_tx_tod_tvalid[0]),       
      .p8_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod_tdata[0]),        
      .p8_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod_tvalid[0]),       
      .p8_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod_tdata[0]),        
      .p8_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts_tvalid[0]),     
      .p8_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts_tdata[0]),      
      .p8_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts_tvalid[0]),    
      .p8_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts_tdata[0]),     
      .i_p8_tx_pause                      (),                           
      .i_p8_tx_pfc                        (8'd0),                       
      .o_p8_rx_pause                      (),                           
      .o_p8_rx_pfc                        (),                           
      .p8_tx_serial                       (ftile_tx_serial[0]),         
      .p8_tx_serial_n                     (ftile_tx_serial_n[0]),       
      .p8_rx_serial                       (ftile_rx_serial[0]),         
      .p8_rx_serial_n                     (ftile_rx_serial_n[0]),       
      .port0_led_speed                    (),      
      .port0_led_status                   (),      
      .port1_led_speed                    (),      
      .port1_led_status                   (),      
      .port2_led_speed                    (),      
      .port2_led_status                   (),      
      .port3_led_speed                    (),      
      .port3_led_status                   (),      
      .port4_led_speed                    (),      
      .port4_led_status                   (),      
      .port5_led_speed                    (),      
      .port5_led_status                   (),      
      .port6_led_speed                    (),      
      .port6_led_status                   (),      
      .port7_led_speed                    (),      
      .port7_led_status                   (),      
      .port8_led_speed                    (),      
      .port8_led_status                   (),      
      .port9_led_speed                    (),      
      .port9_led_status                   (),      
      .port10_led_speed                   (),      
      .port10_led_status                  (),      
      .port11_led_speed                   (),      
      .port11_led_status                  (),      
      .port12_led_speed                   (),      
      .port12_led_status                  (),      
      .port13_led_speed                   (),      
      .port13_led_status                  (),      
      .port14_led_speed                   (),      
      .port14_led_status                  (),      
      .port15_led_speed                   (),      
      .port15_led_status                  (),      
      .port16_led_speed                   (),      
      .port16_led_status                  (),      
      .port17_led_speed                   (),      
      .port17_led_status                  (),      
      .port18_led_speed                   (),      
      .port18_led_status                  (),      
      .port19_led_speed                   (),      
      .port19_led_status                  (),      
      .p8_tx_lanes_stable                 (status_vector[3]),      
      .p8_rx_pcs_ready                    (status_vector[5]),      
      .o_p8_tx_pll_locked                 (status_vector[4]),      
      .o_p8_rx_pcs_fully_aligned          (),                      
      .o_p8_tx_ptp_ready                  (status_vector[6]),      
      .o_p8_rx_ptp_ready                  (status_vector[7]),      
      .o_p8_rx_ptp_offset_data_valid      (status_vector[8]),      
      .o_p8_tx_ptp_offset_data_valid      (status_vector[9]),      
      .subsystem_cold_rst_n               (hssi_cold_boot_reg[0]), 
      .subsystem_cold_rst_ack_n           (status_vector[0]),      
      .i_p8_tx_rst_n                      (p8_tx_rst_n_eth_p0), //(system_reset_n & (!reset_eth_p0)),        
      .i_p8_rx_rst_n                      (p8_rx_rst_n_eth_p0), //(system_reset_n & (!reset_eth_p0)),        
      .o_p8_rx_rst_ack_n                  (status_vector[1]),      
      .o_p8_tx_rst_ack_n                  (status_vector[2]),      
      .o_p8_ereset_n                      (),                      
      .i_clk_ref                          (ftile_clk_ref[0]),      
      .i_p8_clk_tx_tod                    (o_p8_clk_tx_div_clk),   
      .i_p8_clk_rx_tod                    (o_p8_clk_rec_div_clk),  
      .o_p8_clk_pll                       (o_clk_pll[0]),          
      .o_p8_clk_tx_div                    (o_p8_clk_tx_div_clk),   
      .o_p8_clk_rec_div64                 (),                      
      .o_p8_clk_rec_div                   (o_p8_clk_rec_div_clk),  
      .i_p8_clk_ptp_sample                (clk_ptp_sample_clk),    
      .o_p8_cdr_divclk                    (hssi_cdr_clk_out_sig)       
    );

  `ifdef FTILE_PTP_HSSI_25G
     hssi_ss_25G #( 
      `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
    ) inst_port2_hssi_25G 
  `elsif  FTILE_PTP_HSSI_25G_ANLT
     hssi_ss_25G_anlt #( 
      `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
    ) inst_port2_hssi_25G_anlt 	
  `elsif  FTILE_PTP_HSSI_10G_25G_NON_ANLT_DR
     hssi_ss_10G_25G_non_anlt_dr #( 
      `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port2_hssi_10G_25G_non_anlt_dr 	
  `elsif FTILE_PTP_HSSI_10G 
     hssi_ss_10G #( 
      `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
    ) inst_port2_hssi_10G 	
  `elsif FTILE_PTP_HSSI_10G_ANLT 
     hssi_ss_10G_anlt #( 
      `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
    ) inst_port2_hssi_10G_anlt 	
  `endif
   (
      .app_ss_lite_clk                    (axi4lite_clk_clk),                   
      .app_ss_lite_areset_n               (axi4lite_rst_reset_n),               
      .app_ss_lite_awaddr                 (axi4lite_hssi_1.awaddr),             
      .app_ss_lite_awprot                 (axi4lite_hssi_1.awprot),             
      .app_ss_lite_awvalid                (axi4lite_hssi_1.awvalid),            
      .ss_app_lite_awready                (axi4lite_hssi_1.awready),            
      .app_ss_lite_wdata                  (axi4lite_hssi_1.wdata),              
      .app_ss_lite_wstrb                  (axi4lite_hssi_1.wstrb),              
      .app_ss_lite_wvalid                 (axi4lite_hssi_1.wvalid),             
      .ss_app_lite_wready                 (axi4lite_hssi_1.wready),             
      .ss_app_lite_bresp                  (axi4lite_hssi_1.bresp),              
      .ss_app_lite_bvalid                 (axi4lite_hssi_1.bvalid),             
      .app_ss_lite_bready                 (axi4lite_hssi_1.bready),             
      .app_ss_lite_araddr                 (axi4lite_hssi_1.araddr),             
      .app_ss_lite_arprot                 (axi4lite_hssi_1.arprot),             
      .app_ss_lite_arvalid                (axi4lite_hssi_1.arvalid),            
      .ss_app_lite_arready                (axi4lite_hssi_1.arready),            
      .ss_app_lite_rdata                  (axi4lite_hssi_1.rdata),              
      .ss_app_lite_rvalid                 (axi4lite_hssi_1.rvalid),             
      .app_ss_lite_rready                 (axi4lite_hssi_1.rready),             
      .ss_app_lite_rresp                  (axi4lite_hssi_1.rresp),              
      .p8_app_ss_st_tx_clk                (o_clk_pll[1]),                       
      .p8_app_ss_st_tx_areset_n           (rst_n_eth_p[1]),                     
      .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[1] ),           
      .p8_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[1] ),           
      .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[1] ),            
      .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[1] ),            
      .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[1] ),            
      .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[1]),      
      .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[1]),         
      .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[1]),
      .p8_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[1]),
      .p8_app_ss_st_rx_clk                (o_clk_pll[1]),                       
      .p8_app_ss_st_rx_areset_n           (rst_n_eth_p[1]),                     
      .p8_ss_app_st_rx_tvalid             (hssi_ss_st_rx_tvalid[1]),            
      .p8_ss_app_st_rx_tdata              (hssi_ss_st_rx_tdata[1]),             
      .p8_ss_app_st_rx_tkeep              (hssi_ss_st_rx_tkeep[1]),             
      .p8_ss_app_st_rx_tlast              (hssi_ss_st_rx_tlast[1]),             
      .p8_ss_app_st_rx_tuser_client       (hssi_ss_st_rx_tuser_client[1]),      
      .p8_ss_app_st_rx_tuser_last_segment (hssi_ss_st_rx_tuser_last_segment[1]),
      .p8_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx_tuser_sts[1]),         
      .p8_app_ss_st_txtod_tvalid          (hssi_ptp_tx_tod_tvalid[1]),          
      .p8_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod_tdata[1]),           
      .p8_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod_tvalid[1]),          
      .p8_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod_tdata[1]),           
      .p8_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts_tvalid[1]),        
      .p8_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts_tdata[1]),         
      .p8_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts_tvalid[1]),       
      .p8_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts_tdata[1]),        
      .i_p8_tx_pause                      (),                      
      .i_p8_tx_pfc                        (8'd0),                  
      .o_p8_rx_pause                      (),                      
      .o_p8_rx_pfc                        (),                      
      .p8_tx_serial                       (ftile_tx_serial[1]),    
      .p8_tx_serial_n                     (ftile_tx_serial_n[1]),  
      .p8_rx_serial                       (ftile_rx_serial[1]),    
      .p8_rx_serial_n                     (ftile_rx_serial_n[1]),  
      .port0_led_speed                    (),                      
      .port0_led_status                   (),         
      .port1_led_speed                    (),         
      .port1_led_status                   (),         
      .port2_led_speed                    (),         
      .port2_led_status                   (),         
      .port3_led_speed                    (),         
      .port3_led_status                   (),         
      .port4_led_speed                    (),         
      .port4_led_status                   (),         
      .port5_led_speed                    (),         
      .port5_led_status                   (),         
      .port6_led_speed                    (),         
      .port6_led_status                   (),         
      .port7_led_speed                    (),         
      .port7_led_status                   (),         
      .port8_led_speed                    (),         
      .port8_led_status                   (),         
      .port9_led_speed                    (),         
      .port9_led_status                   (),         
      .port10_led_speed                   (),         
      .port10_led_status                  (),         
      .port11_led_speed                   (),         
      .port11_led_status                  (),         
      .port12_led_speed                   (),         
      .port12_led_status                  (),         
      .port13_led_speed                   (),         
      .port13_led_status                  (),         
      .port14_led_speed                   (),         
      .port14_led_status                  (),         
      .port15_led_speed                   (),         
      .port15_led_status                  (),         
      .port16_led_speed                   (),         
      .port16_led_status                  (),         
      .port17_led_speed                   (),         
      .port17_led_status                  (),         
      .port18_led_speed                   (),         
      .port18_led_status                  (),         
      .port19_led_speed                   (),         
      .port19_led_status                  (),         
      .p8_tx_lanes_stable                 (status_vector[13]),     
      .p8_rx_pcs_ready                    (status_vector[15]),     
      .o_p8_tx_pll_locked                 (status_vector[14]),     
      .o_p8_rx_pcs_fully_aligned          (),                      
      .o_p8_tx_ptp_ready                  (status_vector[16]),     
      .o_p8_rx_ptp_ready                  (status_vector[17]),     
      .o_p8_rx_ptp_offset_data_valid      (status_vector[18]),     
      .o_p8_tx_ptp_offset_data_valid      (status_vector[19]),     
      .subsystem_cold_rst_n               (hssi_cold_boot_reg[1]), 
      .subsystem_cold_rst_ack_n           (status_vector[10]),     
      .i_p8_tx_rst_n                      (p8_tx_rst_n_eth_p1), //(system_reset_n & (!reset_eth_p1)),        
      .i_p8_rx_rst_n                      (p8_rx_rst_n_eth_p1), //(system_reset_n & (!reset_eth_p1))        
      .o_p8_rx_rst_ack_n                  (status_vector[11]),     
      .o_p8_tx_rst_ack_n                  (status_vector[12]),     
      .o_p8_ereset_n                      (),                      
      .i_clk_ref                          (ftile_clk_ref[1]),      
      .i_p8_clk_tx_tod                    (o_p9_clk_tx_div_clk),   
      .i_p8_clk_rx_tod                    (o_p9_clk_rec_div_clk),  
      .o_p8_clk_pll                       (o_clk_pll[1]),          
      .o_p8_clk_tx_div                    (o_p9_clk_tx_div_clk),   
      .o_p8_clk_rec_div64                 (),                      
      .o_p8_clk_rec_div                   (o_p9_clk_rec_div_clk),  
      .i_p8_clk_ptp_sample                (clk_ptp_sample_clk_1),  
      .o_p8_cdr_divclk                    ()                       
    );

//50G PAM4 ANLT
`elsif FTILE_PTP_HSSI_50G_AUI1_PAM4_ANLT  
  hssi_ss_50G_PAM4_anlt #(
   `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port1_hssi_50G_PAM4_anlt ( 
       .app_ss_lite_clk                    (axi4lite_clk_clk),          
       .app_ss_lite_areset_n               (axi4lite_rst_reset_n),      
       .app_ss_lite_awaddr                 (axi4lite_hssi.awaddr),      
       .app_ss_lite_awprot                 (axi4lite_hssi.awprot),      
       .app_ss_lite_awvalid                (axi4lite_hssi.awvalid),     
       .ss_app_lite_awready                (axi4lite_hssi.awready),     
       .app_ss_lite_wdata                  (axi4lite_hssi.wdata),       
       .app_ss_lite_wstrb                  (axi4lite_hssi.wstrb),       
       .app_ss_lite_wvalid                 (axi4lite_hssi.wvalid),      
       .ss_app_lite_wready                 (axi4lite_hssi.wready),      
       .ss_app_lite_bresp                  (axi4lite_hssi.bresp),       
       .ss_app_lite_bvalid                 (axi4lite_hssi.bvalid),      
       .app_ss_lite_bready                 (axi4lite_hssi.bready),      
       .app_ss_lite_araddr                 (axi4lite_hssi.araddr),      
       .app_ss_lite_arprot                 (axi4lite_hssi.arprot),      
       .app_ss_lite_arvalid                (axi4lite_hssi.arvalid),     
       .ss_app_lite_arready                (axi4lite_hssi.arready),     
       .ss_app_lite_rdata                  (axi4lite_hssi.rdata),       
       .ss_app_lite_rvalid                 (axi4lite_hssi.rvalid),      
       .app_ss_lite_rready                 (axi4lite_hssi.rready),      
       .ss_app_lite_rresp                  (axi4lite_hssi.rresp),       
       .p8_app_ss_st_tx_clk                (o_clk_pll[0]),              
       .p8_app_ss_st_tx_areset_n           (system_reset_n),            
       .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[0] ),  
       .p8_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[0] ),  
       .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[0] ),   
       .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[0] ),   
       .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[0] ),   
       .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[0]),         
       .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[0]),            
       .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[0]),   
       .p8_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[0]),   
       .p8_app_ss_st_rx_clk                 (o_clk_pll[0]),                         
       .p8_app_ss_st_rx_areset_n            (system_reset_n),                       
       .p8_ss_app_st_rx_tvalid              (hssi_ss_st_rx_tvalid[0]),              
       .p8_ss_app_st_rx_tdata               (hssi_ss_st_rx_tdata[0]),               
       .p8_ss_app_st_rx_tkeep               (hssi_ss_st_rx_tkeep[0]),               
       .p8_ss_app_st_rx_tlast               (hssi_ss_st_rx_tlast[0]),               
       .p8_ss_app_st_rx_tuser_client        (hssi_ss_st_rx_tuser_client[0]),        
       .p8_ss_app_st_rx_tuser_last_segment  (hssi_ss_st_rx_tuser_last_segment[0]),  
       .p8_ss_app_st_rx_tuser_sts           (hssi_ss_st_rx_tuser_sts[0]),           
       .p8_app_ss_st_txtod_tvalid           (hssi_ptp_tx_tod_tvalid[0]),            
       .p8_app_ss_st_txtod_tdata            (hssi_ptp_tx_tod_tdata[0]),             
       .p8_app_ss_st_rxtod_tvalid           (hssi_ptp_rx_tod_tvalid[0]),            
       .p8_app_ss_st_rxtod_tdata            (hssi_ptp_rx_tod_tdata[0]),             
       .p8_ss_app_st_txegrts0_tvalid        (hssi_ptp_tx_egrts_tvalid[0]),          
       .p8_ss_app_st_txegrts0_tdata         (hssi_ptp_tx_egrts_tdata[0]),           
       .p8_ss_app_st_rxingrts0_tvalid       (hssi_ptp_rx_ingrts_tvalid[0]),         
       .p8_ss_app_st_rxingrts0_tdata        (hssi_ptp_rx_ingrts_tdata[0]),         
       .i_p8_tx_pause                       (),                                    
       .i_p8_tx_pfc                         (8'd0),                            
       .o_p8_rx_pause                       (),                                
       .o_p8_rx_pfc                         (),                                
       .p8_tx_serial                        (ftile_tx_serial[0]),              
       .p8_tx_serial_n                      (ftile_tx_serial_n[0]),            
       .p8_rx_serial                        (ftile_rx_serial[0]),              
       .p8_rx_serial_n                      (ftile_rx_serial_n[0]),            
       .port0_led_speed                     (),                                
       .port0_led_status                    (),                                
       .port1_led_speed                     (),                                
       .port1_led_status                    (),                                
       .port2_led_speed                     (),                                
       .port2_led_status                    (),                                
       .port3_led_speed                     (),                                
       .port3_led_status                    (),                                
       .port4_led_speed                     (),                                
       .port4_led_status                    (),                                
       .port5_led_speed                     (),                                
       .port5_led_status                    (),                                
       .port6_led_speed                     (),                                
       .port6_led_status                    (),                                
       .port7_led_speed                     (),                                
       .port7_led_status                    (),                                
       .port8_led_speed                     (),                                
       .port8_led_status                    (),                                
       .port9_led_speed                     (),                                
       .port9_led_status                    (),                                
       .port10_led_speed                    (),                                
       .port10_led_status                   (),                                
       .port11_led_speed                    (),                                
       .port11_led_status                   (),                                
       .port12_led_speed                    (),                                
       .port12_led_status                   (),                                
       .port13_led_speed                    (),                                
       .port13_led_status                   (),                                
       .port14_led_speed                    (),                  
       .port14_led_status                   (),                  
       .port15_led_speed                    (),                  
       .port15_led_status                   (),                  
       .port16_led_speed                    (),                  
       .port16_led_status                   (),                  
       .port17_led_speed                    (),                  
       .port17_led_status                   (),                  
       .port18_led_speed                    (),                  
       .port18_led_status                   (),                  
       .port19_led_speed                    (),                  
       .port19_led_status                   (),                  
       .p8_tx_lanes_stable                  (status_vector[3]),     
       .p8_rx_pcs_ready                     (status_vector[5]),     
       .o_p8_tx_pll_locked                  (status_vector[4]),     
       .o_p8_rx_pcs_fully_aligned           (),                     
       .o_p8_tx_ptp_ready                   (status_vector[6]),     
       .o_p8_rx_ptp_ready                   (status_vector[7]),     
       .o_p8_rx_ptp_offset_data_valid       (status_vector[8]),     
       .o_p8_tx_ptp_offset_data_valid       (status_vector[9]),     
       .subsystem_cold_rst_n                (hssi_cold_boot_reg[0]),   
       .subsystem_cold_rst_ack_n            (status_vector[0]),     
       .i_p8_tx_rst_n                       (system_reset_n),        
       .i_p8_rx_rst_n                       (system_reset_n),        
       .o_p8_rx_rst_ack_n                   (status_vector[1]),     
       .o_p8_tx_rst_ack_n                   (status_vector[2]),     
       .o_p8_ereset_n                       (),                     
       .i_clk_ref                           (ftile_clk_ref[0]),                
       .i_p8_clk_tx_tod                     (o_p8_clk_tx_div_clk),          
       .i_p8_clk_rx_tod                     (o_p8_clk_rec_div_clk),         
       .o_p8_clk_pll                        (o_clk_pll[0]),                 
       .o_p8_clk_tx_div                     (o_p8_clk_tx_div_clk),          
       .o_p8_clk_rec_div64                  (),                             
       .o_p8_clk_rec_div                    (o_p8_clk_rec_div_clk),         
       .i_p8_clk_ptp_sample                 (clk_ptp_sample_clk),           
       .o_p8_cdr_divclk                     (hssi_cdr_clk_out_sig)          
   );

  hssi_ss_50G_PAM4_anlt #(
     `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
    ) inst_port2_hssi_50G_PAM4_anlt (                                                     
        .app_ss_lite_clk                    (axi4lite_clk_clk),                           
        .app_ss_lite_areset_n               (axi4lite_rst_reset_n),                       
        .app_ss_lite_awaddr                 (axi4lite_hssi_1.awaddr),                     
        .app_ss_lite_awprot                 (axi4lite_hssi_1.awprot),                     
        .app_ss_lite_awvalid                (axi4lite_hssi_1.awvalid),                    
        .ss_app_lite_awready                (axi4lite_hssi_1.awready),                    
        .app_ss_lite_wdata                  (axi4lite_hssi_1.wdata),                      
        .app_ss_lite_wstrb                  (axi4lite_hssi_1.wstrb),                      
        .app_ss_lite_wvalid                 (axi4lite_hssi_1.wvalid),                     
        .ss_app_lite_wready                 (axi4lite_hssi_1.wready),                     
        .ss_app_lite_bresp                  (axi4lite_hssi_1.bresp),                      
        .ss_app_lite_bvalid                 (axi4lite_hssi_1.bvalid),                     
        .app_ss_lite_bready                 (axi4lite_hssi_1.bready),                     
        .app_ss_lite_araddr                 (axi4lite_hssi_1.araddr),                     
        .app_ss_lite_arprot                 (axi4lite_hssi_1.arprot),                     
        .app_ss_lite_arvalid                (axi4lite_hssi_1.arvalid),                    
        .ss_app_lite_arready                (axi4lite_hssi_1.arready),                    
        .ss_app_lite_rdata                  (axi4lite_hssi_1.rdata),                      
        .ss_app_lite_rvalid                 (axi4lite_hssi_1.rvalid),                     
        .app_ss_lite_rready                 (axi4lite_hssi_1.rready),                     
        .ss_app_lite_rresp                  (axi4lite_hssi_1.rresp),                      
        .p8_app_ss_st_tx_clk                (o_clk_pll[1]),                               
        .p8_app_ss_st_tx_areset_n           (system_reset_n),                             
        .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[1]),                    
        .p8_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[1]),                    
        .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[1] ),                    
        .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[1]),                     
        .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[1] ),                    
        .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[1]),              
        .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[1]),                 
        .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[1]),        
        .p8_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[1]),        
        .p8_app_ss_st_rx_clk                (o_clk_pll[1]),                               
        .p8_app_ss_st_rx_areset_n           (system_reset_n),                             
        .p8_ss_app_st_rx_tvalid             (hssi_ss_st_rx_tvalid[1]),                    
        .p8_ss_app_st_rx_tdata              (hssi_ss_st_rx_tdata[1]),                     
        .p8_ss_app_st_rx_tkeep              (hssi_ss_st_rx_tkeep[1]),                     
        .p8_ss_app_st_rx_tlast              (hssi_ss_st_rx_tlast[1]),                     
        .p8_ss_app_st_rx_tuser_client       (hssi_ss_st_rx_tuser_client[1]),              
        .p8_ss_app_st_rx_tuser_last_segment (hssi_ss_st_rx_tuser_last_segment[1]),        
        .p8_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx_tuser_sts[1]),                 
        .p8_app_ss_st_txtod_tvalid          (hssi_ptp_tx_tod_tvalid[1]),                  
        .p8_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod_tdata[1]),                   
        .p8_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod_tvalid[1]),                  
        .p8_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod_tdata[1]),                   
        .p8_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts_tvalid[1]),                
        .p8_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts_tdata[1]),                 
        .p8_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts_tvalid[1]),               
        .p8_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts_tdata[1]),                
        .i_p8_tx_pause                      (),                                           
        .i_p8_tx_pfc                        (8'd0),                       
        .o_p8_rx_pause                      (),                           
        .o_p8_rx_pfc                        (),                           
        .p8_tx_serial                       (ftile_tx_serial[1]),         
        .p8_tx_serial_n                     (ftile_tx_serial_n[1]),       
        .p8_rx_serial                       (ftile_rx_serial[1]),         
        .p8_rx_serial_n                     (ftile_rx_serial_n[1]),       
        .port0_led_speed                    (),                           
        .port0_led_status                   (),                           
        .port1_led_speed                    (),                           
        .port1_led_status                   (),                           
        .port2_led_speed                    (),                           
        .port2_led_status                   (),                           
        .port3_led_speed                    (),                           
        .port3_led_status                   (),                           
        .port4_led_speed                    (),                           
        .port4_led_status                   (),                           
        .port5_led_speed                    (),                           
        .port5_led_status                   (),                           
        .port6_led_speed                    (),                           
        .port6_led_status                   (),                           
        .port7_led_speed                    (),                           
        .port7_led_status                   (),                           
        .port8_led_speed                    (),                           
        .port8_led_status                   (),                           
        .port9_led_speed                    (),                           
        .port9_led_status                   (),                           
        .port10_led_speed                   (),                           
        .port10_led_status                  (),                           
        .port11_led_speed                   (),                           
        .port11_led_status                  (),                           
        .port12_led_speed                   (),                           
        .port12_led_status                  (),                           
        .port13_led_speed                   (),                           
        .port13_led_status                  (),                           
        .port14_led_speed                   (),                           
        .port14_led_status                  (),                           
        .port15_led_speed                   (),                           
        .port15_led_status                  (),                  
        .port16_led_speed                   (),                  
        .port16_led_status                  (),                  
        .port17_led_speed                   (),                  
        .port17_led_status                  (),                  
        .port18_led_speed                   (),                  
        .port18_led_status                  (),                  
        .port19_led_speed                   (),                  
        .port19_led_status                  (),                  
        .p8_tx_lanes_stable                 (status_vector[13]),   
        .p8_rx_pcs_ready                    (status_vector[15]),   
        .o_p8_tx_pll_locked                 (status_vector[14]),   
        .o_p8_rx_pcs_fully_aligned          (),                    
        .o_p8_tx_ptp_ready                  (status_vector[16]),   
        .o_p8_rx_ptp_ready                  (status_vector[17]),   
        .o_p8_rx_ptp_offset_data_valid      (status_vector[19]),   
        .o_p8_tx_ptp_offset_data_valid      (status_vector[18]),   
        .subsystem_cold_rst_n               (hssi_cold_boot_reg[1]),   
        .subsystem_cold_rst_ack_n           (status_vector[10]),     
        .i_p8_tx_rst_n                      (system_reset_n),               
        .i_p8_rx_rst_n                      (system_reset_n),               
        .o_p8_rx_rst_ack_n                  (status_vector[11]),           
        .o_p8_tx_rst_ack_n                  (status_vector[12]),           
        .o_p8_ereset_n                      (),                            
        .i_clk_ref                          (ftile_clk_ref[1]),                
        .i_p8_clk_tx_tod                    (o_p9_clk_tx_div_clk),         
        .i_p8_clk_rx_tod                    (o_p9_clk_rec_div_clk),        
        .o_p8_clk_pll                       (o_clk_pll[1]),                
        .o_p8_clk_tx_div                    (o_p9_clk_tx_div_clk),         
        .o_p8_clk_rec_div64                 (),                            
        .o_p8_clk_rec_div                   (o_p9_clk_rec_div_clk),        
        .i_p8_clk_ptp_sample                (clk_ptp_sample_clk_1),          
        .o_p8_cdr_divclk                    () 	
);


//50G PAM4 
`elsif FTILE_PTP_HSSI_50G_AUI1_PAM4  
  hssi_ss_50G_PAM4 #(
   `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port1_hssi_50G_PAM4 ( 
       .app_ss_lite_clk                    (axi4lite_clk_clk),          
       .app_ss_lite_areset_n               (axi4lite_rst_reset_n),      
       .app_ss_lite_awaddr                 (axi4lite_hssi.awaddr),      
       .app_ss_lite_awprot                 (axi4lite_hssi.awprot),      
       .app_ss_lite_awvalid                (axi4lite_hssi.awvalid),     
       .ss_app_lite_awready                (axi4lite_hssi.awready),     
       .app_ss_lite_wdata                  (axi4lite_hssi.wdata),       
       .app_ss_lite_wstrb                  (axi4lite_hssi.wstrb),       
       .app_ss_lite_wvalid                 (axi4lite_hssi.wvalid),      
       .ss_app_lite_wready                 (axi4lite_hssi.wready),      
       .ss_app_lite_bresp                  (axi4lite_hssi.bresp),       
       .ss_app_lite_bvalid                 (axi4lite_hssi.bvalid),      
       .app_ss_lite_bready                 (axi4lite_hssi.bready),      
       .app_ss_lite_araddr                 (axi4lite_hssi.araddr),      
       .app_ss_lite_arprot                 (axi4lite_hssi.arprot),      
       .app_ss_lite_arvalid                (axi4lite_hssi.arvalid),     
       .ss_app_lite_arready                (axi4lite_hssi.arready),     
       .ss_app_lite_rdata                  (axi4lite_hssi.rdata),       
       .ss_app_lite_rvalid                 (axi4lite_hssi.rvalid),      
       .app_ss_lite_rready                 (axi4lite_hssi.rready),      
       .ss_app_lite_rresp                  (axi4lite_hssi.rresp),       
       .p8_app_ss_st_tx_clk                (o_clk_pll[0]),              
       .p8_app_ss_st_tx_areset_n           (system_reset_n),            
       .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[0] ),  
       .p8_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[0] ),  
       .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[0] ),   
       .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[0] ),   
       .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[0] ),   
       .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[0]),         
       .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[0]),            
       .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[0]),   
       .p8_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[0]),   
       .p8_app_ss_st_rx_clk                 (o_clk_pll[0]),                         
       .p8_app_ss_st_rx_areset_n            (system_reset_n),                       
       .p8_ss_app_st_rx_tvalid              (hssi_ss_st_rx_tvalid[0]),              
       .p8_ss_app_st_rx_tdata               (hssi_ss_st_rx_tdata[0]),               
       .p8_ss_app_st_rx_tkeep               (hssi_ss_st_rx_tkeep[0]),               
       .p8_ss_app_st_rx_tlast               (hssi_ss_st_rx_tlast[0]),               
       .p8_ss_app_st_rx_tuser_client        (hssi_ss_st_rx_tuser_client[0]),        
       .p8_ss_app_st_rx_tuser_last_segment  (hssi_ss_st_rx_tuser_last_segment[0]),  
       .p8_ss_app_st_rx_tuser_sts           (hssi_ss_st_rx_tuser_sts[0]),           
       .p8_app_ss_st_txtod_tvalid           (hssi_ptp_tx_tod_tvalid[0]),            
       .p8_app_ss_st_txtod_tdata            (hssi_ptp_tx_tod_tdata[0]),             
       .p8_app_ss_st_rxtod_tvalid           (hssi_ptp_rx_tod_tvalid[0]),            
       .p8_app_ss_st_rxtod_tdata            (hssi_ptp_rx_tod_tdata[0]),             
       .p8_ss_app_st_txegrts0_tvalid        (hssi_ptp_tx_egrts_tvalid[0]),          
       .p8_ss_app_st_txegrts0_tdata         (hssi_ptp_tx_egrts_tdata[0]),           
       .p8_ss_app_st_rxingrts0_tvalid       (hssi_ptp_rx_ingrts_tvalid[0]),         
       .p8_ss_app_st_rxingrts0_tdata        (hssi_ptp_rx_ingrts_tdata[0]),         
       .i_p8_tx_pause                       (),                                    
       .i_p8_tx_pfc                         (8'd0),                            
       .o_p8_rx_pause                       (),                                
       .o_p8_rx_pfc                         (),                                
       .p8_tx_serial                        (ftile_tx_serial[0]),              
       .p8_tx_serial_n                      (ftile_tx_serial_n[0]),            
       .p8_rx_serial                        (ftile_rx_serial[0]),              
       .p8_rx_serial_n                      (ftile_rx_serial_n[0]),            
       .port0_led_speed                     (),                                
       .port0_led_status                    (),                                
       .port1_led_speed                     (),                                
       .port1_led_status                    (),                                
       .port2_led_speed                     (),                                
       .port2_led_status                    (),                                
       .port3_led_speed                     (),                                
       .port3_led_status                    (),                                
       .port4_led_speed                     (),                                
       .port4_led_status                    (),                                
       .port5_led_speed                     (),                                
       .port5_led_status                    (),                                
       .port6_led_speed                     (),                                
       .port6_led_status                    (),                                
       .port7_led_speed                     (),                                
       .port7_led_status                    (),                                
       .port8_led_speed                     (),                                
       .port8_led_status                    (),                                
       .port9_led_speed                     (),                                
       .port9_led_status                    (),                                
       .port10_led_speed                    (),                                
       .port10_led_status                   (),                                
       .port11_led_speed                    (),                                
       .port11_led_status                   (),                                
       .port12_led_speed                    (),                                
       .port12_led_status                   (),                                
       .port13_led_speed                    (),                                
       .port13_led_status                   (),                                
       .port14_led_speed                    (),                  
       .port14_led_status                   (),                  
       .port15_led_speed                    (),                  
       .port15_led_status                   (),                  
       .port16_led_speed                    (),                  
       .port16_led_status                   (),                  
       .port17_led_speed                    (),                  
       .port17_led_status                   (),                  
       .port18_led_speed                    (),                  
       .port18_led_status                   (),                  
       .port19_led_speed                    (),                  
       .port19_led_status                   (),                  
       .p8_tx_lanes_stable                  (status_vector[3]),     
       .p8_rx_pcs_ready                     (status_vector[5]),     
       .o_p8_tx_pll_locked                  (status_vector[4]),     
       .o_p8_rx_pcs_fully_aligned           (),                     
       .o_p8_tx_ptp_ready                   (status_vector[6]),     
       .o_p8_rx_ptp_ready                   (status_vector[7]),     
       .o_p8_rx_ptp_offset_data_valid       (status_vector[8]),     
       .o_p8_tx_ptp_offset_data_valid       (status_vector[9]),     
       .subsystem_cold_rst_n                (hssi_cold_boot_reg[0]),   
       .subsystem_cold_rst_ack_n            (status_vector[0]),     
       .i_p8_tx_rst_n                       (system_reset_n),        
       .i_p8_rx_rst_n                       (system_reset_n),        
       .o_p8_rx_rst_ack_n                   (status_vector[1]),     
       .o_p8_tx_rst_ack_n                   (status_vector[2]),     
       .o_p8_ereset_n                       (),                     
       .i_clk_ref                           (ftile_clk_ref[0]),                
       .i_p8_clk_tx_tod                     (o_p8_clk_tx_div_clk),          
       .i_p8_clk_rx_tod                     (o_p8_clk_rec_div_clk),         
       .o_p8_clk_pll                        (o_clk_pll[0]),                 
       .o_p8_clk_tx_div                     (o_p8_clk_tx_div_clk),          
       .o_p8_clk_rec_div64                  (),                             
       .o_p8_clk_rec_div                    (o_p8_clk_rec_div_clk),         
       .i_p8_clk_ptp_sample                 (clk_ptp_sample_clk),           
       .o_p8_cdr_divclk                     (hssi_cdr_clk_out_sig)          
   );

  hssi_ss_50G_PAM4 #(
     `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
    ) inst_port2_hssi_50G_PAM4 (                                                     
        .app_ss_lite_clk                    (axi4lite_clk_clk),                           
        .app_ss_lite_areset_n               (axi4lite_rst_reset_n),                       
        .app_ss_lite_awaddr                 (axi4lite_hssi_1.awaddr),                     
        .app_ss_lite_awprot                 (axi4lite_hssi_1.awprot),                     
        .app_ss_lite_awvalid                (axi4lite_hssi_1.awvalid),                    
        .ss_app_lite_awready                (axi4lite_hssi_1.awready),                    
        .app_ss_lite_wdata                  (axi4lite_hssi_1.wdata),                      
        .app_ss_lite_wstrb                  (axi4lite_hssi_1.wstrb),                      
        .app_ss_lite_wvalid                 (axi4lite_hssi_1.wvalid),                     
        .ss_app_lite_wready                 (axi4lite_hssi_1.wready),                     
        .ss_app_lite_bresp                  (axi4lite_hssi_1.bresp),                      
        .ss_app_lite_bvalid                 (axi4lite_hssi_1.bvalid),                     
        .app_ss_lite_bready                 (axi4lite_hssi_1.bready),                     
        .app_ss_lite_araddr                 (axi4lite_hssi_1.araddr),                     
        .app_ss_lite_arprot                 (axi4lite_hssi_1.arprot),                     
        .app_ss_lite_arvalid                (axi4lite_hssi_1.arvalid),                    
        .ss_app_lite_arready                (axi4lite_hssi_1.arready),                    
        .ss_app_lite_rdata                  (axi4lite_hssi_1.rdata),                      
        .ss_app_lite_rvalid                 (axi4lite_hssi_1.rvalid),                     
        .app_ss_lite_rready                 (axi4lite_hssi_1.rready),                     
        .ss_app_lite_rresp                  (axi4lite_hssi_1.rresp),                      
        .p8_app_ss_st_tx_clk                (o_clk_pll[1]),                               
        .p8_app_ss_st_tx_areset_n           (system_reset_n),                             
        .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[1]),                    
        .p8_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[1]),                    
        .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[1] ),                    
        .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[1]),                     
        .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[1] ),                    
        .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[1]),              
        .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[1]),                 
        .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[1]),        
        .p8_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[1]),        
        .p8_app_ss_st_rx_clk                (o_clk_pll[1]),                               
        .p8_app_ss_st_rx_areset_n           (system_reset_n),                             
        .p8_ss_app_st_rx_tvalid             (hssi_ss_st_rx_tvalid[1]),                    
        .p8_ss_app_st_rx_tdata              (hssi_ss_st_rx_tdata[1]),                     
        .p8_ss_app_st_rx_tkeep              (hssi_ss_st_rx_tkeep[1]),                     
        .p8_ss_app_st_rx_tlast              (hssi_ss_st_rx_tlast[1]),                     
        .p8_ss_app_st_rx_tuser_client       (hssi_ss_st_rx_tuser_client[1]),              
        .p8_ss_app_st_rx_tuser_last_segment (hssi_ss_st_rx_tuser_last_segment[1]),        
        .p8_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx_tuser_sts[1]),                 
        .p8_app_ss_st_txtod_tvalid          (hssi_ptp_tx_tod_tvalid[1]),                  
        .p8_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod_tdata[1]),                   
        .p8_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod_tvalid[1]),                  
        .p8_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod_tdata[1]),                   
        .p8_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts_tvalid[1]),                
        .p8_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts_tdata[1]),                 
        .p8_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts_tvalid[1]),               
        .p8_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts_tdata[1]),                
        .i_p8_tx_pause                      (),                                           
        .i_p8_tx_pfc                        (8'd0),                       
        .o_p8_rx_pause                      (),                           
        .o_p8_rx_pfc                        (),                           
        .p8_tx_serial                       (ftile_tx_serial[1]),         
        .p8_tx_serial_n                     (ftile_tx_serial_n[1]),       
        .p8_rx_serial                       (ftile_rx_serial[1]),         
        .p8_rx_serial_n                     (ftile_rx_serial_n[1]),       
        .port0_led_speed                    (),                           
        .port0_led_status                   (),                           
        .port1_led_speed                    (),                           
        .port1_led_status                   (),                           
        .port2_led_speed                    (),                           
        .port2_led_status                   (),                           
        .port3_led_speed                    (),                           
        .port3_led_status                   (),                           
        .port4_led_speed                    (),                           
        .port4_led_status                   (),                           
        .port5_led_speed                    (),                           
        .port5_led_status                   (),                           
        .port6_led_speed                    (),                           
        .port6_led_status                   (),                           
        .port7_led_speed                    (),                           
        .port7_led_status                   (),                           
        .port8_led_speed                    (),                           
        .port8_led_status                   (),                           
        .port9_led_speed                    (),                           
        .port9_led_status                   (),                           
        .port10_led_speed                   (),                           
        .port10_led_status                  (),                           
        .port11_led_speed                   (),                           
        .port11_led_status                  (),                           
        .port12_led_speed                   (),                           
        .port12_led_status                  (),                           
        .port13_led_speed                   (),                           
        .port13_led_status                  (),                           
        .port14_led_speed                   (),                           
        .port14_led_status                  (),                           
        .port15_led_speed                   (),                           
        .port15_led_status                  (),                  
        .port16_led_speed                   (),                  
        .port16_led_status                  (),                  
        .port17_led_speed                   (),                  
        .port17_led_status                  (),                  
        .port18_led_speed                   (),                  
        .port18_led_status                  (),                  
        .port19_led_speed                   (),                  
        .port19_led_status                  (),                  
        .p8_tx_lanes_stable                 (status_vector[13]),   
        .p8_rx_pcs_ready                    (status_vector[15]),   
        .o_p8_tx_pll_locked                 (status_vector[14]),   
        .o_p8_rx_pcs_fully_aligned          (),                    
        .o_p8_tx_ptp_ready                  (status_vector[16]),   
        .o_p8_rx_ptp_ready                  (status_vector[17]),   
        .o_p8_rx_ptp_offset_data_valid      (status_vector[19]),   
        .o_p8_tx_ptp_offset_data_valid      (status_vector[18]),   
        .subsystem_cold_rst_n               (hssi_cold_boot_reg[1]),   
        .subsystem_cold_rst_ack_n           (status_vector[10]),     
        .i_p8_tx_rst_n                      (system_reset_n),               
        .i_p8_rx_rst_n                      (system_reset_n),               
        .o_p8_rx_rst_ack_n                  (status_vector[11]),           
        .o_p8_tx_rst_ack_n                  (status_vector[12]),           
        .o_p8_ereset_n                      (),                            
        .i_clk_ref                          (ftile_clk_ref[1]),                
        .i_p8_clk_tx_tod                    (o_p9_clk_tx_div_clk),         
        .i_p8_clk_rx_tod                    (o_p9_clk_rec_div_clk),        
        .o_p8_clk_pll                       (o_clk_pll[1]),                
        .o_p8_clk_tx_div                    (o_p9_clk_tx_div_clk),         
        .o_p8_clk_rec_div64                 (),                            
        .o_p8_clk_rec_div                   (o_p9_clk_rec_div_clk),        
        .i_p8_clk_ptp_sample                (clk_ptp_sample_clk_1),          
        .o_p8_cdr_divclk                    () 	
);

//100G PAM4 ANLT
`elsif FTILE_PTP_HSSI_100G_GAUI2_PAM4_ANLT 
  hssi_ss_100G_PAM4_anlt #(
      `ifdef SIM_MODE
        .SIM_MODE                      (1'b1),
      `else
        .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port1_hssi_100G_PAM4_anlt ( 
        .app_ss_lite_clk                    (axi4lite_clk_clk),                         
        .app_ss_lite_areset_n               (axi4lite_rst_reset_n),                     
        .app_ss_lite_awaddr                 (axi4lite_hssi.awaddr),                     
        .app_ss_lite_awprot                 (axi4lite_hssi.awprot),                     
        .app_ss_lite_awvalid                (axi4lite_hssi.awvalid),                    
        .ss_app_lite_awready                (axi4lite_hssi.awready),                    
        .app_ss_lite_wdata                  (axi4lite_hssi.wdata),                      
        .app_ss_lite_wstrb                  (axi4lite_hssi.wstrb),                      
        .app_ss_lite_wvalid                 (axi4lite_hssi.wvalid),                     
        .ss_app_lite_wready                 (axi4lite_hssi.wready),                     
        .ss_app_lite_bresp                  (axi4lite_hssi.bresp),                      
        .ss_app_lite_bvalid                 (axi4lite_hssi.bvalid),                     
        .app_ss_lite_bready                 (axi4lite_hssi.bready),                     
        .app_ss_lite_araddr                 (axi4lite_hssi.araddr),                     
        .app_ss_lite_arprot                 (axi4lite_hssi.arprot),                     
        .app_ss_lite_arvalid                (axi4lite_hssi.arvalid),                    
        .ss_app_lite_arready                (axi4lite_hssi.arready),                    
        .ss_app_lite_rdata                  (axi4lite_hssi.rdata),                      
        .ss_app_lite_rvalid                 (axi4lite_hssi.rvalid),                     
        .app_ss_lite_rready                 (axi4lite_hssi.rready),                     
        .ss_app_lite_rresp                  (axi4lite_hssi.rresp),                      
        .p8_app_ss_st_tx_clk                (o_clk_pll[0]),                             
        .p8_app_ss_st_tx_areset_n           (system_reset_n),                           
        .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[0] ),                 
        .p8_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[0] ),                 
        .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[0] ),                  
        .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[0] ),                  
        .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[0] ),                  
        .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[0]),            
        .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[0]),               
        .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[0]),      
        .p8_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[0]),      
        .p8_app_ss_st_rx_clk                 (o_clk_pll[0]),                            
        .p8_app_ss_st_rx_areset_n            (system_reset_n),                          
        .p8_ss_app_st_rx_tvalid              (hssi_ss_st_rx_tvalid[0]),                 
        .p8_ss_app_st_rx_tdata               (hssi_ss_st_rx_tdata[0]),                  
        .p8_ss_app_st_rx_tkeep               (hssi_ss_st_rx_tkeep[0]),                  
        .p8_ss_app_st_rx_tlast               (hssi_ss_st_rx_tlast[0]),                  
        .p8_ss_app_st_rx_tuser_client        (hssi_ss_st_rx_tuser_client[0]),           
        .p8_ss_app_st_rx_tuser_last_segment  (hssi_ss_st_rx_tuser_last_segment[0]),     
        .p8_ss_app_st_rx_tuser_sts           (hssi_ss_st_rx_tuser_sts[0]),              
        .p8_app_ss_st_txtod_tvalid           (hssi_ptp_tx_tod_tvalid[0]),               
        .p8_app_ss_st_txtod_tdata            (hssi_ptp_tx_tod_tdata[0]),                
        .p8_app_ss_st_rxtod_tvalid           (hssi_ptp_rx_tod_tvalid[0]),               
        .p8_app_ss_st_rxtod_tdata            (hssi_ptp_rx_tod_tdata[0]),                
        .p8_ss_app_st_txegrts0_tvalid        (hssi_ptp_tx_egrts_tvalid[0]),             
        .p8_ss_app_st_txegrts0_tdata         (hssi_ptp_tx_egrts_tdata[0]),              
        .p8_ss_app_st_rxingrts0_tvalid       (hssi_ptp_rx_ingrts_tvalid[0]),            
        .p8_ss_app_st_rxingrts0_tdata        (hssi_ptp_rx_ingrts_tdata[0]),             
        .i_p8_tx_pause                       (),                             
        .i_p8_tx_pfc                         (8'd0),                         
        .o_p8_rx_pause                       (),                             
        .o_p8_rx_pfc                         (),                             
        .p8_tx_serial                        (ftile_tx_serial[1:0]),         
        .p8_tx_serial_n                      (ftile_tx_serial_n[1:0]),       
        .p8_rx_serial                        (ftile_rx_serial[1:0]),         
        .p8_rx_serial_n                      (ftile_rx_serial_n[1:0]),       
        .port0_led_speed                     (),                             
        .port0_led_status                    (),                             
        .port1_led_speed                     (),                             
        .port1_led_status                    (),                             
        .port2_led_speed                     (),                             
        .port2_led_status                    (),                             
        .port3_led_speed                     (),                             
        .port3_led_status                    (),                             
        .port4_led_speed                     (),                             
        .port4_led_status                    (),                             
        .port5_led_speed                     (),                             
        .port5_led_status                    (),                             
        .port6_led_speed                     (),                             
        .port6_led_status                    (),                             
        .port7_led_speed                     (),                             
        .port7_led_status                    (),                             
        .port8_led_speed                     (),                             
        .port8_led_status                    (),                             
        .port9_led_speed                     (),                             
        .port9_led_status                    (),                             
        .port10_led_speed                    (),                             
        .port10_led_status                   (),                             
        .port11_led_speed                    (),                             
        .port11_led_status                   (),                             
        .port12_led_speed                    (),                             
        .port12_led_status                   (),                             
        .port13_led_speed                    (),                             
        .port13_led_status                   (),                             
        .port14_led_speed                    (),                             
        .port14_led_status                   (),                             
        .port15_led_speed                    (),                  
        .port15_led_status                   (),                  
        .port16_led_speed                    (),                  
        .port16_led_status                   (),                  
        .port17_led_speed                    (),                  
        .port17_led_status                   (),                  
        .port18_led_speed                    (),                  
        .port18_led_status                   (),                  
        .port19_led_speed                    (),                  
        .port19_led_status                   (),                  
        .p8_tx_lanes_stable                  (status_vector[3]),     
        .p8_rx_pcs_ready                     (status_vector[5]),     
        .o_p8_tx_pll_locked                  (status_vector[4]),     
        .o_p8_rx_pcs_fully_aligned           (),                     
        .o_p8_tx_ptp_ready                   (status_vector[6]),     
        .o_p8_rx_ptp_ready                   (status_vector[7]),     
        .o_p8_rx_ptp_offset_data_valid       (status_vector[8]),     
        .o_p8_tx_ptp_offset_data_valid       (status_vector[9]),     
        .subsystem_cold_rst_n                (hssi_cold_boot_reg[0]),   
        .subsystem_cold_rst_ack_n            (status_vector[0]),     
        .i_p8_tx_rst_n                       (system_reset_n),        
        .i_p8_rx_rst_n                       (system_reset_n),        
        .o_p8_rx_rst_ack_n                   (status_vector[1]),     
        .o_p8_tx_rst_ack_n                   (status_vector[2]),     
        .o_p8_ereset_n                       (),                     
        .i_clk_ref                           (ftile_clk_ref[0]),                
        .i_p8_clk_tx_tod                     (o_p8_clk_tx_div_clk),          
        .i_p8_clk_rx_tod                     (o_p8_clk_rec_div_clk),         
        .o_p8_clk_pll                        (o_clk_pll[0]),                 
        .o_p8_clk_tx_div                     (o_p8_clk_tx_div_clk),          
        .o_p8_clk_rec_div64                  (),                             
        .o_p8_clk_rec_div                    (o_p8_clk_rec_div_clk),         
        .i_p8_clk_ptp_sample                 (clk_ptp_sample_clk),           
        .o_p8_cdr_divclk                     (hssi_cdr_clk_out_sig)          
   );

  hssi_ss_100G_PAM4_anlt #(
      `ifdef SIM_MODE
        .SIM_MODE                      (1'b1),
      `else
        .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port2_hssi_100G_PAM4_anlt (
         .app_ss_lite_clk                    (axi4lite_clk_clk),                
         .app_ss_lite_areset_n               (axi4lite_rst_reset_n),            
         .app_ss_lite_awaddr                 (axi4lite_hssi_1.awaddr),          
         .app_ss_lite_awprot                 (axi4lite_hssi_1.awprot),          
         .app_ss_lite_awvalid                (axi4lite_hssi_1.awvalid),         
         .ss_app_lite_awready                (axi4lite_hssi_1.awready),         
         .app_ss_lite_wdata                  (axi4lite_hssi_1.wdata),           
         .app_ss_lite_wstrb                  (axi4lite_hssi_1.wstrb),           
         .app_ss_lite_wvalid                 (axi4lite_hssi_1.wvalid),          
         .ss_app_lite_wready                 (axi4lite_hssi_1.wready),          
         .ss_app_lite_bresp                  (axi4lite_hssi_1.bresp),           
         .ss_app_lite_bvalid                 (axi4lite_hssi_1.bvalid),          
         .app_ss_lite_bready                 (axi4lite_hssi_1.bready),          
         .app_ss_lite_araddr                 (axi4lite_hssi_1.araddr),          
         .app_ss_lite_arprot                 (axi4lite_hssi_1.arprot),          
         .app_ss_lite_arvalid                (axi4lite_hssi_1.arvalid),         
         .ss_app_lite_arready                (axi4lite_hssi_1.arready),         
         .ss_app_lite_rdata                  (axi4lite_hssi_1.rdata),           
         .ss_app_lite_rvalid                 (axi4lite_hssi_1.rvalid),          
         .app_ss_lite_rready                 (axi4lite_hssi_1.rready),          
         .ss_app_lite_rresp                  (axi4lite_hssi_1.rresp),           
         .p8_app_ss_st_tx_clk                (o_clk_pll[1]),                    
         .p8_app_ss_st_tx_areset_n           (system_reset_n),                  
         .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[1]),         
         .p8_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[1]),         
         .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[1] ),         
         .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[1]),          
         .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[1] ),         
         .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[1]),   
         .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[1]),      
         .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[1]),  
         .p8_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[1]),  
         .p8_app_ss_st_rx_clk                (o_clk_pll[1]),                         
         .p8_app_ss_st_rx_areset_n           (system_reset_n),                       
         .p8_ss_app_st_rx_tvalid             (hssi_ss_st_rx_tvalid[1]),              
         .p8_ss_app_st_rx_tdata              (hssi_ss_st_rx_tdata[1]),               
         .p8_ss_app_st_rx_tkeep              (hssi_ss_st_rx_tkeep[1]),               
         .p8_ss_app_st_rx_tlast              (hssi_ss_st_rx_tlast[1]),               
         .p8_ss_app_st_rx_tuser_client       (hssi_ss_st_rx_tuser_client[1]),        
         .p8_ss_app_st_rx_tuser_last_segment (hssi_ss_st_rx_tuser_last_segment[1]),  
         .p8_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx_tuser_sts[1]),           
         .p8_app_ss_st_txtod_tvalid          (hssi_ptp_tx_tod_tvalid[1]),            
         .p8_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod_tdata[1]),             
         .p8_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod_tvalid[1]),            
         .p8_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod_tdata[1]),             
         .p8_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts_tvalid[1]),          
         .p8_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts_tdata[1]),            
         .p8_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts_tvalid[1]),          
         .p8_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts_tdata[1]),           
         .i_p8_tx_pause                      (),                                      
         .i_p8_tx_pfc                        (8'd0),                                  
         .o_p8_rx_pause                      (),                                      
         .o_p8_rx_pfc                        (),                                      
         .p8_tx_serial                       (ftile_tx_serial[3:2]),                  
         .p8_tx_serial_n                     (ftile_tx_serial_n[3:2]),                
         .p8_rx_serial                       (ftile_rx_serial[3:2]),                  
         .p8_rx_serial_n                     (ftile_rx_serial_n[3:2]),                
         .port0_led_speed                    (),                                      
         .port0_led_status                   (),                                      
         .port1_led_speed                    (),                                      
         .port1_led_status                   (),                                      
         .port2_led_speed                    (),                                      
         .port2_led_status                   (),                                      
         .port3_led_speed                    (),                                      
         .port3_led_status                   (),                                      
         .port4_led_speed                    (),                                      
         .port4_led_status                   (),                                      
         .port5_led_speed                    (),                                      
         .port5_led_status                   (),                                      
         .port6_led_speed                    (),                                      
         .port6_led_status                   (),                                      
         .port7_led_speed                    (),                                      
         .port7_led_status                   (),                                      
         .port8_led_speed                    (),                                      
         .port8_led_status                   (),                                      
         .port9_led_speed                    (),                                      
         .port9_led_status                   (),                                      
         .port10_led_speed                   (),                                      
         .port10_led_status                  (),                                      
         .port11_led_speed                   (),                                      
         .port11_led_status                  (),                                      
         .port12_led_speed                   (),                                      
         .port12_led_status                  (),                                      
         .port13_led_speed                   (),                                      
         .port13_led_status                  (),                                      
         .port14_led_speed                   (),                                      
         .port14_led_status                  (),                  
         .port15_led_speed                   (),                  
         .port15_led_status                  (),                  
         .port16_led_speed                   (),                  
         .port16_led_status                  (),                  
         .port17_led_speed                   (),                  
         .port17_led_status                  (),                  
         .port18_led_speed                   (),                  
         .port18_led_status                  (),                  
         .port19_led_speed                   (),                  
         .port19_led_status                  (),                  
         .p8_tx_lanes_stable                 (status_vector[13]),   
         .p8_rx_pcs_ready                    (status_vector[15]),   
         .o_p8_tx_pll_locked                 (status_vector[14]),   
         .o_p8_rx_pcs_fully_aligned          (),                    
         .o_p8_tx_ptp_ready                  (status_vector[16]),   
         .o_p8_rx_ptp_ready                  (status_vector[17]),   
         .o_p8_rx_ptp_offset_data_valid      (status_vector[19]),   
         .o_p8_tx_ptp_offset_data_valid      (status_vector[18]),   
         .subsystem_cold_rst_n               (hssi_cold_boot_reg[1]),   
         .subsystem_cold_rst_ack_n           (status_vector[10]),     
         .i_p8_tx_rst_n                      (system_reset_n),               
         .i_p8_rx_rst_n                      (system_reset_n),               
         .o_p8_rx_rst_ack_n                  (status_vector[11]),           
         .o_p8_tx_rst_ack_n                  (status_vector[12]),           
         .o_p8_ereset_n                      (),                            
         .i_clk_ref                          (ftile_clk_ref[1]),                
         .i_p8_clk_tx_tod                    (o_p9_clk_tx_div_clk),         
         .i_p8_clk_rx_tod                    (o_p9_clk_rec_div_clk),        
         .o_p8_clk_pll                       (o_clk_pll[1]),                
         .o_p8_clk_tx_div                    (o_p9_clk_tx_div_clk),         
         .o_p8_clk_rec_div64                 (),                            
         .o_p8_clk_rec_div                   (o_p9_clk_rec_div_clk),        
         .i_p8_clk_ptp_sample                (clk_ptp_sample_clk_1),          
         .o_p8_cdr_divclk                    () 	
);

//100G PAM4 
`elsif FTILE_PTP_HSSI_100G_GAUI2_PAM4 
  hssi_ss_100G_PAM4 #(
      `ifdef SIM_MODE
        .SIM_MODE                      (1'b1),
      `else
        .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port1_hssi_100G_PAM4 ( 
        .app_ss_lite_clk                    (axi4lite_clk_clk),                         
        .app_ss_lite_areset_n               (axi4lite_rst_reset_n),                     
        .app_ss_lite_awaddr                 (axi4lite_hssi.awaddr),                     
        .app_ss_lite_awprot                 (axi4lite_hssi.awprot),                     
        .app_ss_lite_awvalid                (axi4lite_hssi.awvalid),                    
        .ss_app_lite_awready                (axi4lite_hssi.awready),                    
        .app_ss_lite_wdata                  (axi4lite_hssi.wdata),                      
        .app_ss_lite_wstrb                  (axi4lite_hssi.wstrb),                      
        .app_ss_lite_wvalid                 (axi4lite_hssi.wvalid),                     
        .ss_app_lite_wready                 (axi4lite_hssi.wready),                     
        .ss_app_lite_bresp                  (axi4lite_hssi.bresp),                      
        .ss_app_lite_bvalid                 (axi4lite_hssi.bvalid),                     
        .app_ss_lite_bready                 (axi4lite_hssi.bready),                     
        .app_ss_lite_araddr                 (axi4lite_hssi.araddr),                     
        .app_ss_lite_arprot                 (axi4lite_hssi.arprot),                     
        .app_ss_lite_arvalid                (axi4lite_hssi.arvalid),                    
        .ss_app_lite_arready                (axi4lite_hssi.arready),                    
        .ss_app_lite_rdata                  (axi4lite_hssi.rdata),                      
        .ss_app_lite_rvalid                 (axi4lite_hssi.rvalid),                     
        .app_ss_lite_rready                 (axi4lite_hssi.rready),                     
        .ss_app_lite_rresp                  (axi4lite_hssi.rresp),                      
        .p8_app_ss_st_tx_clk                (o_clk_pll[0]),                             
        .p8_app_ss_st_tx_areset_n           (system_reset_n),                           
        .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[0] ),                 
        .p8_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[0] ),                 
        .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[0] ),                  
        .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[0] ),                  
        .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[0] ),                  
        .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[0]),            
        .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[0]),               
        .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[0]),      
        .p8_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[0]),      
        .p8_app_ss_st_rx_clk                 (o_clk_pll[0]),                            
        .p8_app_ss_st_rx_areset_n            (system_reset_n),                          
        .p8_ss_app_st_rx_tvalid              (hssi_ss_st_rx_tvalid[0]),                 
        .p8_ss_app_st_rx_tdata               (hssi_ss_st_rx_tdata[0]),                  
        .p8_ss_app_st_rx_tkeep               (hssi_ss_st_rx_tkeep[0]),                  
        .p8_ss_app_st_rx_tlast               (hssi_ss_st_rx_tlast[0]),                  
        .p8_ss_app_st_rx_tuser_client        (hssi_ss_st_rx_tuser_client[0]),           
        .p8_ss_app_st_rx_tuser_last_segment  (hssi_ss_st_rx_tuser_last_segment[0]),     
        .p8_ss_app_st_rx_tuser_sts           (hssi_ss_st_rx_tuser_sts[0]),              
        .p8_app_ss_st_txtod_tvalid           (hssi_ptp_tx_tod_tvalid[0]),               
        .p8_app_ss_st_txtod_tdata            (hssi_ptp_tx_tod_tdata[0]),                
        .p8_app_ss_st_rxtod_tvalid           (hssi_ptp_rx_tod_tvalid[0]),               
        .p8_app_ss_st_rxtod_tdata            (hssi_ptp_rx_tod_tdata[0]),                
        .p8_ss_app_st_txegrts0_tvalid        (hssi_ptp_tx_egrts_tvalid[0]),             
        .p8_ss_app_st_txegrts0_tdata         (hssi_ptp_tx_egrts_tdata[0]),              
        .p8_ss_app_st_rxingrts0_tvalid       (hssi_ptp_rx_ingrts_tvalid[0]),            
        .p8_ss_app_st_rxingrts0_tdata        (hssi_ptp_rx_ingrts_tdata[0]),             
        .i_p8_tx_pause                       (),                             
        .i_p8_tx_pfc                         (8'd0),                         
        .o_p8_rx_pause                       (),                             
        .o_p8_rx_pfc                         (),                             
        .p8_tx_serial                        (ftile_tx_serial[1:0]),         
        .p8_tx_serial_n                      (ftile_tx_serial_n[1:0]),       
        .p8_rx_serial                        (ftile_rx_serial[1:0]),         
        .p8_rx_serial_n                      (ftile_rx_serial_n[1:0]),       
        .port0_led_speed                     (),                             
        .port0_led_status                    (),                             
        .port1_led_speed                     (),                             
        .port1_led_status                    (),                             
        .port2_led_speed                     (),                             
        .port2_led_status                    (),                             
        .port3_led_speed                     (),                             
        .port3_led_status                    (),                             
        .port4_led_speed                     (),                             
        .port4_led_status                    (),                             
        .port5_led_speed                     (),                             
        .port5_led_status                    (),                             
        .port6_led_speed                     (),                             
        .port6_led_status                    (),                             
        .port7_led_speed                     (),                             
        .port7_led_status                    (),                             
        .port8_led_speed                     (),                             
        .port8_led_status                    (),                             
        .port9_led_speed                     (),                             
        .port9_led_status                    (),                             
        .port10_led_speed                    (),                             
        .port10_led_status                   (),                             
        .port11_led_speed                    (),                             
        .port11_led_status                   (),                             
        .port12_led_speed                    (),                             
        .port12_led_status                   (),                             
        .port13_led_speed                    (),                             
        .port13_led_status                   (),                             
        .port14_led_speed                    (),                             
        .port14_led_status                   (),                             
        .port15_led_speed                    (),                  
        .port15_led_status                   (),                  
        .port16_led_speed                    (),                  
        .port16_led_status                   (),                  
        .port17_led_speed                    (),                  
        .port17_led_status                   (),                  
        .port18_led_speed                    (),                  
        .port18_led_status                   (),                  
        .port19_led_speed                    (),                  
        .port19_led_status                   (),                  
        .p8_tx_lanes_stable                  (status_vector[3]),     
        .p8_rx_pcs_ready                     (status_vector[5]),     
        .o_p8_tx_pll_locked                  (status_vector[4]),     
        .o_p8_rx_pcs_fully_aligned           (),                     
        .o_p8_tx_ptp_ready                   (status_vector[6]),     
        .o_p8_rx_ptp_ready                   (status_vector[7]),     
        .o_p8_rx_ptp_offset_data_valid       (status_vector[8]),     
        .o_p8_tx_ptp_offset_data_valid       (status_vector[9]),     
        .subsystem_cold_rst_n                (hssi_cold_boot_reg[0]),   
        .subsystem_cold_rst_ack_n            (status_vector[0]),     
        .i_p8_tx_rst_n                       (system_reset_n),        
        .i_p8_rx_rst_n                       (system_reset_n),        
        .o_p8_rx_rst_ack_n                   (status_vector[1]),     
        .o_p8_tx_rst_ack_n                   (status_vector[2]),     
        .o_p8_ereset_n                       (),                     
        .i_clk_ref                           (ftile_clk_ref[0]),                
        .i_p8_clk_tx_tod                     (o_p8_clk_tx_div_clk),          
        .i_p8_clk_rx_tod                     (o_p8_clk_rec_div_clk),         
        .o_p8_clk_pll                        (o_clk_pll[0]),                 
        .o_p8_clk_tx_div                     (o_p8_clk_tx_div_clk),          
        .o_p8_clk_rec_div64                  (),                             
        .o_p8_clk_rec_div                    (o_p8_clk_rec_div_clk),         
        .i_p8_clk_ptp_sample                 (clk_ptp_sample_clk),           
        .o_p8_cdr_divclk                     (hssi_cdr_clk_out_sig)          
   );

  hssi_ss_100G_PAM4 #(
      `ifdef SIM_MODE
        .SIM_MODE                      (1'b1),
      `else
        .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
     ) inst_port2_hssi_100G_PAM4 (
         .app_ss_lite_clk                    (axi4lite_clk_clk),                
         .app_ss_lite_areset_n               (axi4lite_rst_reset_n),            
         .app_ss_lite_awaddr                 (axi4lite_hssi_1.awaddr),          
         .app_ss_lite_awprot                 (axi4lite_hssi_1.awprot),          
         .app_ss_lite_awvalid                (axi4lite_hssi_1.awvalid),         
         .ss_app_lite_awready                (axi4lite_hssi_1.awready),         
         .app_ss_lite_wdata                  (axi4lite_hssi_1.wdata),           
         .app_ss_lite_wstrb                  (axi4lite_hssi_1.wstrb),           
         .app_ss_lite_wvalid                 (axi4lite_hssi_1.wvalid),          
         .ss_app_lite_wready                 (axi4lite_hssi_1.wready),          
         .ss_app_lite_bresp                  (axi4lite_hssi_1.bresp),           
         .ss_app_lite_bvalid                 (axi4lite_hssi_1.bvalid),          
         .app_ss_lite_bready                 (axi4lite_hssi_1.bready),          
         .app_ss_lite_araddr                 (axi4lite_hssi_1.araddr),          
         .app_ss_lite_arprot                 (axi4lite_hssi_1.arprot),          
         .app_ss_lite_arvalid                (axi4lite_hssi_1.arvalid),         
         .ss_app_lite_arready                (axi4lite_hssi_1.arready),         
         .ss_app_lite_rdata                  (axi4lite_hssi_1.rdata),           
         .ss_app_lite_rvalid                 (axi4lite_hssi_1.rvalid),          
         .app_ss_lite_rready                 (axi4lite_hssi_1.rready),          
         .ss_app_lite_rresp                  (axi4lite_hssi_1.rresp),           
         .p8_app_ss_st_tx_clk                (o_clk_pll[1]),                    
         .p8_app_ss_st_tx_areset_n           (system_reset_n),                  
         .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[1]),         
         .p8_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[1]),         
         .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[1] ),         
         .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[1]),          
         .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[1] ),         
         .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[1]),   
         .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[1]),      
         .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[1]),  
         .p8_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[1]),  
         .p8_app_ss_st_rx_clk                (o_clk_pll[1]),                         
         .p8_app_ss_st_rx_areset_n           (system_reset_n),                       
         .p8_ss_app_st_rx_tvalid             (hssi_ss_st_rx_tvalid[1]),              
         .p8_ss_app_st_rx_tdata              (hssi_ss_st_rx_tdata[1]),               
         .p8_ss_app_st_rx_tkeep              (hssi_ss_st_rx_tkeep[1]),               
         .p8_ss_app_st_rx_tlast              (hssi_ss_st_rx_tlast[1]),               
         .p8_ss_app_st_rx_tuser_client       (hssi_ss_st_rx_tuser_client[1]),        
         .p8_ss_app_st_rx_tuser_last_segment (hssi_ss_st_rx_tuser_last_segment[1]),  
         .p8_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx_tuser_sts[1]),           
         .p8_app_ss_st_txtod_tvalid          (hssi_ptp_tx_tod_tvalid[1]),            
         .p8_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod_tdata[1]),             
         .p8_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod_tvalid[1]),            
         .p8_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod_tdata[1]),             
         .p8_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts_tvalid[1]),          
         .p8_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts_tdata[1]),            
         .p8_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts_tvalid[1]),          
         .p8_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts_tdata[1]),           
         .i_p8_tx_pause                      (),                                      
         .i_p8_tx_pfc                        (8'd0),                                  
         .o_p8_rx_pause                      (),                                      
         .o_p8_rx_pfc                        (),                                      
         .p8_tx_serial                       (ftile_tx_serial[3:2]),                  
         .p8_tx_serial_n                     (ftile_tx_serial_n[3:2]),                
         .p8_rx_serial                       (ftile_rx_serial[3:2]),                  
         .p8_rx_serial_n                     (ftile_rx_serial_n[3:2]),                
         .port0_led_speed                    (),                                      
         .port0_led_status                   (),                                      
         .port1_led_speed                    (),                                      
         .port1_led_status                   (),                                      
         .port2_led_speed                    (),                                      
         .port2_led_status                   (),                                      
         .port3_led_speed                    (),                                      
         .port3_led_status                   (),                                      
         .port4_led_speed                    (),                                      
         .port4_led_status                   (),                                      
         .port5_led_speed                    (),                                      
         .port5_led_status                   (),                                      
         .port6_led_speed                    (),                                      
         .port6_led_status                   (),                                      
         .port7_led_speed                    (),                                      
         .port7_led_status                   (),                                      
         .port8_led_speed                    (),                                      
         .port8_led_status                   (),                                      
         .port9_led_speed                    (),                                      
         .port9_led_status                   (),                                      
         .port10_led_speed                   (),                                      
         .port10_led_status                  (),                                      
         .port11_led_speed                   (),                                      
         .port11_led_status                  (),                                      
         .port12_led_speed                   (),                                      
         .port12_led_status                  (),                                      
         .port13_led_speed                   (),                                      
         .port13_led_status                  (),                                      
         .port14_led_speed                   (),                                      
         .port14_led_status                  (),                  
         .port15_led_speed                   (),                  
         .port15_led_status                  (),                  
         .port16_led_speed                   (),                  
         .port16_led_status                  (),                  
         .port17_led_speed                   (),                  
         .port17_led_status                  (),                  
         .port18_led_speed                   (),                  
         .port18_led_status                  (),                  
         .port19_led_speed                   (),                  
         .port19_led_status                  (),                  
         .p8_tx_lanes_stable                 (status_vector[13]),   
         .p8_rx_pcs_ready                    (status_vector[15]),   
         .o_p8_tx_pll_locked                 (status_vector[14]),   
         .o_p8_rx_pcs_fully_aligned          (),                    
         .o_p8_tx_ptp_ready                  (status_vector[16]),   
         .o_p8_rx_ptp_ready                  (status_vector[17]),   
         .o_p8_rx_ptp_offset_data_valid      (status_vector[19]),   
         .o_p8_tx_ptp_offset_data_valid      (status_vector[18]),   
         .subsystem_cold_rst_n               (hssi_cold_boot_reg[1]),   
         .subsystem_cold_rst_ack_n           (status_vector[10]),     
         .i_p8_tx_rst_n                      (system_reset_n),               
         .i_p8_rx_rst_n                      (system_reset_n),               
         .o_p8_rx_rst_ack_n                  (status_vector[11]),           
         .o_p8_tx_rst_ack_n                  (status_vector[12]),           
         .o_p8_ereset_n                      (),                            
         .i_clk_ref                          (ftile_clk_ref[1]),                
         .i_p8_clk_tx_tod                    (o_p9_clk_tx_div_clk),         
         .i_p8_clk_rx_tod                    (o_p9_clk_rec_div_clk),        
         .o_p8_clk_pll                       (o_clk_pll[1]),                
         .o_p8_clk_tx_div                    (o_p9_clk_tx_div_clk),         
         .o_p8_clk_rec_div64                 (),                            
         .o_p8_clk_rec_div                   (o_p9_clk_rec_div_clk),        
         .i_p8_clk_ptp_sample                (clk_ptp_sample_clk_1),          
         .o_p8_cdr_divclk                    () 	
);

`endif


always@(*) begin


  if (HSSI_NUM_OF_SEG == 4) begin
     hssi_ss_st_tx_tuser_client[1]       = {axi_st_tx_tuser_client_o[1][0],axi_st_tx_tuser_client_o[1][0],axi_st_tx_tuser_client_o[1][0],axi_st_tx_tuser_client_o[1][0]};
     hssi_axi_st_rx_tuser_client_i[1][0][6:0] = ms_hssi_ss_st_rx_tuser_client[1][6:0];
     hssi_axi_st_rx_tuser_sts_i[1][0][4:0]    = ms_hssi_ss_st_rx_tuser_sts[1][4:0]; 
     
     hssi_ss_st_tx_tuser_client[0]       = {axi_st_tx_tuser_client_o[0][0],axi_st_tx_tuser_client_o[0][0],axi_st_tx_tuser_client_o[0][0],axi_st_tx_tuser_client_o[0][0]};
     hssi_axi_st_rx_tuser_client_i[0][0][6:0] = ms_hssi_ss_st_rx_tuser_client[0][6:0];
     hssi_axi_st_rx_tuser_sts_i[0][0][4:0]    = ms_hssi_ss_st_rx_tuser_sts[0][4:0]; 
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[0][3][4:0] = dma_axi_st_rx_tuser_sts[0][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[0][2][4:0] = dma_axi_st_rx_tuser_sts[0][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[0][1][4:0] = dma_axi_st_rx_tuser_sts[0][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[0][0][4:0] = dma_axi_st_rx_tuser_sts[0][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[1][3][4:0] = dma_axi_st_rx_tuser_sts[1][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[1][2][4:0] = dma_axi_st_rx_tuser_sts[1][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[1][1][4:0] = dma_axi_st_rx_tuser_sts[1][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[1][0][4:0] = dma_axi_st_rx_tuser_sts[1][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[2][3][4:0] = dma_axi_st_rx_tuser_sts[2][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[2][2][4:0] = dma_axi_st_rx_tuser_sts[2][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[2][1][4:0] = dma_axi_st_rx_tuser_sts[2][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[2][0][4:0] = dma_axi_st_rx_tuser_sts[2][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[3][3][4:0] = dma_axi_st_rx_tuser_sts[3][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[3][2][4:0] = dma_axi_st_rx_tuser_sts[3][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[3][1][4:0] = dma_axi_st_rx_tuser_sts[3][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[3][0][4:0] = dma_axi_st_rx_tuser_sts[3][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[4][3][4:0] = dma_axi_st_rx_tuser_sts[4][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[4][2][4:0] = dma_axi_st_rx_tuser_sts[4][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[4][1][4:0] = dma_axi_st_rx_tuser_sts[4][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[4][0][4:0] = dma_axi_st_rx_tuser_sts[4][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[5][3][4:0] = dma_axi_st_rx_tuser_sts[5][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[5][2][4:0] = dma_axi_st_rx_tuser_sts[5][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[5][1][4:0] = dma_axi_st_rx_tuser_sts[5][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[5][0][4:0] = dma_axi_st_rx_tuser_sts[5][0][4:0];

	 dma_gbx_ptpb_axi_st_rx_tuser_client[0][3][1:0] = dma_axi_st_rx_tuser_client[0][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[0][2][1:0] = dma_axi_st_rx_tuser_client[0][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[0][1][1:0] = dma_axi_st_rx_tuser_client[0][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[0][0][1:0] = dma_axi_st_rx_tuser_client[0][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[1][3][1:0] = dma_axi_st_rx_tuser_client[1][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[1][2][1:0] = dma_axi_st_rx_tuser_client[1][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[1][1][1:0] = dma_axi_st_rx_tuser_client[1][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[1][0][1:0] = dma_axi_st_rx_tuser_client[1][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[2][3][1:0] = dma_axi_st_rx_tuser_client[2][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[2][2][1:0] = dma_axi_st_rx_tuser_client[2][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[2][1][1:0] = dma_axi_st_rx_tuser_client[2][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[2][0][1:0] = dma_axi_st_rx_tuser_client[2][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[3][3][1:0] = dma_axi_st_rx_tuser_client[3][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[3][2][1:0] = dma_axi_st_rx_tuser_client[3][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[3][1][1:0] = dma_axi_st_rx_tuser_client[3][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[3][0][1:0] = dma_axi_st_rx_tuser_client[3][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[4][3][1:0] = dma_axi_st_rx_tuser_client[4][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[4][2][1:0] = dma_axi_st_rx_tuser_client[4][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[4][1][1:0] = dma_axi_st_rx_tuser_client[4][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[4][0][1:0] = dma_axi_st_rx_tuser_client[4][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[5][3][1:0] = dma_axi_st_rx_tuser_client[5][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[5][2][1:0] = dma_axi_st_rx_tuser_client[5][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[5][1][1:0] = dma_axi_st_rx_tuser_client[5][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[5][0][1:0] = dma_axi_st_rx_tuser_client[5][0][1:0];

  end
  else if (HSSI_NUM_OF_SEG == 2) begin
     hssi_ss_st_tx_tuser_client[1]       = {axi_st_tx_tuser_client_o[1][0],axi_st_tx_tuser_client_o[1][0]};
     hssi_axi_st_rx_tuser_client_i[1][0][6:0] = ms_hssi_ss_st_rx_tuser_client[1][6:0];
     hssi_axi_st_rx_tuser_sts_i[1][0][4:0]    = ms_hssi_ss_st_rx_tuser_sts[1][4:0];
     
     hssi_ss_st_tx_tuser_client[0]       = {axi_st_tx_tuser_client_o[0][0],axi_st_tx_tuser_client_o[0][0]};
     hssi_axi_st_rx_tuser_client_i[0][0][6:0] = ms_hssi_ss_st_rx_tuser_client[0][6:0];
     hssi_axi_st_rx_tuser_sts_i[0][0][4:0]    = ms_hssi_ss_st_rx_tuser_sts[0][4:0];
	 
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[0][1][4:0] = dma_axi_st_rx_tuser_sts[0][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[0][0][4:0] = dma_axi_st_rx_tuser_sts[0][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[1][1][4:0] = dma_axi_st_rx_tuser_sts[1][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[1][0][4:0] = dma_axi_st_rx_tuser_sts[1][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[2][1][4:0] = dma_axi_st_rx_tuser_sts[2][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[2][0][4:0] = dma_axi_st_rx_tuser_sts[2][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[3][1][4:0] = dma_axi_st_rx_tuser_sts[3][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[3][0][4:0] = dma_axi_st_rx_tuser_sts[3][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[4][1][4:0] = dma_axi_st_rx_tuser_sts[4][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[4][0][4:0] = dma_axi_st_rx_tuser_sts[4][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[5][1][4:0] = dma_axi_st_rx_tuser_sts[5][0][4:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_sts[5][0][4:0] = dma_axi_st_rx_tuser_sts[5][0][4:0];

	 dma_gbx_ptpb_axi_st_rx_tuser_client[0][1][1:0] = dma_axi_st_rx_tuser_client[0][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[0][0][1:0] = dma_axi_st_rx_tuser_client[0][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[1][1][1:0] = dma_axi_st_rx_tuser_client[1][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[1][0][1:0] = dma_axi_st_rx_tuser_client[1][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[2][1][1:0] = dma_axi_st_rx_tuser_client[2][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[2][0][1:0] = dma_axi_st_rx_tuser_client[2][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[3][1][1:0] = dma_axi_st_rx_tuser_client[3][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[3][0][1:0] = dma_axi_st_rx_tuser_client[3][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[4][1][1:0] = dma_axi_st_rx_tuser_client[4][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[4][0][1:0] = dma_axi_st_rx_tuser_client[4][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[5][1][1:0] = dma_axi_st_rx_tuser_client[5][0][1:0];
	 dma_gbx_ptpb_axi_st_rx_tuser_client[5][0][1:0] = dma_axi_st_rx_tuser_client[5][0][1:0];
  end
  else if (HSSI_NUM_OF_SEG == 1)
   begin
     hssi_ss_st_tx_tuser_client[1]       = axi_st_tx_tuser_client_o[1][0];
     hssi_axi_st_rx_tuser_client_i[1][0][6:0] = ms_hssi_ss_st_rx_tuser_client[1][6:0];
     hssi_axi_st_rx_tuser_sts_i[1][0][4:0]    = ms_hssi_ss_st_rx_tuser_sts[1][4:0];
     
     hssi_ss_st_tx_tuser_client[0]       = axi_st_tx_tuser_client_o[0][0];
     hssi_axi_st_rx_tuser_client_i[0][0][6:0] = ms_hssi_ss_st_rx_tuser_client[0][6:0];
     hssi_axi_st_rx_tuser_sts_i[0][0][4:0]    = ms_hssi_ss_st_rx_tuser_sts[0][4:0];
	 
	 dma_gbx_ptpb_axi_st_rx_tuser_sts = dma_axi_st_rx_tuser_sts;
	 dma_gbx_ptpb_axi_st_rx_tuser_client = dma_axi_st_rx_tuser_client;
	 
   end
end

generate for(genvar i=0;i<NUM_PORTS;i++) begin : gen_ptp_gbx_top_inst

 //---------------------------------------------
  // Multi-segment to Single-segment Conversion
  //---------------------------------------------
  
  multiseg_singleseg_conv  
    #(
      .DATA_W        (HSSI_TDATA_WIDTH)
     ,.USER_W        (10)   
     ,.USER_STS_W    (RX_USER_STS_WIDTH)
     ,.USER_CLIENT_W (RX_USER_CLIENT_WIDTH)
	  ,.USER_TS_IGR_W (RXIGR_TS_DW)
	) i_multiseg_singleseg_conv 
    (
      .i_clk             (o_clk_pll[i]), 
      .i_rstn            (~hssi_pll_rst[i]),
      .axis_tx_if        (axis_tx_if[i]),
      .axis_rx_if        (axis_rx_if[i])
    );  
   
  assign axis_rx_if[i].tvalid                     = hssi_ss_st_rx_tvalid[i] ;              
  assign axis_rx_if[i].tdata                      = hssi_ss_st_rx_tdata[i]  ;
  assign axis_rx_if[i].tkeep                      = hssi_ss_st_rx_tkeep[i]  ;
  assign axis_rx_if[i].tlast                      = hssi_ss_st_rx_tlast[i]  ;
  assign axis_rx_if[i].tuser_last_segment[HSSI_NUM_OF_SEG-1:0] = hssi_ss_st_rx_tuser_last_segment[i];
  assign axis_rx_if[i].tuser_sts                  = hssi_ss_st_rx_tuser_sts[i];
  assign axis_rx_if[i].tuser_client               = hssi_ss_st_rx_tuser_client[i];
  assign axis_rx_if[i].tuser_ts_igr_data          = hssi_ptp_rx_ingrts_tdata[i];
  assign axis_rx_if[i].tuser_ts_igr_valid         = hssi_ptp_rx_ingrts_tvalid[i];
  assign ms_hssi_ss_st_rx_tuser_sts_extended[i]   = '{default:0};
  assign ms_hssi_ss_st_rx_tuser_pkt_seg_parity[i] = '0;

  assign ms_hssi_ss_st_rx_tvalid[i]               = axis_tx_if[i].tvalid;         
  assign ms_hssi_ss_st_rx_tdata[i]                = axis_tx_if[i].tdata;         
  assign ms_hssi_ss_st_rx_tkeep[i]                = axis_tx_if[i].tkeep;          
  assign ms_hssi_ss_st_rx_tlast[i]                = axis_tx_if[i].tlast;        
  assign axis_tx_if[i].tready                     = 1; 
  assign ms_hssi_ss_st_rx_tuser_sts[i]            = axis_tx_if[i].tuser_sts;
  assign ms_hssi_ss_st_rx_tuser_client[i]         = axis_tx_if[i].tuser_client; 
  assign ms_hssi_ss_st_rx_tuser_last_segment[i]   = axis_tx_if[i].tuser_last_segment[HSSI_NUM_OF_SEG-1:0];
  assign ms_hssi_ptp_rx_ingrts_tdata[i]           = axis_tx_if[i].tuser_ts_igr_data;
  assign ms_hssi_ptp_rx_ingrts_tvalid[i]          = axis_tx_if[i].tuser_ts_igr_valid;
 
end endgenerate


for(genvar i = 0; i < DMA_CHS; i++) begin : tlast_segment_map
   case (HSSI_NUM_OF_SEG)
   'd1: begin
      assign dma_gbx_ptpb_axi_st_rx_tuser_last_segment_conv[i] = dma_gbx_ptpb_axi_st_rx_tlast[i];
	end
   'd2: begin
      assign dma_gbx_ptpb_axi_st_rx_tuser_last_segment_conv[i] = (dma_gbx_ptpb_axi_st_rx_tlast[i] & dma_gbx_ptpb_axi_st_rx_tkeep[i][8]) ? 2'b10 : (dma_gbx_ptpb_axi_st_rx_tlast[i] & dma_gbx_ptpb_axi_st_rx_tkeep[i][0]) ? 2'b01 : 2'b00;
	end
   'd4: begin
      assign dma_gbx_ptpb_axi_st_rx_tuser_last_segment_conv[i] = (dma_gbx_ptpb_axi_st_rx_tlast[i] & dma_gbx_ptpb_axi_st_rx_tkeep[i][24]) ? 4'b1000 : (dma_gbx_ptpb_axi_st_rx_tlast[i] & dma_gbx_ptpb_axi_st_rx_tkeep[i][16]) ? 4'b0100 : (dma_gbx_ptpb_axi_st_rx_tlast[i] & dma_gbx_ptpb_axi_st_rx_tkeep[i][8]) ? 4'b0010 : (dma_gbx_ptpb_axi_st_rx_tlast[i] & dma_gbx_ptpb_axi_st_rx_tkeep[i][0]) ? 4'b0001 : 4'b0000;
    end
    default: begin
	  assign dma_gbx_ptpb_axi_st_rx_tuser_last_segment_conv[i] = '0;
	end
	endcase
end

	
endmodule
