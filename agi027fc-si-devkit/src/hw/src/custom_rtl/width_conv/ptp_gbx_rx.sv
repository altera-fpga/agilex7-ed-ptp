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
// Description: Example PTP Design Rx Interface:			
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

module ptp_gbx_rx
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
    )

   ( 
     //=======================================================================================
     // Clocks
     //---------------------------------------------------------------------------------------
     // clock for RX data path    
     input var logic                                   rx_clk_i      
	 
     //resets
      //Active low async reset for RX data path
    ,input var logic                                   rx_areset_n_i		
	
   
	
    //=========================================================================================
    // RX Interface
    //-----------------------------------------------------------------------------------------
    // rx ingress interface:  Inputs from HSSI
    ,input var logic                                   axi_st_rx_tvalid_i
    ,input var logic [HSSI_NUM_OF_SEG-1:0]
                     [HSSI_DATA_SEG_WIDTH -1:0]        axi_st_rx_tdata_i
    ,input var logic [HSSI_NUM_OF_SEG-1:0] 
                     [HSSI_KEEP_SEG_WIDTH -1:0]        axi_st_rx_tkeep_i
    ,input var logic                                   axi_st_rx_tlast_i
     //Rx Packet Error Status
    ,input var logic [HSSI_NUM_OF_SEG-1:0][6:0]        axi_st_rx_tuser_client_i
     //Rx Packet Status
    ,input var logic [HSSI_NUM_OF_SEG-1:0][4:0]        axi_st_rx_tuser_sts_i
    ,input var logic [HSSI_NUM_OF_SEG-1:0][31:0]       axi_st_rx_tuser_sts_extended_i
    ,input var logic [HSSI_NUM_OF_SEG-1:0]             axi_st_rx_tuser_pkt_seg_parity_i
    ,input var logic [HSSI_NUM_OF_SEG-1:0]             axi_st_rx_tuser_last_segment_i
    
    ,output var logic                                  axi_st_rx_tready_o
	
    //-----------------------------------------------------------------------------------------
    // rx egress interface: outputs to DMA
    ,output var logic                                  axi_st_rx_tvalid_o
    ,output var logic [DMA_NUM_OF_SEG -1:0] 
                      [DMA_DATA_SEG_WIDTH -1:0]        axi_st_rx_tdata_o
    ,output var logic [DMA_NUM_OF_SEG -1:0] 
                      [DMA_KEEP_SEG_WIDTH -1:0]        axi_st_rx_tkeep_o
    ,output var logic                                  axi_st_rx_tlast_o
     //Rx Packet Error Status
    ,output var logic [DMA_NUM_OF_SEG-1:0][6:0]        axi_st_rx_tuser_client_o
     //Rx Packet Status
    ,output var logic [DMA_NUM_OF_SEG-1:0][4:0]        axi_st_rx_tuser_sts_o
    ,output var logic [DMA_NUM_OF_SEG-1:0][31:0]       axi_st_rx_tuser_sts_extended_o
    ,output var logic [DMA_NUM_OF_SEG-1:0]             axi_st_rx_tuser_pkt_seg_parity_o
    ,output var logic [DMA_NUM_OF_SEG-1:0]             axi_st_rx_tuser_last_segment_o
    
    ,input var logic                                   axi_st_rx_tready_i
	
    //=========================================================================================
    // Time Stamp Interface:  HN: Note I have not seen an update in the spec regarding the
    //                        alignment.
    //-----------------------------------------------------------------------------------------
  	
    //-----------------------------------------------------------------------------------------
    // rx ingress timestamp from HSSI interface
    // valid during sop
    ,input var logic                                   axi_st_rxegrts0_tvalid_i 
    ,input var logic [RXIGR_TS_DW-1:0]                 axi_st_rxegrts0_tdata_i

     // applicable when ETHERNET_RATE = 400
    ,input var logic                                   axi_st_rxegrts1_tvalid_i
    ,input var logic [RXIGR_TS_DW-1:0]                 axi_st_rxegrts1_tdata_i
	
     // rx egress timestamp to DMA interface
    ,output var logic                                  axi_st_rxegrts0_tvalid_o
    ,output var logic [RXIGR_TS_DW-1:0]                axi_st_rxegrts0_tdata_o
     
    ,output var logic                                  axi_st_rxegrts1_tvalid_o
    ,output var logic [RXIGR_TS_DW-1:0]                axi_st_rxegrts1_tdata_o
	     

     );


   logic clk, rst;

   always_comb begin
      clk = rx_clk_i;
   end

   //------------------------------------------------------------------------------------------
   // reset
   ipbb_asyn_to_syn_rst rst_sync
     (.clk (clk)
      ,.asyn_rst (!rx_areset_n_i)

      // output
      ,.syn_rst (rst)
      );
    
   logic [31:0] rst_reg;
   // Generate arrays of reset to be used in submodule
   always_ff @(posedge clk) begin
      rst_reg <= '{default:rst};
   end
   
   //==========================================================================================
   localparam TUSER_CLIENT_WIDTH        = 7;
   localparam TUSER_STS_WIDTH           = 5;
   localparam TUSER_STS_EXT_WIDTH       = 32;
   localparam TUSER_SEG_PARITY_WIDTH    = HSSI_NUM_OF_SEG;
   localparam DMA_SEG_PARITY_WIDTH      = DMA_NUM_OF_SEG;
   
   localparam HSSI_TUSER_MD_WIDTH = TUSER_CLIENT_WIDTH
				   +TUSER_STS_WIDTH
				   +TUSER_STS_EXT_WIDTH
				   +DMA_SEG_PARITY_WIDTH ;

   localparam DMA_TUSER_MD_WIDTH =  TUSER_CLIENT_WIDTH
				   +TUSER_STS_WIDTH
				   +TUSER_STS_EXT_WIDTH
				   +DMA_SEG_PARITY_WIDTH;
   
   localparam IFIFO_DEPTH         = 512;
   localparam IFIFO_WIDTH         = $clog2(IFIFO_DEPTH);
   
   localparam EFIFO_DEPTH         = 512;
   localparam EFIFO_WIDTH         = $clog2(EFIFO_DEPTH);
   
   logic [HSSI_NUM_OF_SEG -1:0][HSSI_TUSER_MD_WIDTH -1:0] axi_st_rx_tuser_md_i;
   logic [DMA_NUM_OF_SEG-1:0][DMA_TUSER_MD_WIDTH -1:0] axi_st_rx_tuser_md_o;
   logic [HSSI_NUM_OF_SEG-1:0] mod_axi_st_rx_tuser_last_segment_i;

   logic rxets0_fifo_mty, rxets0_fifo_full, rxets0_fifo_lkahd, rxets0_fifo_ov, rxets0_fifo_ud,
	 rxets0_fifo_pop,
	 rxets1_fifo_mty, rxets1_fifo_full, rxets1_fifo_lkahd, rxets1_fifo_ov, rxets1_fifo_ud,
	 rxets1_fifo_pop, sop_state;
   logic [IFIFO_WIDTH -1:0] rxets0_fifo_cnt, rxets1_fifo_cnt;
   
   logic [DMA_NUM_OF_SEG-1:0][6:0]  rx_tuser_client_o, rx_tuser_client_reg;
   logic [DMA_NUM_OF_SEG-1:0][4:0]  rx_tuser_sts_o, rx_tuser_sts_reg;
   logic [DMA_NUM_OF_SEG-1:0][31:0] rx_tuser_sts_extended_o, rx_tuser_sts_extended_reg;
   logic [DMA_NUM_OF_SEG-1:0] 	    rx_tuser_pkt_seg_parity_o;
   
   always_comb begin
      for (int i = 0; i < HSSI_NUM_OF_SEG; i++) begin
	 axi_st_rx_tuser_md_i[i] = {axi_st_rx_tuser_client_i[i]
				    ,axi_st_rx_tuser_sts_i[i]
				    ,axi_st_rx_tuser_sts_extended_i[i]
				    ,axi_st_rx_tuser_pkt_seg_parity_i[i]
				    };

	 mod_axi_st_rx_tuser_last_segment_i[i] =
	   axi_st_rx_tvalid_i & axi_st_rx_tlast_i & axi_st_rx_tuser_last_segment_i[i];
	 
	 
      end
   end
   
   ipbb_axi_wdj_lg2sm
     #( .IDATA_WIDTH (HSSI_TDATA_WIDTH)
       ,.INUM_SEG (HSSI_NUM_OF_SEG)
       ,.ENUM_SEG (DMA_NUM_OF_SEG)
       ,.ITUSER_MD_WIDTH (HSSI_TUSER_MD_WIDTH )
       ,.ETUSER_MD_WIDTH (DMA_TUSER_MD_WIDTH)
       ,.TID_WIDTH (1)
       ,.IFIFO_DEPTH (IFIFO_DEPTH)    
       ,.EFIFO_DEPTH (EFIFO_DEPTH)
       
       
       ) axi_wdj_rx
   (
     .clk (clk)
    ,.rst (rst_reg[0])
    //-----------------------------------------------------------------------------------------
    // Ingress axi-st interface
    // outputs
    ,.trdy_o (axi_st_rx_tready_o)

    // inputs
    ,.tvld_i (axi_st_rx_tvalid_i)
    ,.tid_i ('0)
    ,.tdata_i (axi_st_rx_tdata_i)
    ,.tkeep_i (axi_st_rx_tkeep_i)
    ,.tuser_md_i (axi_st_rx_tuser_md_i)
    ,.terr_i ('0)
    ,.tlast_i (axi_st_rx_tlast_i)
    ,.tlast_segment_i (mod_axi_st_rx_tuser_last_segment_i)

    //-----------------------------------------------------------------------------------------
    // Egress axi-st interface
    // outputs
    ,.tvld_o (axi_st_rx_tvalid_o)
    ,.tid_o ()
    ,.tdata_o (axi_st_rx_tdata_o)
    ,.tkeep_o (axi_st_rx_tkeep_o)
    /*
    ,.tuser_md_o ({ axi_st_rx_tuser_client_o
		   ,axi_st_rx_tuser_sts_o
		   ,axi_st_rx_tuser_sts_extended_o
		   ,axi_st_rx_tuser_pkt_seg_parity_o
				    })*/
    ,.tuser_md_o ({ rx_tuser_client_o
		   ,rx_tuser_sts_o
		   ,rx_tuser_sts_extended_o
		   ,axi_st_rx_tuser_pkt_seg_parity_o
				    })
    ,.terr_o ()
    ,.tlast_o (axi_st_rx_tlast_o)
    ,.tlast_segment_o (axi_st_rx_tuser_last_segment_o)

    // inputs
    ,.trdy_i (axi_st_rx_tready_i)
   
    );

   

   
   always_ff @(posedge clk) begin
      if (axi_st_rx_tready_i & axi_st_rx_tvalid_o & axi_st_rx_tlast_o)
	sop_state <= '1;
      else if (sop_state & axi_st_rx_tready_i & axi_st_rx_tvalid_o)
	sop_state <= '0;
      
      if (rst_reg[3])
	sop_state <= '1;      
   end

   always_ff @(posedge clk) begin
      if (sop_state & axi_st_rx_tready_i & axi_st_rx_tvalid_o) begin
	 rx_tuser_client_reg       <= rx_tuser_client_o;
	 rx_tuser_sts_reg          <= rx_tuser_sts_o;
	 rx_tuser_sts_extended_reg <= rx_tuser_sts_extended_o;
      end
   end

   always_comb begin
      if (sop_state) begin
	 axi_st_rx_tuser_client_o       = rx_tuser_client_o;
	 axi_st_rx_tuser_sts_o          = rx_tuser_sts_o;
	 axi_st_rx_tuser_sts_extended_o = rx_tuser_sts_extended_o;
      end
      else begin
	 axi_st_rx_tuser_client_o       = rx_tuser_client_reg;
	 axi_st_rx_tuser_sts_o          = rx_tuser_sts_reg;
	 axi_st_rx_tuser_sts_extended_o = rx_tuser_sts_extended_reg;
      end
   end
   
   always_comb begin
      axi_st_rxegrts0_tvalid_o =
	sop_state & axi_st_rx_tready_i & axi_st_rx_tvalid_o & !rxets0_fifo_mty;
      rxets0_fifo_pop = axi_st_rxegrts0_tvalid_o;
      

      axi_st_rxegrts1_tvalid_o =
	sop_state & axi_st_rx_tready_i & axi_st_rx_tvalid_o & !rxets1_fifo_mty;

      rxets1_fifo_pop = axi_st_rxegrts1_tvalid_o;
      
   end
   
   //------------------------------------------------------------------------------------------
   // rxets0_fifo
   ipbb_scfifo_inff #(  .DWD (RXIGR_TS_DW )                  
		       ,.NUM_WORDS (IFIFO_DEPTH) ) rxets0_fifo
     (
      .clk (clk)
      ,.rst (rst_reg[1])

      // inputs
      ,.din (axi_st_rxegrts0_tdata_i)
      ,.wrreq (axi_st_rxegrts0_tvalid_i & axi_st_rx_tready_o)
      ,.rdreq (rxets0_fifo_pop)

      // outputs
      ,.dout (axi_st_rxegrts0_tdata_o)
      ,.rdempty (rxets0_fifo_mty)
      ,.wrfull (rxets0_fifo_full)
      ,.wrusedw (rxets0_fifo_cnt)
      ,.rdempty_lkahd (rxets0_fifo_lkahd)
      ,.overflow (rxets0_fifo_ov)
      ,.underflow (rxets0_fifo_ud)
      );
   
   //------------------------------------------------------------------------------------------
   // rxets1_fifo
   ipbb_scfifo_inff #(  .DWD (RXIGR_TS_DW )                  
		       ,.NUM_WORDS (IFIFO_DEPTH) ) rxets1_fifo
     (
      .clk (clk)
      ,.rst (rst_reg[2])

      // inputs
      ,.din (axi_st_rxegrts1_tdata_i)
      ,.wrreq (axi_st_rxegrts1_tvalid_i  & axi_st_rx_tready_o)
      ,.rdreq (rxets1_fifo_pop)

      // outputs
      ,.dout (axi_st_rxegrts1_tdata_o)
      ,.rdempty (rxets1_fifo_mty)
      ,.wrfull (rxets1_fifo_full)
      ,.wrusedw (rxets1_fifo_cnt)
      ,.rdempty_lkahd (rxets1_fifo_lkahd)
      ,.overflow (rxets1_fifo_ov)
      ,.underflow (rxets1_fifo_ud)
      );
   
endmodule // ptp_gbx_rx

   
