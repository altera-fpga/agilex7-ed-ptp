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
// Description: Example PTP Design Tx Interface:			
// 		
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

module ptp_gbx_tx
  #(

     parameter ETHERNET_RATE          = 400  // supports 10/25/50/100/200/400

    //-----------------------------------------------------------------------------------------
    // ingress interface parameter:
    ,parameter HSSI_TDATA_WIDTH	      = 1024 // supports 64/128/256/512/1024      
    ,parameter HSSI_NUM_OF_SEG        = 16   // supports 1/2/4/8/16
    ,parameter HSSI_NUM_OF_SOP        = 1    // supports only 1
    // per segment tdata_width: Note HSSI_DATA_SEG_WIDTH must equal to DMA_DATA_SEG_WIDTH
    ,parameter HSSI_DATA_SEG_WIDTH    = HSSI_TDATA_WIDTH/HSSI_NUM_OF_SEG
    
    ,parameter HSSI_KEEP_WIDTH        = HSSI_TDATA_WIDTH/8
    // per segment tkeep_width: Note HSSI_KEEP_SEG_WIDTH must equal to DMA_KEEP_SEG_WIDTH
    ,parameter HSSI_KEEP_SEG_WIDTH    = HSSI_KEEP_WIDTH/HSSI_NUM_OF_SEG
    
    //-----------------------------------------------------------------------------------------
    // egress interface parameter
    ,parameter DMA_TDATA_WIDTH        = 64   // supports only 64b                         
    ,parameter DMA_NUM_OF_SEG         = 1    // supports only 1
    ,parameter DMA_NUM_OF_SOP         = 1    // supports only 1 
    // per segment tdata_width: Note HSSI_DATA_SEG_WIDTH must equal to DMA_DATA_SEG_WIDTH 
    ,parameter DMA_DATA_SEG_WIDTH     = DMA_TDATA_WIDTH/DMA_NUM_OF_SEG
    ,parameter DMA_KEEP_WIDTH         = DMA_TDATA_WIDTH/8
    // per segment tkeep_width: Note HSSI_KEEP_SEG_WIDTH must equal to DMA_KEEP_SEG_WIDTH
    ,parameter DMA_KEEP_SEG_WIDTH     = DMA_KEEP_WIDTH/DMA_NUM_OF_SEG
    
    ,parameter TXEGR_TS_DW            = 128
    ,parameter RXIGR_TS_DW            = 96  
    ,parameter PTP_WIDTH              = 94
    ,parameter PTP_EXT_WIDTH          = 327
      
    )

  ( 
     //=======================================================================================
     // Clocks
     //---------------------------------------------------------------------------------------
     // clock for RX data path    
     input var logic                                   tx_clk_i      
	 
     //resets
      //Active low async reset for RX data path
    ,input var logic                                   tx_areset_n_i		
	
    //=========================================================================================
    // TX Interface:  Inputs from DMA
    //-----------------------------------------------------------------------------------------
    // tx ingress interface
    ,input var logic                                   axi_st_tx_tvalid_i
    ,input var logic [DMA_NUM_OF_SEG -1:0] 
                      [DMA_DATA_SEG_WIDTH -1:0]        axi_st_tx_tdata_i
    ,input var logic [DMA_NUM_OF_SEG -1:0] 
                      [DMA_KEEP_SEG_WIDTH -1:0]        axi_st_tx_tkeep_i
    ,input var logic                                   axi_st_tx_tlast_i    
    ,input var logic [DMA_NUM_OF_SEG-1:0] [1:0]        axi_st_tx_tuser_client_i
    ,input var logic [DMA_NUM_OF_SEG-1:0]              axi_st_tx_tuser_pkt_seg_parity_i
    ,input var logic [DMA_NUM_OF_SEG-1:0]              axi_st_tx_tuser_last_segment_i
    ,input var logic [PTP_WIDTH -1:0]                  axi_st_tx_tuser_ptp_i
    ,input var logic [PTP_EXT_WIDTH -1:0]              axi_st_tx_tuser_ptp_extended_i
    
    ,output var logic                                  axi_st_tx_tready_o
	
    //-----------------------------------------------------------------------------------------
    // tx egress interface: Outputs to HSSI
    ,output var logic                                  axi_st_tx_tvalid_o
    ,output var logic [HSSI_NUM_OF_SEG-1:0]
                       [HSSI_DATA_SEG_WIDTH -1:0]      axi_st_tx_tdata_o
    ,output var logic [HSSI_NUM_OF_SEG-1:0] 
                      [HSSI_KEEP_SEG_WIDTH -1:0]       axi_st_tx_tkeep_o
    ,output var logic                                  axi_st_tx_tlast_o
    ,output var logic [HSSI_NUM_OF_SEG-1:0]            axi_st_tx_tuser_last_segment_o
    ,output var logic [HSSI_NUM_OF_SEG-1:0][1:0]       axi_st_tx_tuser_client_o
    ,output var logic [HSSI_NUM_OF_SEG-1:0]            axi_st_tx_tuser_pkt_seg_parity_o   
    ,output var logic [PTP_WIDTH - 1:0]                axi_st_tx_tuser_ptp_o
    ,output var logic [PTP_EXT_WIDTH -1:0]             axi_st_tx_tuser_ptp_extended_o
    
    ,input var logic                                   axi_st_tx_tready_i

    //=========================================================================================
    // Time Stamp Interface:
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
     );
 
   logic   clk, rst;

   always_comb begin
      clk = tx_clk_i;
   end

   //------------------------------------------------------------------------------------------
   // reset
   ipbb_asyn_to_syn_rst rst_sync
     (.clk (clk)
      ,.asyn_rst (!tx_areset_n_i)

      // output
      ,.syn_rst (rst)
      );
    
   logic [31:0] rst_reg;
   // Generate arrays of reset to be used in submodule
   always_ff @(posedge clk) begin
      rst_reg <= '{default:rst};
   end
   //==========================================================================================
   localparam TUSER_CLIENT_WIDTH        = 2;
   localparam TUSER_PTP_WIDTH           = PTP_WIDTH;
   localparam TUSER_PTP_EXT_WIDTH       = PTP_EXT_WIDTH;
   localparam HSSI_SEG_PARITY_WIDTH     = HSSI_NUM_OF_SEG;
   localparam DMA_SEG_PARITY_WIDTH      = DMA_NUM_OF_SEG;

   localparam DMA_TUSER_MD_WIDTH =  TUSER_CLIENT_WIDTH
				   +TUSER_PTP_WIDTH
				   +TUSER_PTP_EXT_WIDTH
				   +DMA_SEG_PARITY_WIDTH;

   localparam HSSI_TUSER_MD_WIDTH =  TUSER_CLIENT_WIDTH
				    +TUSER_PTP_WIDTH
				    +TUSER_PTP_EXT_WIDTH
				    +HSSI_SEG_PARITY_WIDTH;
   
   localparam IFIFO_DEPTH         = 512;
   localparam IFIFO_WIDTH         = $clog2(IFIFO_DEPTH);
   
   localparam EFIFO_DEPTH         = 2048; // to support Jumbo pkt, earlier value is 512
   localparam EFIFO_WIDTH         = $clog2(EFIFO_DEPTH);
   
   logic [DMA_NUM_OF_SEG-1:0][DMA_TUSER_MD_WIDTH -1:0] axi_st_tx_tuser_md_i;
   logic [HSSI_NUM_OF_SEG -1:0][HSSI_TUSER_MD_WIDTH -1:0] axi_st_tx_tuser_md_o;

   logic [HSSI_NUM_OF_SEG -1:0]
	 [DMA_TUSER_MD_WIDTH -1:0]        tx_tuser_md_o;
				  
   logic [HSSI_NUM_OF_SEG-1:0]
         [TUSER_CLIENT_WIDTH -1:0]        tx_tuser_client_o;
   
   logic [HSSI_NUM_OF_SEG-1:0]            tx_tuser_pkt_seg_parity_o;
    
   logic [HSSI_NUM_OF_SEG-1:0]
         [TUSER_PTP_WIDTH - 1:0]          tx_tuser_ptp_o;
   
   logic [HSSI_NUM_OF_SEG-1:0] 
         [TUSER_PTP_EXT_WIDTH -1:0]       tx_tuser_ptp_extended_o;
			      
   always_comb begin
      for (int i = 0; i < DMA_NUM_OF_SEG; i++) begin
	 axi_st_tx_tuser_md_i[i] = { 
				     axi_st_tx_tuser_pkt_seg_parity_i[i]
				    ,axi_st_tx_tuser_client_i[i]		 
				    ,axi_st_tx_tuser_ptp_i
				    ,axi_st_tx_tuser_ptp_extended_i
				    };	 
      end

      //axi_st_tx_tuser_client_o         = tx_tuser_client_o;
      //axi_st_tx_tuser_pkt_seg_parity_o = tx_tuser_pkt_seg_parity_o;     
      //axi_st_tx_tuser_ptp_o            = tx_tuser_ptp_o[0];
      //axi_st_tx_tuser_ptp_extended_o   = tx_tuser_ptp_extended_o[0];      
   end

   always_ff @(posedge clk) begin
      axi_st_txegrts0_tvalid_o <= axi_st_txegrts0_tvalid_i;
      axi_st_txegrts0_tdata_o  <= axi_st_txegrts0_tdata_i;

      axi_st_txegrts1_tvalid_o <= axi_st_txegrts1_tvalid_i;
      axi_st_txegrts1_tdata_o  <= axi_st_txegrts1_tdata_i;

   end

   always_comb begin
      for (int i = 0; i < HSSI_NUM_OF_SEG; i++) begin
	 { tx_tuser_pkt_seg_parity_o[i]
	  ,tx_tuser_client_o[i]
	  ,tx_tuser_ptp_o[i]
	  ,tx_tuser_ptp_extended_o[i]}  = tx_tuser_md_o[i];	 
      end

      axi_st_tx_tuser_pkt_seg_parity_o = tx_tuser_pkt_seg_parity_o;
      axi_st_tx_tuser_client_o         = tx_tuser_client_o;
      axi_st_tx_tuser_ptp_o            = tx_tuser_ptp_o[0];
      axi_st_tx_tuser_ptp_extended_o   = tx_tuser_ptp_extended_o[0];
   end
   
   ipbb_axi_wdj_sm2lg
   #(   .IDATA_WIDTH (DMA_TDATA_WIDTH )
       ,.INUM_SEG (DMA_NUM_OF_SEG )
       ,.ENUM_SEG (HSSI_NUM_OF_SEG )
       ,.ITUSER_MD_WIDTH (DMA_TUSER_MD_WIDTH )
       ,.ETUSER_MD_WIDTH (DMA_TUSER_MD_WIDTH )
       ,.TID_WIDTH (1)
       ,.IFIFO_DEPTH (IFIFO_DEPTH)    
       ,.EFIFO_DEPTH (EFIFO_DEPTH)) axi_wdj_tx
   (
     .clk (clk)
    ,.rst (rst_reg[0])

    //-----------------------------------------------------------------------------------------
    // Ingress axi-st interface:  Inputs from DMA
    // outputs
    ,.trdy_o (axi_st_tx_tready_o)

    // inputs
    ,.tvld_i (axi_st_tx_tvalid_i)  
    ,.tid_i ('0)
    ,.tdata_i (axi_st_tx_tdata_i)  
    ,.tkeep_i (axi_st_tx_tkeep_i)
    ,.tuser_md_i (axi_st_tx_tuser_md_i)
    ,.terr_i ('0)  
    ,.tlast_i (axi_st_tx_tlast_i)
    //,.tlast_segment_i (axi_st_tx_tuser_last_segment_i & axi_st_tx_tlast_i)
    ,.tlast_segment_i (axi_st_tx_tlast_i)   // HN fix me:  Temporary fix to get around tb issue
    
    //------------------------------------------------------------------------------------------
    // Egress axi-st interface: Outputs to HSSI
    // inputs
    ,.trdy_i (axi_st_tx_tready_i)

    // outputs
    ,.tvld_o (axi_st_tx_tvalid_o)  
    ,.tid_o ()
    ,.tdata_o (axi_st_tx_tdata_o)
    ,.tkeep_o (axi_st_tx_tkeep_o)
    ,.tuser_md_o (tx_tuser_md_o)
    /*
    ,.tuser_md_o ({ tx_tuser_client_o
		   ,tx_tuser_pkt_seg_parity_o
		   ,tx_tuser_ptp_o
		   ,tx_tuser_ptp_extended_o
		   })*/
    ,.terr_o ()  
    ,.tlast_o (axi_st_tx_tlast_o)
    ,.tlast_segment_o (axi_st_tx_tuser_last_segment_o)  
   
    );
   
   
endmodule // ptp_gbx_tx
