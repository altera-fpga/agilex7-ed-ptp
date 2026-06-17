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


//---------------------------------------------------------------------------------------------
// File editing rules:
//   - Columns MUST NOT EXCEED 95.
//   - Do not use TAB Function as indentation.
//   - Indentation must not be more 4.
//   - Please follow the editing rules.
//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------
// Description: axi-2-axi width adjustment from smaller number of segments to larger number 
//              of segments
//  Supports valid configuration
//  - ENUM_SEG = 1;  INUM_SEG = 1
//  - ENUM_SEG = 2;  INUM_SEG = 1
//  - ENUM_SEG = 4;  INUM_SEG = 1
//  - ENUM_SEG = 8;  INUM_SEG = 1
//  - ENUM_SEG = 16; INUM_SEG = 1
//
//  - Note: Number of bytes per segment must be the same for both ingress and egress
//----------------------------------------------------------------------------------------------

module ipbb_axi_wdj_sm2lg
 #(parameter  IDATA_WIDTH            = 1024      // supports the following setting
                                                 // 64, 128, 256, 512 and 1024
             ,IKEEP_WIDTH            = IDATA_WIDTH/8
             ,IBYTESVLD_WIDTH        = $clog2(IKEEP_WIDTH)
             ,INUM_SEG               = 16        
             ,INUM_SEG_WIDTH         = $clog2(INUM_SEG)
             ,IDATA_SEG_WIDTH        = IDATA_WIDTH/INUM_SEG    // data width per segment
             ,IKEEP_SEG_WIDTH        = IKEEP_WIDTH/INUM_SEG
             ,IBYTESVLD_SEG_WIDTH    = $clog2(IKEEP_SEG_WIDTH)   
             ,IFIFO_DEPTH            = 512
             ,IFIFO_WIDTH            = $clog2(IFIFO_DEPTH)

             ,ENUM_SEG               = 1 
             ,EDATA_WIDTH            = ENUM_SEG * IDATA_SEG_WIDTH 
             ,EKEEP_WIDTH            = EDATA_WIDTH/8
             ,EBYTESVLD_WIDTH        = $clog2(EKEEP_WIDTH)
            
             ,ENUM_SEG_WIDTH         = $clog2(ENUM_SEG)
             ,EDATA_SEG_WIDTH        = EDATA_WIDTH/ENUM_SEG   // data width per segment
             ,EKEEP_SEG_WIDTH        = EKEEP_WIDTH/ENUM_SEG
             ,EBYTESVLD_SEG_WIDTH    = $clog2(EKEEP_SEG_WIDTH)  
             ,EFIFO_DEPTH            = 2048 // to support Jumbo pkt, earlier value is 512
             ,EFIFO_WIDTH            = $clog2(EFIFO_DEPTH)
   
             ,ITUSER_MD_WIDTH         = 1
             ,ETUSER_MD_WIDTH         = 1   
             ,TID_WIDTH               = 3
 
             ,NUM_SOP                = 1    // only supports NUM_SOP=1
             ,SOP_ALIGN              = 1    // enable sop align during multi-segment mode
   )
   (
    input var logic                        clk
   ,input var logic                        rst       // active high sync to clk
   
   //------------------------------------------------------------------------------------------
   // Ingress axi-st interface
   ,output var logic                        trdy_o
   
   ,input var logic                         tvld_i
   ,input var logic [INUM_SEG -1:0]
                    [TID_WIDTH -1:0]        tid_i          // vld during sop of axi_st
   
   ,input var logic [INUM_SEG -1:0]
                    [IDATA_SEG_WIDTH -1:0]  tdata_i
   
   ,input var logic [INUM_SEG -1:0]
                    [IKEEP_SEG_WIDTH -1:0]  tkeep_i
   
   ,input var logic [INUM_SEG -1:0]
                    [ITUSER_MD_WIDTH -1:0]  tuser_md_i      // vld during sop of axi_st
   
   ,input var logic  [INUM_SEG -1:0]        terr_i         // error indiction.
                                                           // note: in multi-segment mode this
                                                           // could result in two packets get
                                                           // merge together with error at the
                                                           // egress.
   ,input var logic                         tlast_i
   ,input var logic [INUM_SEG -1:0]         tlast_segment_i
  

   //------------------------------------------------------------------------------------------
   // Egress axi-st interface
   ,input var logic                          trdy_i
   
   ,output var logic                         tvld_o
   ,output var logic [ENUM_SEG -1:0]
                     [TID_WIDTH -1:0]        tid_o          // vld during sop of axi_st
   
   ,output var logic [ENUM_SEG -1:0]
                     [EDATA_SEG_WIDTH -1:0]  tdata_o
   
   ,output var logic [ENUM_SEG -1:0]
                     [EKEEP_SEG_WIDTH -1:0]  tkeep_o
   
   ,output var logic [ENUM_SEG -1:0]
                     [ETUSER_MD_WIDTH -1:0]   tuser_md_o      // vld during sop of axi_st
   
   ,output var logic [ENUM_SEG -1:0]         terr_o        // error indiction.
                                                           // note: in multi-segment mode this
                                                           // could result in two packets get
                                                           // merge together with error at the
                                                           // egress.
   ,output var logic                         tlast_o
   ,output var logic [ENUM_SEG -1:0]         tlast_segment_o
  
    );

   logic [31:0] rst_reg;
   // Generate arrays of reset to be used in submodule
   always_ff @(posedge clk) begin
      rst_reg <= '{default:rst};
   end
   

   localparam CYC_CNT = (INUM_SEG > ENUM_SEG) ? INUM_SEG/ENUM_SEG :
			                        ENUM_SEG/INUM_SEG  ;
   localparam CYC_CNT_WIDTH = $clog2(CYC_CNT);
   
      
   logic ififo_push, ififo_pop, ififo_mty ,ififo_full, ififo_rdempty_lkahd, ififo_ov, 
	 ififo_ud,  tlast_r, efifo_rdy, ififo_tlast, ififo_data_vld;

   logic [IFIFO_WIDTH -1:0] ififo_cnt;

   logic [INUM_SEG -1:0] [TID_WIDTH -1:0] ififo_tid_r;
   logic [15:0] [TID_WIDTH -1:0]  tid_r;
   
   logic [INUM_SEG -1:0] [IDATA_SEG_WIDTH -1:0] ififo_tdata_r;
   logic [15:0] [IDATA_SEG_WIDTH -1:0] tdata_r;
   
   logic [INUM_SEG -1:0][IKEEP_SEG_WIDTH -1:0] ififo_tkeep_r;
   logic [15:0][IKEEP_SEG_WIDTH -1:0] tkeep_r;
   
   logic [INUM_SEG -1:0][ITUSER_MD_WIDTH -1:0] ififo_tuser_md_r;
   logic [15:0][ITUSER_MD_WIDTH -1:0] tuser_md_r;

   logic [INUM_SEG -1:0]  ififo_tlast_segment_r, ififo_terr_r;
   logic [15:0] tlast_segment_r, terr_r;
   
   logic [CYC_CNT_WIDTH -1:0]  cyc_cnt, nxt_cyc_cnt, ififo_cyc_cnt;
   
   

   //logic [4:0] inum_seg, enum_seg;

   logic [15:0] ififo_tlast_segment, ififo_terr;
   
   logic [15:0] [IKEEP_SEG_WIDTH -1:0] ififo_tkeep;
   
   logic [15:0] [IDATA_SEG_WIDTH -1:0] ififo_tdata;

   logic [15:0] [ITUSER_MD_WIDTH -1:0] ififo_tuser_md;
   
   logic [15:0] [TID_WIDTH -1:0]       ififo_tid;
   
   logic efifo_tlast_w, efifo_tlast_r, 
	 efifo_push, efifo_pop, efifo_mty, efifo_full, 
	 efifo_rdempty_lkahd, efifo_ov, efifo_ud ;
   
   logic [EFIFO_WIDTH -1:0] efifo_cnt;
   
   logic [ENUM_SEG -1:0] [TID_WIDTH -1:0] efifo_tid_w, efifo_tid_r;   
   logic [ENUM_SEG -1:0] [ETUSER_MD_WIDTH -1:0] efifo_tuser_md_w, efifo_tuser_md_r;
   logic [ENUM_SEG -1:0] [EDATA_SEG_WIDTH -1:0] efifo_tdata_w, efifo_tdata_r;
   logic [ENUM_SEG -1:0] [EKEEP_SEG_WIDTH -1:0] efifo_tkeep_w, efifo_tkeep_r;
   logic [ENUM_SEG -1:0] efifo_terr_w, efifo_terr_r,
			 efifo_tlast_segment_w, efifo_tlast_segment_r;
   
   
   localparam IFIFO_FC_WM = IFIFO_DEPTH - 32;
   localparam EFIFO_FC_WM = EFIFO_DEPTH - 32;


   logic [ETUSER_MD_WIDTH -1:0] efifo_tuser_md_w_0, efifo_tuser_md_r_0;
   always_comb begin
      efifo_tuser_md_w_0 = efifo_tuser_md_w[0];
      efifo_tuser_md_r_0 = efifo_tuser_md_r[0];
      
   end
   
   //------------------------------------------------------------------------------------------
   always_comb begin
      trdy_o =  rst ? '0 : ififo_cnt < IFIFO_FC_WM;
      
      // push to ififo
      ififo_push = trdy_o & tvld_i;      
   end

   always_comb begin
      if (!ififo_mty & tlast_r & (SOP_ALIGN == 1) & efifo_rdy)
	nxt_cyc_cnt = '0;
      else if (!ififo_mty & efifo_rdy)
	nxt_cyc_cnt = cyc_cnt + 1'b1;     
      else
	nxt_cyc_cnt = cyc_cnt;
   end

   always_ff @(posedge clk) begin
      cyc_cnt <= nxt_cyc_cnt;
      
      if (rst_reg[0])
	cyc_cnt <= '0;
   end

   always_comb begin
      efifo_rdy = efifo_cnt < EFIFO_FC_WM;
      
      ififo_pop = !ififo_mty & efifo_rdy ;
   end

   generate
      if (ENUM_SEG == 16) begin
	 always_ff @(posedge clk) begin
	    case (cyc_cnt)
	      'd0: begin
		 ififo_tuser_md[0]       <= tuser_md_r[0];
		 ififo_tlast_segment[0]  <= tlast_segment_r[0];
		 ififo_tkeep[0]          <= tkeep_r[0];
		 ififo_tdata[0]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:1]       <= '0;		 
	      end
	      'd1: begin
		 ififo_tuser_md[1]       <= tuser_md_r[0];
		 ififo_tlast_segment[1]  <= tlast_segment_r[0];
		 ififo_tkeep[1]          <= tkeep_r[0];
		 ififo_tdata[1]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:2]       <= '0;
	      end
	      'd2: begin
		 ififo_tuser_md[2]       <= tuser_md_r[0];
		 ififo_tlast_segment[2]  <= tlast_segment_r[0];
		 ififo_tkeep[2]          <= tkeep_r[0];
		 ififo_tdata[2]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:3]       <= '0;
	      end
	      'd3: begin
		 ififo_tuser_md[3]       <= tuser_md_r[0];
		 ififo_tlast_segment[3]  <= tlast_segment_r[0];
		 ififo_tkeep[3]          <= tkeep_r[0];
		 ififo_tdata[3]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:4]       <= '0;
	      end
	      'd4: begin
		 ififo_tuser_md[4]       <= tuser_md_r[0];
		 ififo_tlast_segment[4]  <= tlast_segment_r[0];
		 ififo_tkeep[4]          <= tkeep_r[0];
		 ififo_tdata[4]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:5]       <= '0;
	      end
	      'd5: begin
		 ififo_tuser_md[5]       <= tuser_md_r[0];
		 ififo_tlast_segment[5]  <= tlast_segment_r[0];
		 ififo_tkeep[5]          <= tkeep_r[0];
		 ififo_tdata[5]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:6]       <= '0;
	      end
	      'd6: begin
		 ififo_tuser_md[6]       <= tuser_md_r[0];
		 ififo_tlast_segment[6]  <= tlast_segment_r[0];
		 ififo_tkeep[6]          <= tkeep_r[0];
		 ififo_tdata[6]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:7]       <= '0;
	      end
	      'd7: begin
		 ififo_tuser_md[7]       <= tuser_md_r[0];
		 ififo_tlast_segment[7]  <= tlast_segment_r[0];
		 ififo_tkeep[7]          <= tkeep_r[0];
		 ififo_tdata[7]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:8]       <= '0;
	      end
	      'd8: begin
		 ififo_tuser_md[8]       <= tuser_md_r[0];
		 ififo_tlast_segment[8]  <= tlast_segment_r[0];
		 ififo_tkeep[8]          <= tkeep_r[0];
		 ififo_tdata[8]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:9]       <= '0;
	      end
	      'd9: begin
		 ififo_tuser_md[9]       <= tuser_md_r[0];
		 ififo_tlast_segment[9]  <= tlast_segment_r[0];
		 ififo_tkeep[9]          <= tkeep_r[0];
		 ififo_tdata[9]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:10]      <= '0;
	      end
	      'd10: begin
		 ififo_tuser_md[10]       <= tuser_md_r[0];
		 ififo_tlast_segment[10]  <= tlast_segment_r[0];
		 ififo_tkeep[10]          <= tkeep_r[0];
		 ififo_tdata[10]          <= tdata_r[0];
		 ififo_data_vld           <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:11]       <= '0;
	      end
	      'd11: begin
		 ififo_tuser_md[11]       <= tuser_md_r[0];
		 ififo_tlast_segment[11]  <= tlast_segment_r[0];
		 ififo_tkeep[11]          <= tkeep_r[0];
		 ififo_tdata[11]          <= tdata_r[0];
		 ififo_data_vld           <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:12]       <= '0;
	      end
	      'd12: begin
		 ififo_tuser_md[12]       <= tuser_md_r[0];
		 ififo_tlast_segment[12]  <= tlast_segment_r[0];
		 ififo_tkeep[12]          <= tkeep_r[0];
		 ififo_tdata[12]          <= tdata_r[0];
		 ififo_data_vld           <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:13]       <= '0;
	      end
	      'd13: begin
		 ififo_tuser_md[13]       <= tuser_md_r[0];
		 ififo_tlast_segment[13]  <= tlast_segment_r[0];
		 ififo_tkeep[13]          <= tkeep_r[0];
		 ififo_tdata[13]          <= tdata_r[0];
		 ififo_data_vld           <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15:14]       <= '0;
	      end
	      'd14: begin
		 ififo_tuser_md[14]       <= tuser_md_r[0];
		 ififo_tlast_segment[14]  <= tlast_segment_r[0];
		 ififo_tkeep[14]          <= tkeep_r[0];
		 ififo_tdata[14]          <= tdata_r[0];
		 ififo_data_vld           <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[15]          <= '0;
	      end
	      default: begin
		 ififo_tuser_md[15]       <= tuser_md_r[0];
		 ififo_tlast_segment[15]  <= tlast_segment_r[0];
		 ififo_tkeep[15]          <= tkeep_r[0];
		 ififo_tdata[15]          <= tdata_r[0];
		 ififo_data_vld           <= (ififo_pop);
	      end
	    endcase // case (cyc_cnt)

	    ififo_tlast    <= tlast_r;
	    ififo_tid      <= tid_r;
	    ififo_terr     <= terr_r;
	    
	    if (rst_reg[0]) begin
	       ififo_data_vld      <= '0;
	       ififo_tdata         <= '0;
	       ififo_tkeep         <= '0;
	       ififo_tlast_segment <= '0;
	    end
	 end // always_ff @ (posedge clk)	 
      end // if (ENUM_SEG == 16)
      
      else if (ENUM_SEG == 8) begin
	 always_ff @(posedge clk) begin
	    case (cyc_cnt)
	      'd0: begin
		 ififo_tuser_md[0]       <= tuser_md_r[0];
		 ififo_tlast_segment[0]  <= tlast_segment_r[0];
		 ififo_tkeep[0]          <= tkeep_r[0];
		 ififo_tdata[0]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[7:1]        <= '0;
	      end
	      'd1: begin
		 ififo_tuser_md[1]       <= tuser_md_r[0];
		 ififo_tlast_segment[1]  <= tlast_segment_r[0];
		 ififo_tkeep[1]          <= tkeep_r[0];
		 ififo_tdata[1]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[7:2]        <= '0;
	      end
	      'd2: begin
		 ififo_tuser_md[2]       <= tuser_md_r[0];
		 ififo_tlast_segment[2]  <= tlast_segment_r[0];
		 ififo_tkeep[2]          <= tkeep_r[0];
		 ififo_tdata[2]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[7:3]        <= '0;
	      end
	      'd3: begin
		 ififo_tuser_md[3]       <= tuser_md_r[0];
		 ififo_tlast_segment[3]  <= tlast_segment_r[0];
		 ififo_tkeep[3]          <= tkeep_r[0];
		 ififo_tdata[3]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[7:4]        <= '0;
	      end
	      'd4: begin
		 ififo_tuser_md[4]       <= tuser_md_r[0];
		 ififo_tlast_segment[4]  <= tlast_segment_r[0];
		 ififo_tkeep[4]          <= tkeep_r[0];
		 ififo_tdata[4]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[7:5]        <= '0;
	      end
	      'd5: begin
		 ififo_tuser_md[5]       <= tuser_md_r[0];
		 ififo_tlast_segment[5]  <= tlast_segment_r[0];
		 ififo_tkeep[5]          <= tkeep_r[0];
		 ififo_tdata[5]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[7:6]        <= '0;
	      end
	      'd6: begin
		 ififo_tuser_md[6]       <= tuser_md_r[0];
		 ififo_tlast_segment[6]  <= tlast_segment_r[0];
		 ififo_tkeep[6]          <= tkeep_r[0];
		 ififo_tdata[6]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[7]          <= '0;
	      end
	      default: begin
		 ififo_tuser_md[7]       <= tuser_md_r[0];
		 ififo_tlast_segment[7]  <= tlast_segment_r[0];
		 ififo_tkeep[7]          <= tkeep_r[0];
		 ififo_tdata[7]          <= tdata_r[0];
		 ififo_data_vld          <= ififo_pop;
	      end
	    endcase // case (cyc_cnt)		

	    ififo_tlast    <= tlast_r;
	    ififo_tid      <= tid_r;
	    ififo_terr     <= terr_r;
	    
	    if (rst_reg[0]) begin
	       ififo_data_vld      <= '0;
	       ififo_tdata         <= '0;
	       ififo_tkeep         <= '0;
	       ififo_tlast_segment <= '0;
	    end
	 end
      end // if (ENUM_SEG == 8)

      else if (ENUM_SEG == 4) begin
	 always_ff @(posedge clk) begin
	    case (cyc_cnt)
	      'd0: begin
		 ififo_tuser_md[0]       <= tuser_md_r[0];
		 ififo_tlast_segment[0]  <= tlast_segment_r[0];
		 ififo_tkeep[0]          <= tkeep_r[0];
		 ififo_tdata[0]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[3:1]        <= '0;
	      end
	      'd1: begin
		 ififo_tuser_md[1]       <= tuser_md_r[0];
		 ififo_tlast_segment[1]  <= tlast_segment_r[0];
		 ififo_tkeep[1]          <= tkeep_r[0];
		 ififo_tdata[1]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[3:2]        <= '0;
	      end
	      'd2: begin
		 ififo_tuser_md[2]       <= tuser_md_r[0];
		 ififo_tlast_segment[2]  <= tlast_segment_r[0];
		 ififo_tkeep[2]          <= tkeep_r[0];
		 ififo_tdata[2]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[3]          <= '0;
	      end
	      'd3: begin
		 ififo_tuser_md[3]       <= tuser_md_r[0];
		 ififo_tlast_segment[3]  <= tlast_segment_r[0];
		 ififo_tkeep[3]          <= tkeep_r[0];
		 ififo_tdata[3]          <= tdata_r[0];
		 ififo_data_vld          <= ififo_pop;
	      end
	    endcase
	    ififo_tlast    <= tlast_r;
	    ififo_tid      <= tid_r;
	    ififo_terr     <= terr_r;
	    
	    if (rst_reg[0]) begin
	       ififo_data_vld      <= '0;
	       ififo_tdata         <= '0;
	       ififo_tkeep         <= '0;
	       ififo_tlast_segment <= '0;
	    end
	 end
      end // if (ENUM_SEG == 4)
      
      else if (ENUM_SEG == 2) begin
	 always_ff @(posedge clk) begin
	    case (cyc_cnt)
	      'd0: begin
		 ififo_tuser_md[0]       <= tuser_md_r[0];
		 ififo_tlast_segment[0]  <= tlast_segment_r[0];
		 ififo_tkeep[0]          <= tkeep_r[0];
		 ififo_tdata[0]          <= tdata_r[0];
		 ififo_data_vld          <= (ififo_pop & tlast_r & (SOP_ALIGN == 1));
		 ififo_tkeep[1]          <= '0;
	      end
	      default: begin
		 ififo_tuser_md[1]       <= tuser_md_r[0];
		 ififo_tlast_segment[1]  <= tlast_segment_r[0];
		 ififo_tkeep[1]          <= tkeep_r[0];
		 ififo_tdata[1]          <= tdata_r[0];
		 ififo_data_vld          <= ififo_pop;
		 
	      end
	    endcase // case (cyc_cnt)
	    ififo_tlast    <= tlast_r;
	    ififo_tid      <= tid_r;
	    ififo_terr     <= terr_r;
	    
	    if (rst_reg[0]) begin
	       ififo_data_vld      <= '0;
	       ififo_tdata         <= '0;
	       ififo_tkeep         <= '0;
	       ififo_tlast_segment <= '0;
	    end
	 end // always_ff @ (posedge clk)	 
      end // if (ENUM_SEG == 2)

      else begin
	 always_ff @(posedge clk) begin
	    ififo_tuser_md[0]       <= tuser_md_r[0];
	    ififo_tlast_segment[0]  <= tlast_segment_r[0];
	    ififo_tkeep[0]          <= tkeep_r[0];
	    ififo_tdata[0]          <= tdata_r[0];
	    ififo_data_vld          <= ififo_pop;

	    ififo_tlast    <= tlast_r;
	    ififo_tid      <= tid_r;
	    ififo_terr     <= terr_r;
	    
	    if (rst_reg[0]) begin
	       ififo_data_vld      <= '0;
	       ififo_tdata         <= '0;
	       ififo_tkeep         <= '0;
	       ififo_tlast_segment <= '0;
	    end
	 end

      end // else: !if(ENUM_SEG == 2)
   endgenerate

    
   generate
      if (ENUM_SEG == 1) begin
	 always_comb begin
	    efifo_push    = ififo_data_vld ;
	    
	    efifo_tdata_w         = ififo_tdata[0];
	    efifo_tkeep_w         = ififo_tkeep[0];
	    efifo_tlast_segment_w = ififo_tlast_segment[0] ;
	    efifo_tid_w           = ififo_tid[0];
	    efifo_tuser_md_w      = ififo_tuser_md[0];
	    efifo_tlast_w         = ififo_tlast;
	    efifo_terr_w          = ififo_terr[0];

	    tlast_segment_o = efifo_tlast_segment_r[0];
	 end
      end // if (ENUM_SEG == 1)

      else if (ENUM_SEG == 2) begin
	 always_comb begin
	    efifo_push    = ififo_data_vld ;
	    
	    efifo_tdata_w         = ififo_tdata[1:0];
	    efifo_tkeep_w         = ififo_tkeep[1:0];
	    efifo_tlast_segment_w = ififo_tlast_segment[1:0] ;
	    efifo_tid_w           = ififo_tid[1:0];
	    efifo_tuser_md_w      = ififo_tuser_md[1:0];
	    efifo_tlast_w         = ififo_tlast;
	    efifo_terr_w          = ififo_terr[1:0];

	    tlast_segment_o = efifo_tlast_segment_r[1:0];
	 end
      end // if (ENUM_SEG == 2)
      
      else if (ENUM_SEG == 4) begin
	 always_comb begin
	    efifo_push    = ififo_data_vld ;
	    
	    efifo_tdata_w         = ififo_tdata[3:0];
	    efifo_tkeep_w         = ififo_tkeep[3:0];
	    efifo_tlast_segment_w = ififo_tlast_segment[3:0] ;
	    efifo_tid_w           = ififo_tid[3:0];
	    efifo_tuser_md_w      = ififo_tuser_md[3:0];
	    efifo_tlast_w         = ififo_tlast;
	    efifo_terr_w          = ififo_terr[3:0];

	    tlast_segment_o = efifo_tlast_segment_r[3:0];
	 end
      end // if (ENUM_SEG == 4)
      
      else if (ENUM_SEG == 8) begin
	 always_comb begin
	    efifo_push    = ififo_data_vld ;
	    
	    efifo_tdata_w         = ififo_tdata[7:0];
	    efifo_tkeep_w         = ififo_tkeep[7:0];
	    efifo_tlast_segment_w = ififo_tlast_segment[7:0] ;
	    efifo_tid_w           = ififo_tid[7:0];
	    efifo_tuser_md_w      = ififo_tuser_md[7:0];
	    efifo_tlast_w         = ififo_tlast;
	    efifo_terr_w          = ififo_terr[7:0];

	    tlast_segment_o = efifo_tlast_segment_r[7:0];
	 end
      end // if (ENUM_SEG == 8)

      else begin
	 always_comb begin
	    efifo_push    = ififo_data_vld ;
	    
	    efifo_tdata_w         = ififo_tdata[15:0];
	    efifo_tkeep_w         = ififo_tkeep[15:0];
	    efifo_tlast_segment_w = ififo_tlast_segment[15:0] ;
	    efifo_tid_w           = ififo_tid[15:0];
	    efifo_tuser_md_w      = ififo_tuser_md[15:0];
	    efifo_tlast_w         = ififo_tlast;
	    efifo_terr_w          = ififo_terr[15:0];

	    tlast_segment_o = efifo_tlast_segment_r[15:0];
	 end
      end // else: !if(ENUM_SEG == 8)
   endgenerate
   
   //------------------------------------------------------------------------------------------
   // egress interface
   always_comb begin
      efifo_pop = trdy_i & !efifo_mty;
      
      tvld_o = !efifo_mty;
      tid_o = efifo_tid_r;
      tdata_o = efifo_tdata_r;
      tkeep_o = efifo_tkeep_r;
      tuser_md_o = efifo_tuser_md_r;
      terr_o     = efifo_terr_r;
      tlast_o    = efifo_tlast_r;

      /*
      case (ENUM_SEG)
	// ENUM_SEG = 1
	'd1: tlast_segment_o = efifo_tlast_segment_r[0];
	// ENUM_SEG = 2
	'd2: tlast_segment_o = efifo_tlast_segment_r[1:0];
	// ENUM_SEG = 4
	'd4: tlast_segment_o = efifo_tlast_segment_r[3:0];
	// ENUM_SEG = 8
	'd8: tlast_segment_o = efifo_tlast_segment_r[7:0];
	// ENUM_SEG = 16
	default: tlast_segment_o = efifo_tlast_segment_r[15:0];
      endcase*/
   end
   
   //------------------------------------------------------------------------------------------
   // ingress fifo
   ipbb_scfifo_inff #(  .DWD ( (INUM_SEG*IDATA_SEG_WIDTH)
			      +(INUM_SEG*TID_WIDTH)
			      +(INUM_SEG*IKEEP_SEG_WIDTH)
			      +INUM_SEG
			      +1
			      +(INUM_SEG*ITUSER_MD_WIDTH)
			      +INUM_SEG )
		       ,.NUM_WORDS (IFIFO_DEPTH) ) ififo
     (
      .clk (clk)
      ,.rst (rst_reg[0])

      // inputs
      ,.din ({ tdata_i
	      ,tid_i
	      ,tkeep_i
	      ,tlast_segment_i
	      ,tlast_i
	      ,tuser_md_i
	      ,terr_i})
      ,.wrreq (ififo_push)
      ,.rdreq (ififo_pop)

      // outputs
      ,.dout ({ ififo_tdata_r
	       ,ififo_tid_r
	       ,ififo_tkeep_r
	       ,ififo_tlast_segment_r
	       ,ififo_tlast_r
	       ,ififo_tuser_md_r
	       ,ififo_terr_r})
      ,.rdempty (ififo_mty)
      ,.wrfull (ififo_full)
      ,.wrusedw (ififo_cnt)
      ,.rdempty_lkahd (ififo_rdempty_lkahd)
      ,.overflow (ififo_ov)
      ,.underflow (ififo_ud)
      );

      // mapping read data from ififo
   always_comb begin
      tdata_r         = '0;
      tid_r           = '0;
      tkeep_r         = '0;
      tlast_segment_r = '0;
      tuser_md_r      = '0;
      terr_r          = '0;     
      tlast_r         = ififo_tlast_r;

      // INUM_SEG = 1
      tdata_r[0]         = ififo_tdata_r;
      tid_r[0]           = ififo_tid_r;
      tkeep_r[0]         = ififo_tkeep_r;
      tlast_segment_r[0] = ififo_tlast_segment_r;
      tuser_md_r[0]      = ififo_tuser_md_r;
      terr_r[0]          = ififo_terr_r;
   end

   //------------------------------------------------------------------------------------------
   // egress fifo
   ipbb_sfw_fifo #(  .DW ( (ENUM_SEG*EDATA_SEG_WIDTH)
			      +(ENUM_SEG*TID_WIDTH)
			      +(ENUM_SEG*EKEEP_SEG_WIDTH)
			      +ENUM_SEG
			      +1
			      +(ENUM_SEG*ETUSER_MD_WIDTH)
			      +ENUM_SEG )
		       ,.DEPTH (EFIFO_DEPTH) ) efifo
     (
      .clk (clk)
      ,.rst (rst_reg[1])

      // inputs
      ,.din ({ efifo_tdata_w
	      ,efifo_tid_w
	      ,efifo_tkeep_w
	      ,efifo_tlast_segment_w
	      ,efifo_tlast_w
	      ,efifo_tuser_md_w
	      ,efifo_terr_w})
      ,.push (efifo_push)
      ,.rel_ptr (efifo_push & efifo_tlast_w)
      ,.pop (efifo_pop)

      // outputs
      ,.dout ({efifo_tdata_r
	      ,efifo_tid_r
	      ,efifo_tkeep_r
	      ,efifo_tlast_segment_r
	      ,efifo_tlast_r
	      ,efifo_tuser_md_r
	      ,efifo_terr_r})
      ,.empty (efifo_mty)
      ,.full (efifo_full)
      ,.cnt (efifo_cnt)
      ,.overflow (efifo_ov)
      ,.underflow (efifo_ud)
      );



endmodule // ipbb_axi_wdj_lg2sm

    

    

				       
