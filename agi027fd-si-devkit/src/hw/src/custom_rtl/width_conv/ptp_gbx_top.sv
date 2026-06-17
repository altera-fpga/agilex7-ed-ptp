// ############################################################################################
// intel_start_of_header
//
// INTEL CONFIDENTIAL
// Copyright 2018 Intel Corporation
//
// The source code contained or described herein and all documents related
// to the source code ("Material") are owned by Intel Corporation or
// its suppliers or licensors. Title to the Material remains with Intel
// Corporation or its suppliers and licensors. The Material contains trade
// secrets and proprietary and confidential information of Intel or its
// suppliers and licensors. The Material is protected by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material
// may be used, copied, reproduced, modified, published, uploaded, posted,
// transmitted, distributed, or disclosed in any way without Intel's prior
// express written permission.
//
// No license under any patent, copyright, trade secret or other intellectual
// property right is granted to or conferred upon you by disclosure or
// delivery of the Materials, either expressly, by implication, inducement,
// estoppel or otherwise. Any license under such intellectual property
// rights must be express and approved by Intel in writing.
//
// intel_end_of_header
// ############################################################################################


//#############################################################################################
// File editing rules:
//   - Columns MUST NOT EXCEED 95.
//   - Do not use TAB Function as indentation.
//   - Indentation must not be more 4.
//   - Please follow the editing rules.
//#############################################################################################


//---------------------------------------------------------------------------------------------
// Description: This is the top level of PTP Gearbox Module (ptp_gbx_top.sv)			
// 	- All the top level parameters & Interfaces listed in here		
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

module ptp_gbx_top
  #(

     parameter ETHERNET_RATE                   = 400  // supports 10/25/50/100/200/400   
    ,parameter DMA_TDATA_WIDTH                 = 64   // supports only 64b
    ,parameter HSSI_TDATA_WIDTH	               = 1024 // supports 64/128/256/512/1024
    
    ,parameter DMA_NUM_OF_SEG                  = 1    // supports only 1
    ,parameter DMA_NUM_OF_SOP                  = 1    // supports only 1 	
    ,parameter HSSI_NUM_OF_SEG                 = 16   // supports 1/2/4/8/16
    ,parameter HSSI_NUM_OF_SOP                 = 1    // supports only 1
    ,parameter TXEGR_TS_DW                     = 128
    ,parameter RXIGR_TS_DW                     = 96
    ,parameter PTP_WIDTH                       = 94
    ,parameter PTP_EXT_WIDTH                   = 328
    )

   ( 
     //=======================================================================================
     // Clocks
     //---------------------------------------------------------------------------------------
     // clock for TX data path
     input var logic                                   tx_clk_i 
	 // clock for RX data path    
    ,input var logic                                   rx_clk_i      
	 
     //resets
     //Active low async reset for TX data path
    ,input var logic				       tx_areset_n_i
     //Active low async reset for RX data path
    ,input var logic                                   rx_areset_n_i		
	
    //=========================================================================================
    // TX Interface:  Inputs from DMA
    //-----------------------------------------------------------------------------------------
    // tx ingress interface
    ,input var logic                                   axi_st_tx_tvalid_i
    ,input var logic [DMA_TDATA_WIDTH-1:0]             axi_st_tx_tdata_i
    ,input var logic [DMA_TDATA_WIDTH/8-1:0]           axi_st_tx_tkeep_i
    ,input var logic                                   axi_st_tx_tlast_i
    ,input var logic [PTP_WIDTH -1:0]                  axi_st_tx_tuser_ptp_i
    ,input var logic [PTP_EXT_WIDTH -1:0]              axi_st_tx_tuser_ptp_extended_i
    ,input var logic [DMA_NUM_OF_SEG-1:0] [1:0]        axi_st_tx_tuser_client_i
    ,input var logic [DMA_NUM_OF_SEG-1:0]              axi_st_tx_tuser_pkt_seg_parity_i
    ,input var logic [DMA_NUM_OF_SEG-1:0]              axi_st_tx_tuser_last_segment_i
    
    ,output var logic                                  axi_st_tx_tready_o
	
    //-----------------------------------------------------------------------------------------
    // tx egress interface: Outputs to HSSI
    ,output var logic                                  axi_st_tx_tvalid_o
    ,output var logic [HSSI_TDATA_WIDTH-1:0]           axi_st_tx_tdata_o
    ,output var logic [HSSI_TDATA_WIDTH/8-1:0]         axi_st_tx_tkeep_o
    ,output var logic                                  axi_st_tx_tlast_o
    ,output var logic [PTP_WIDTH -1:0]                 axi_st_tx_tuser_ptp_o
    ,output var logic [PTP_EXT_WIDTH -1:0]             axi_st_tx_tuser_ptp_extended_o
    ,output var logic [HSSI_NUM_OF_SEG-1:0][1:0]       axi_st_tx_tuser_client_o
    ,output var logic [HSSI_NUM_OF_SEG-1:0]            axi_st_tx_tuser_pkt_seg_parity_o
    ,output var logic [HSSI_NUM_OF_SEG-1:0]            axi_st_tx_tuser_last_segment_o
     
    ,input var logic                                   axi_st_tx_tready_i
	
    //=========================================================================================
    // RX Interface
    //-----------------------------------------------------------------------------------------
    // rx ingress interface:  Inputs from HSSI
    ,input var logic                                   axi_st_rx_tvalid_i
    ,input var logic [HSSI_TDATA_WIDTH-1:0]            axi_st_rx_tdata_i
    ,input var logic [HSSI_TDATA_WIDTH/8-1:0]          axi_st_rx_tkeep_i
    ,input var logic                                   axi_st_rx_tlast_i
	//Rx Packet Error Status
    ,input var logic [HSSI_NUM_OF_SEG-1:0] [6:0]       axi_st_rx_tuser_client_i
	//Rx Packet Status
    ,input var logic [HSSI_NUM_OF_SEG-1:0] [4:0]       axi_st_rx_tuser_sts_i
    ,input var logic [HSSI_NUM_OF_SEG-1:0] [31:0]      axi_st_rx_tuser_sts_extended_i
    ,input var logic [HSSI_NUM_OF_SEG-1:0]             axi_st_rx_tuser_pkt_seg_parity_i
    ,input var logic [HSSI_NUM_OF_SEG-1:0]             axi_st_rx_tuser_last_segment_i
    
    ,output var logic                                  axi_st_rx_tready_o
	
    //-----------------------------------------------------------------------------------------
    // rx egress interface: outputs to DMA
    ,output var logic                                  axi_st_rx_tvalid_o
    ,output var logic [DMA_TDATA_WIDTH-1:0]            axi_st_rx_tdata_o
    ,output var logic [DMA_TDATA_WIDTH/8-1:0]          axi_st_rx_tkeep_o
    ,output var logic                                  axi_st_rx_tlast_o
	//Rx Packet Error Status
    ,output var logic [DMA_NUM_OF_SEG-1:0] [6:0]       axi_st_rx_tuser_client_o
	//Rx Packet Status
    ,output var logic [DMA_NUM_OF_SEG-1:0] [4:0]       axi_st_rx_tuser_sts_o
    ,output var logic [DMA_NUM_OF_SEG-1:0] [31:0]      axi_st_rx_tuser_sts_extended_o
    ,output var logic [DMA_NUM_OF_SEG-1:0]             axi_st_rx_tuser_pkt_seg_parity_o
    ,output var logic [DMA_NUM_OF_SEG-1:0]             axi_st_rx_tuser_last_segment_o
    
    ,input var logic                                   axi_st_rx_tready_i
	
    //=========================================================================================
    // Time Stamp Interface:-  HN: Note I have not seen an update in the spec regarding the
    //                         alignment.
    //-----------------------------------------------------------------------------------------
    // tx egress timestamp from HSSI interface
    ,input var logic                                   axi_st_txegrts0_tvalid_i
    ,input var logic [TXEGR_TS_DW-1:0]                 axi_st_txegrts0_tdata_i
    ,input var logic                                   axi_st_txegrts1_tvalid_i
    ,input var logic [TXEGR_TS_DW-1:0]                 axi_st_txegrts1_tdata_i
	
     // tx egress timestamp to DMA interface
    ,output var logic                                  axi_st_txegrts0_tvalid_o
    ,output var logic [TXEGR_TS_DW-1:0]                axi_st_txegrts0_tdata_o
    ,output var logic                                  axi_st_txegrts1_tvalid_o
    ,output var logic [TXEGR_TS_DW-1:0]                axi_st_txegrts1_tdata_o
	
    //-----------------------------------------------------------------------------------------
    // rx ingress timestamp from HSSI interface
    ,input var logic                                   axi_st_rxegrts0_tvalid_i
    ,input var logic [RXIGR_TS_DW-1:0]                 axi_st_rxegrts0_tdata_i
    ,input var logic                                   axi_st_rxegrts1_tvalid_i
    ,input var logic [RXIGR_TS_DW-1:0]                 axi_st_rxegrts1_tdata_i
	
	// tx ingress timestamp to DMA interface
    ,output var logic                                  axi_st_rxegrts0_tvalid_o
    ,output var logic [RXIGR_TS_DW-1:0]                axi_st_rxegrts0_tdata_o
    ,output var logic                                  axi_st_rxegrts1_tvalid_o
    ,output var logic [RXIGR_TS_DW-1:0]                axi_st_rxegrts1_tdata_o
	     

     );
   //===============================================================end of top level interfaces

   //------------------------------------------------------------------------------------------
   // ptp_gbx_rx
   ptp_gbx_rx
    #( .HSSI_TDATA_WIDTH (HSSI_TDATA_WIDTH)
      ,.HSSI_NUM_OF_SEG (HSSI_NUM_OF_SEG)
      ,.DMA_TDATA_WIDTH (DMA_TDATA_WIDTH)
      ,.DMA_NUM_OF_SEG (DMA_NUM_OF_SEG)
      ,.TXEGR_TS_DW (TXEGR_TS_DW)
      ,.RXIGR_TS_DW (RXIGR_TS_DW)
      
      ) ptp_gbx_rx
   (
    .rx_clk_i (rx_clk_i)
    ,.rx_areset_n_i (rx_areset_n_i)
    

    //-----------------------------------------------------------------------------------------
    // // rx ingress interface:  Inputs from HSSI
    // inputs
    ,.axi_st_rx_tvalid_i (axi_st_rx_tvalid_i)
    ,.axi_st_rx_tdata_i (axi_st_rx_tdata_i)
    ,.axi_st_rx_tkeep_i (axi_st_rx_tkeep_i)
    ,.axi_st_rx_tlast_i (axi_st_rx_tlast_i)
    ,.axi_st_rx_tuser_client_i (axi_st_rx_tuser_client_i)
    ,.axi_st_rx_tuser_sts_i (axi_st_rx_tuser_sts_i)
    ,.axi_st_rx_tuser_sts_extended_i (axi_st_rx_tuser_sts_extended_i)
    ,.axi_st_rx_tuser_pkt_seg_parity_i (axi_st_rx_tuser_pkt_seg_parity_i)
    ,.axi_st_rx_tuser_last_segment_i (axi_st_rx_tuser_last_segment_i)

    // outputs
    ,.axi_st_rx_tready_o (axi_st_rx_tready_o)

    //-----------------------------------------------------------------------------------------
    // rx egress interface: outputs to DMA
    // outputs
    ,.axi_st_rx_tvalid_o (axi_st_rx_tvalid_o)
    ,.axi_st_rx_tdata_o (axi_st_rx_tdata_o)
    ,.axi_st_rx_tkeep_o (axi_st_rx_tkeep_o)
    ,.axi_st_rx_tlast_o (axi_st_rx_tlast_o)
    ,.axi_st_rx_tuser_client_o (axi_st_rx_tuser_client_o)  
    ,.axi_st_rx_tuser_sts_o (axi_st_rx_tuser_sts_o)
    ,.axi_st_rx_tuser_sts_extended_o (axi_st_rx_tuser_sts_extended_o)
    ,.axi_st_rx_tuser_pkt_seg_parity_o (axi_st_rx_tuser_pkt_seg_parity_o)
    ,.axi_st_rx_tuser_last_segment_o (axi_st_rx_tuser_last_segment_o)

    // inputs
    ,.axi_st_rx_tready_i (axi_st_rx_tready_i)

    //-----------------------------------------------------------------------------------------
    // rx timestamp interface from HSSI
    // inputs
    ,.axi_st_rxegrts0_tvalid_i (axi_st_rxegrts0_tvalid_i)
    ,.axi_st_rxegrts0_tdata_i (axi_st_rxegrts0_tdata_i)
    ,.axi_st_rxegrts1_tvalid_i (axi_st_rxegrts1_tvalid_i)
    ,.axi_st_rxegrts1_tdata_i (axi_st_rxegrts1_tdata_i)

    // outputs
    ,.axi_st_rxegrts0_tvalid_o (axi_st_rxegrts0_tvalid_o)
    ,.axi_st_rxegrts0_tdata_o (axi_st_rxegrts0_tdata_o)
    ,.axi_st_rxegrts1_tvalid_o (axi_st_rxegrts1_tvalid_o)
    ,.axi_st_rxegrts1_tdata_o (axi_st_rxegrts1_tdata_o)
    
    );
   
   
   //------------------------------------------------------------------------------------------
   // ptp_gbx_tx
   ptp_gbx_tx
    #( .HSSI_TDATA_WIDTH (HSSI_TDATA_WIDTH)
      ,.HSSI_NUM_OF_SEG (HSSI_NUM_OF_SEG)
      ,.DMA_TDATA_WIDTH (DMA_TDATA_WIDTH)
      ,.DMA_NUM_OF_SEG (DMA_NUM_OF_SEG)
      ,.TXEGR_TS_DW (TXEGR_TS_DW)
      ,.RXIGR_TS_DW (RXIGR_TS_DW)
      ,.PTP_WIDTH (PTP_WIDTH)
      ,.PTP_EXT_WIDTH (PTP_EXT_WIDTH)
      ) ptp_gbx_tx
   (
    .tx_clk_i (tx_clk_i)
    ,.tx_areset_n_i (tx_areset_n_i)

    //=========================================================================================
    // TX Interface:  Inputs from DMA
    // inputs
    ,.axi_st_tx_tvalid_i (axi_st_tx_tvalid_i)
    ,.axi_st_tx_tdata_i (axi_st_tx_tdata_i)
    ,.axi_st_tx_tkeep_i (axi_st_tx_tkeep_i)
    ,.axi_st_tx_tlast_i (axi_st_tx_tlast_i)
    ,.axi_st_tx_tuser_client_i (axi_st_tx_tuser_client_i)
    ,.axi_st_tx_tuser_pkt_seg_parity_i (axi_st_tx_tuser_pkt_seg_parity_i)
    ,.axi_st_tx_tuser_last_segment_i (axi_st_tx_tuser_last_segment_i)
    ,.axi_st_tx_tuser_ptp_i (axi_st_tx_tuser_ptp_i)
    ,.axi_st_tx_tuser_ptp_extended_i (axi_st_tx_tuser_ptp_extended_i)

    // outputs
    ,.axi_st_tx_tready_o (axi_st_tx_tready_o)


    //-----------------------------------------------------------------------------------------
    // tx egress interface: Outputs to HSSI
    // outputs
    ,.axi_st_tx_tvalid_o (axi_st_tx_tvalid_o)
    ,.axi_st_tx_tdata_o (axi_st_tx_tdata_o)
    ,.axi_st_tx_tkeep_o (axi_st_tx_tkeep_o)
    ,.axi_st_tx_tlast_o (axi_st_tx_tlast_o)
    ,.axi_st_tx_tuser_last_segment_o (axi_st_tx_tuser_last_segment_o)
    ,.axi_st_tx_tuser_client_o (axi_st_tx_tuser_client_o)
    ,.axi_st_tx_tuser_pkt_seg_parity_o (axi_st_tx_tuser_pkt_seg_parity_o)
    ,.axi_st_tx_tuser_ptp_o (axi_st_tx_tuser_ptp_o)
    ,.axi_st_tx_tuser_ptp_extended_o (axi_st_tx_tuser_ptp_extended_o)

    // inputs
    ,.axi_st_tx_tready_i (axi_st_tx_tready_i)

    //=========================================================================================
    // Time Stamp Interface:  tx egress timestamp from HSSI interface
    // inputs
    ,.axi_st_txegrts0_tvalid_i (axi_st_txegrts0_tvalid_i)
    ,.axi_st_txegrts0_tdata_i (axi_st_txegrts0_tdata_i)
    ,.axi_st_txegrts1_tvalid_i (axi_st_txegrts1_tvalid_i)
    ,.axi_st_txegrts1_tdata_i (axi_st_txegrts1_tdata_i)

    //  tx egress timestamp to DMA interface
    // outputs
    ,.axi_st_txegrts0_tvalid_o (axi_st_txegrts0_tvalid_o)
    ,.axi_st_txegrts0_tdata_o (axi_st_txegrts0_tdata_o)
    ,.axi_st_txegrts1_tvalid_o (axi_st_txegrts1_tvalid_o)
    ,.axi_st_txegrts1_tdata_o (axi_st_txegrts1_tdata_o)
    
    );
   
endmodule // ptp_gbx_top
   
