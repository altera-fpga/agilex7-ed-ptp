//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

`timescale 1 ps / 1 ps
module multiseg_singleseg_conv 
  #(
    parameter  DATA_W = 64  // supports 64/128/512b
   ,parameter  USER_W = 10   
   ,parameter  USER_STS_W = 10   
   ,parameter  USER_CLIENT_W = 10   
   ,parameter  USER_TS_IGR_W = 96  
 )
  (
  input 		    i_clk,
  input	            i_rstn,
  
  axis_if.source    axis_tx_if,
  axis_if.sink      axis_rx_if 
);

import macsec_srd_pkg::*;

 localparam FIFO_DEPTH           	  	 = 4;
 localparam [3:0]PKT_COUNTER_WIDTH	 	 = 4'd4;
 localparam TUSER_W 				          = $bits(axis_rx_if.tuser_last_segment);
 localparam TUSER_STS_W 				    = $bits(axis_rx_if.tuser_sts);
 localparam TUSER_CLIENT_W 				 = $bits(axis_rx_if.tuser_client);
 localparam TUSER_TS_IGR_W 				 = $bits(axis_rx_if.tuser_ts_igr_data);
 localparam TDATA 				          = $bits(axis_rx_if.tdata);
 localparam TKEEP 				          = $bits(axis_rx_if.tdata)/8;
 localparam FIFO_DATA_WIDTH 	          = 1 + TKEEP + TDATA + TUSER_W + TUSER_STS_W + TUSER_CLIENT_W + 1 + TUSER_TS_IGR_W;
 localparam SEGMENT_W                   = 64;
 localparam EMPTY_WIDTH                 = $clog2(TDATA/8)+1; 
 
 logic [FIFO_DATA_WIDTH-1:0]            fifo_wdata;
 logic [FIFO_DATA_WIDTH-1:0]            fifo_rdata;
 logic 				                      fifo_wreq;
 logic 				                      fifo_full;
 logic 			                         fifo_rdempty;
 logic 				                      fifo_r_valid;	
 logic [TUSER_W-1:0]		                fifo_rd_data_tuser;
 logic [TDATA-1:0]		                fifo_rd_data_tdata;
 logic [TKEEP-1:0]		                fifo_rd_data_tkeep;
 logic            	                   fifo_rd_data_tlast;
 logic [TKEEP-1:0]		                merger_tkeep;
 logic [TUSER_W-1:0]		                merger_tuser;
 logic 					                   merger_tlast;
 logic 					                   merger_tready;
 logic [TDATA-1:0]                      merger_din; 
 logic [TDATA-1:0]                      hold_data; 
 logic [TDATA-1:0]                      hold_data_del; 
 logic [TDATA-1:0]                      hold_data_pipe; 
 logic                                  hold_tvalid_pipe;
 logic                                  hold_tlast_pipe;
 logic 				                    fifo_rdack;
 logic 				                    fifo_rdreq;
 logic 				                    hold_valid;
 logic [TKEEP-1:0]		                hold_tkeep;
 logic [TKEEP-1:0]		                hold_tkeep_del;
 logic [TKEEP-1:0]		                hold_tkeep_pipe;
 logic [TUSER_W-1:0]		            hold_tuser;
 logic 					                hold_tlast;
 logic [TKEEP-1:0]		                fifo_tkeep_mod;
 logic [TKEEP-1:0]		                hold_tkeep_mod;
 logic 					                   hold_valid_mod;
 logic [TDATA-1:0]                      hold_tdata_mod;
 logic                                  stall_pipeline;
 logic                                  frame_in_prog;
 logic                                  frame_start;
 logic                                  frame_end;
 logic                                  tmp_avst_rx_sop;
 logic [EMPTY_WIDTH-1:0] rx_st_wbc_stg0,rx_st_wbc_stg1,rx_st_empty0,rx_st_empty1,current_valid_bytes,current_valid_bytes_reg;
 logic [EMPTY_WIDTH-1:0] rx_st_wbc_stg0_reg,rx_st_empty0_reg;
 logic [EMPTY_WIDTH-1:0] sop_empty_bytes,eop_empty_bytes;
 logic frame_multiseg;
 logic [TUSER_W-1:0]	      hold_tuser_last_segment_del; 
 logic [TUSER_W-1:0]          hold_tuser_last_segment;
 logic [TUSER_TS_IGR_W-1:0]	hold_tuser_ts_igr_data;

  //----------------------------------------------
  // FIFO write logic
  //----------------------------------------------
  
  assign fifo_wdata        	= {axis_rx_if.tlast,axis_rx_if.tkeep,axis_rx_if.tdata,axis_rx_if.tuser_last_segment, axis_rx_if.tuser_sts, axis_rx_if.tuser_client, axis_rx_if.tuser_ts_igr_data, axis_rx_if.tuser_ts_igr_valid};
  assign fifo_wreq	         = axis_rx_if.tvalid & axis_rx_if.tready;
  //assign fifo_wreq	         = axis_rx_if.tvalid & merger_tready;
 
  //----------------------------------------------
  // Backpressure 
  //----------------------------------------------
   
   assign axis_rx_if.tready         = !fifo_full;

  //----------------------------------------------
  // SCFIFO Instance
  //----------------------------------------------  
  
  fim_scfifo  #(
     .DATA_WIDTH (FIFO_DATA_WIDTH),
	 .DEPTH_LOG2 (FIFO_DEPTH),
	 .SHOWAHEAD  ("ON")
	 )
  fim_scfifo_inst(
     .clk    (i_clk),
     .sclr	 (0),
     .w_data (fifo_wdata),
     .w_req  (fifo_wreq),
     .r_req  (fifo_rdreq),
     .r_data (fifo_rdata),
     .w_usedw(),
     .r_usedw(),
     .w_full (fifo_full),
     .w_ready(),
     .r_empty(fifo_rdempty),
     .r_valid (fifo_r_valid) // r_valid is set when r_data is valid.
	  );

 integer i;
  //----------------------------------------------
  // FIFO read logic
  //----------------------------------------------  
  assign fifo_rdreq = axis_tx_if.tready  & ~fifo_rdempty & !stall_pipeline;
  
  //----------------------------------------------
  // pipeline_stage0
  //----------------------------------------------  
   
 axis_if #(.DATA_W(DATA_W),.USER_W(USER_W),.USER_STS_W(USER_STS_W),.USER_CLIENT_W(USER_CLIENT_W), .USER_TS_IGR_W(USER_TS_IGR_W)) multiseg_stage0();
 
  always @(posedge i_clk) begin
  if(!i_rstn) begin
    multiseg_stage0.tdata               <=  'd0;
    multiseg_stage0.tvalid              <=  'd0;
    multiseg_stage0.tlast               <=  'd0;
    multiseg_stage0.tuser_last_segment  <=  'd0;
    multiseg_stage0.tuser_sts           <=  'd0;
    multiseg_stage0.tuser_client        <=  'd0;
    multiseg_stage0.tuser_ts_igr_data   <=  'd0;
    multiseg_stage0.tuser_ts_igr_valid  <=  'd0;
    multiseg_stage0.tkeep               <=  'd0;
  end 
  else if(axis_tx_if.tready & fifo_rdreq)begin
    {multiseg_stage0.tlast,multiseg_stage0.tkeep,multiseg_stage0.tdata,multiseg_stage0.tuser_last_segment,multiseg_stage0.tuser_sts,multiseg_stage0.tuser_client,multiseg_stage0.tuser_ts_igr_data,multiseg_stage0.tuser_ts_igr_valid,multiseg_stage0.tvalid} <= {fifo_rdata,fifo_rdreq};
	  //multiseg_stage0.tvalid <= fifo_rdreq;
    end
  else begin
    multiseg_stage0.tdata               <=  'd0;
    multiseg_stage0.tvalid              <=  'd0;
    multiseg_stage0.tlast               <=  'd0;
    multiseg_stage0.tuser_last_segment  <=  'd0;
    multiseg_stage0.tuser_sts           <=  'd0;
    multiseg_stage0.tuser_client        <=  'd0;
    multiseg_stage0.tuser_ts_igr_data   <=  'd0;
    multiseg_stage0.tuser_ts_igr_valid  <=  'd0;
    multiseg_stage0.tkeep               <=  'd0;
  end	
  end
   //----------------------------------------------
  //  Multisegment detection
  //----------------------------------------------  
  always_comb begin
    fifo_tkeep_mod = multiseg_stage0.tkeep;
  for(int i=1;i<TUSER_W-2;i++)
    if(multiseg_stage0.tuser_last_segment[i-1])// & fifo_rd_data_tlast)
      fifo_tkeep_mod = multiseg_stage0.tkeep & ~({TKEEP{1'b1}} << (i*8));
   end
 
 always_comb begin 
    hold_tkeep_mod ='0;
  for(int i=1;i<TUSER_W-2;i++)
    if(multiseg_stage0.tuser_last_segment[i-1])begin
	    hold_tkeep_mod =( multiseg_stage0.tkeep >> (i*8));
	end
  end
  
  always_comb begin
    //hold_valid_mod ='0;
    if (((sop_empty_bytes!=0) & tmp_avst_rx_sop) |frame_multiseg )
    hold_valid_mod = 1'b1;
    else
    hold_valid_mod ='0;
     for(int i=1;i<TUSER_W-2;i++)
      if(multiseg_stage0.tuser_last_segment[i-1])
      hold_valid_mod = (|(multiseg_stage0.tkeep  >> (i*8)));
  end
  
  //----------------------------------------------
  // Detection of sop
  //----------------------------------------------   

  assign frame_start = multiseg_stage0.tvalid;
  assign frame_end   = multiseg_stage0.tvalid  & multiseg_stage0.tlast ;
  
  always @(posedge i_clk, negedge i_rstn) begin
    if(!i_rstn) begin
      frame_in_prog <= 1'b0;
    end else begin
      frame_in_prog <= (frame_in_prog | frame_start) & ~frame_end;
      end
    end	
	
	assign tmp_avst_rx_sop   = multiseg_stage0.tvalid & ~frame_in_prog;
	
  //----------------------------------------------
  // Calculate eop_empty_bytes & sop_empty bytes 
  //---------------------------------------------- 
  
   always_comb begin
  eop_empty_bytes = 0;
    for(int i=0;i<TKEEP;i++)
      if(!multiseg_stage0.tkeep[TKEEP-1-i])
      eop_empty_bytes = i+1;
  end  

  always_comb begin
  sop_empty_bytes = 0;
    for(int i=0;i<TKEEP;i++)
      if(!multiseg_stage0.tkeep[i])
      sop_empty_bytes = i+1;
  end
  //----------------------------------------------
  // Detection of Multisegment packet
  //---------------------------------------------- 
  
  always @(posedge i_clk, negedge i_rstn) begin
    if(!i_rstn) begin
      frame_multiseg <= 1'b0;
    end else begin
      frame_multiseg <= (frame_multiseg | hold_valid) & ~multiseg_stage0.tlast;
  end
  end
  //----------------------------------------------
  // Detection of Nullbytes
  //----------------------------------------------  
  
  logic frame_null_bytes;
  always @(posedge i_clk, negedge i_rstn) begin
    if(!i_rstn) begin
      frame_null_bytes <= 1'b0;
    end else begin
      frame_null_bytes <= (frame_null_bytes| (tmp_avst_rx_sop & (sop_empty_bytes!=0)) )& ~multiseg_stage0.tlast & multiseg_stage0.tvalid;
  end
  end
  
  //----------------------------------------------
  // Calculation of valid_byte_count & empty_bytes
  //----------------------------------------------  
  
  assign current_valid_bytes = (multiseg_stage0.tlast & multiseg_stage0.tvalid ) | (multiseg_stage0.tvalid & tmp_avst_rx_sop & sop_empty_bytes!=0 )? (TKEEP - eop_empty_bytes) : current_valid_bytes_reg;
 
  always @(posedge i_clk) begin
    if((multiseg_stage0.tlast & multiseg_stage0.tvalid ) | (multiseg_stage0.tvalid & tmp_avst_rx_sop & sop_empty_bytes!=0 ))
     current_valid_bytes_reg <=  (TKEEP - eop_empty_bytes);
  end

 always @(posedge i_clk) begin
   if(multiseg_stage0.tlast | (tmp_avst_rx_sop & sop_empty_bytes!=0 ))
    rx_st_wbc_stg0_reg <= TKEEP - sop_empty_bytes; 
  end

assign rx_st_wbc_stg0 = (multiseg_stage0.tlast | (tmp_avst_rx_sop & sop_empty_bytes!=0 )) ? TKEEP - sop_empty_bytes : rx_st_wbc_stg0_reg ; 
//  always_comb begin
//   if(multiseg_stage0.tlast | (tmp_avst_rx_sop & sop_empty_bytes!=0 ))
//   rx_st_wbc_stg0 = TKEEP - sop_empty_bytes;  
//  end
 
 always @(posedge i_clk) begin
   if(multiseg_stage0.tlast | (tmp_avst_rx_sop & sop_empty_bytes!=0))
   rx_st_empty0_reg <= sop_empty_bytes;
  end
  assign rx_st_empty0 = (multiseg_stage0.tlast | (tmp_avst_rx_sop & sop_empty_bytes!=0)) ? sop_empty_bytes : rx_st_empty0_reg ;

// always_comb begin
//   if(multiseg_stage0.tlast | (tmp_avst_rx_sop & sop_empty_bytes!=0))
//   rx_st_empty0 = sop_empty_bytes;
//   end 

 //--------------------------------------------------------------------------------------------------
 //hold data during multisegment packet  
 // during multisegment packet(tlast), Second packet information right shift with empty_bytes times
 //--------------------------------------------------------------------------------------------------
   
  always @(posedge i_clk) begin
     hold_valid <= hold_valid_mod;
	 hold_tkeep_del <= hold_tkeep;
	 hold_data_del  <= hold_data;
	 hold_tuser_last_segment_del <= hold_tuser_last_segment;
	if (multiseg_stage0.tuser_ts_igr_valid)
	  hold_tuser_ts_igr_data  <= multiseg_stage0.tuser_ts_igr_data;
   if(multiseg_stage0.tvalid & (frame_multiseg | frame_null_bytes)  & multiseg_stage0.tlast  & (current_valid_bytes+ rx_st_wbc_stg1 > TKEEP )) begin
	   hold_tkeep <= multiseg_stage0.tkeep >> rx_st_empty1;
	   hold_data  <= multiseg_stage0.tdata >> rx_st_empty1*8;
	   hold_tuser_last_segment <= multiseg_stage0.tuser_last_segment;
	end
   else if( multiseg_stage0.tvalid & (multiseg_stage0.tlast | (tmp_avst_rx_sop & sop_empty_bytes!=0 )) &(current_valid_bytes+ rx_st_wbc_stg1 <= TKEEP ) ) begin
      hold_tkeep <= multiseg_stage0.tkeep >>rx_st_empty0;
	  hold_data  <= multiseg_stage0.tdata >>rx_st_empty0*8;
	  hold_tuser_last_segment <= multiseg_stage0.tuser_last_segment;
	 end
   else if( multiseg_stage0.tvalid & (frame_multiseg | frame_null_bytes | hold_valid) ) begin
      hold_tkeep <= multiseg_stage0.tkeep >> rx_st_empty1;
	  hold_data  <= multiseg_stage0.tdata >> rx_st_empty1*8;
      hold_tuser_last_segment <= multiseg_stage0.tuser_last_segment;
   end
   end	
 	    
  //----------------------------------------------
  // pipeline_stage1
  //----------------------------------------------   
  
  axis_if #(.DATA_W(DATA_W),.USER_W(USER_W),.USER_STS_W(USER_STS_W),.USER_CLIENT_W(USER_CLIENT_W),.USER_TS_IGR_W(USER_TS_IGR_W)) multiseg_stage1();

   always @(posedge i_clk) begin
   if(!i_rstn) begin
      multiseg_stage1.tdata              <=  'd0;
	  multiseg_stage1.tvalid             <=  'd0;
	  multiseg_stage1.tlast              <=  'd0;
	  multiseg_stage1.tuser_last_segment <=  'd0;
	  multiseg_stage1.tuser_sts          <=  'd0;
	  multiseg_stage1.tuser_client       <=  'd0;
      multiseg_stage1.tuser_ts_igr_data  <=  'd0;
	  multiseg_stage1.tkeep              <=  'd0;
	  stall_pipeline                     <=  1'b0;
	  rx_st_wbc_stg1                     <=  'd0;
   end 
   else begin

    if(axis_tx_if.tready & (frame_multiseg | frame_null_bytes)  & multiseg_stage0.tvalid  & multiseg_stage0.tlast) begin
       multiseg_stage1.tdata               <= (multiseg_stage0.tdata << rx_st_wbc_stg1*8) | hold_data;
       multiseg_stage1.tvalid              <= multiseg_stage0.tvalid ;
	   multiseg_stage1.tlast               <= (current_valid_bytes + rx_st_wbc_stg1  <= TKEEP)? multiseg_stage0.tlast : 1'b0 ;
	   stall_pipeline                      <= (current_valid_bytes + rx_st_wbc_stg1 <= TKEEP)? 1'b0 : 1'b1 ;
	   multiseg_stage1.tuser_last_segment  <= multiseg_stage0.tuser_last_segment;
       multiseg_stage1.tuser_sts           <= multiseg_stage0.tuser_sts;
       multiseg_stage1.tuser_client        <= multiseg_stage0.tuser_client;
	   multiseg_stage1.tkeep               <= (fifo_tkeep_mod << rx_st_wbc_stg1) | hold_tkeep;
	   rx_st_wbc_stg1                      <= (current_valid_bytes + rx_st_wbc_stg1 <= TKEEP)? rx_st_wbc_stg0 :((current_valid_bytes + rx_st_wbc_stg1) - TKEEP);
	   rx_st_empty1                        <= (current_valid_bytes + rx_st_wbc_stg1 <= TKEEP)? rx_st_empty0 : TKEEP - (rx_st_wbc_stg0 + rx_st_wbc_stg1 - TKEEP) ;
	
    end

   else if(axis_tx_if.tready & (frame_multiseg | hold_valid | frame_null_bytes )  & multiseg_stage0.tvalid ) begin
	  multiseg_stage1.tdata               <= (multiseg_stage0.tdata << rx_st_wbc_stg1*8) | hold_data;
	  multiseg_stage1.tvalid              <= multiseg_stage0.tvalid ;
	  multiseg_stage1.tlast               <= multiseg_stage0.tlast ;
	  //stall_pipeline         <= (rx_st_wbc_stg0 <= TKEEP)? 1'b0 : 1'b1 ;
	  multiseg_stage1.tuser_last_segment  <= multiseg_stage0.tuser_last_segment;
     multiseg_stage1.tuser_sts           <= multiseg_stage0.tuser_sts;
     multiseg_stage1.tuser_client        <= multiseg_stage0.tuser_client;
	  multiseg_stage1.tkeep               <= (multiseg_stage0.tkeep <<rx_st_wbc_stg1 ) | hold_tkeep;
	  rx_st_wbc_stg1                      <= rx_st_wbc_stg0;
	     // rx_st_empty1          <=   TKEEP - rx_st_wbc_stg0 ;
	 
     end
  else if (axis_tx_if.tready & tmp_avst_rx_sop & multiseg_stage0.tvalid & sop_empty_bytes != 0) begin
	  multiseg_stage1.tvalid              <= 1'b0;
	  multiseg_stage1.tlast               <= multiseg_stage0.tlast ;
	  multiseg_stage1.tkeep               <= fifo_tkeep_mod;
	  multiseg_stage1.tdata               <= multiseg_stage0.tdata;
     multiseg_stage1.tuser_client        <= multiseg_stage0.tuser_client;
	  rx_st_wbc_stg1                      <= rx_st_wbc_stg0;
	  rx_st_empty1                        <= rx_st_empty0;
	 end
  else if(axis_tx_if.tready & !hold_valid & multiseg_stage0.tvalid ) begin
      multiseg_stage1.tvalid              <= multiseg_stage0.tvalid ;
      multiseg_stage1.tlast               <= multiseg_stage0.tlast ;
      multiseg_stage1.tkeep               <= fifo_tkeep_mod;
      multiseg_stage1.tdata               <= multiseg_stage0.tdata;
      multiseg_stage1.tuser_last_segment  <= multiseg_stage0.tuser_last_segment;
      multiseg_stage1.tuser_sts           <= multiseg_stage0.tuser_sts;
      multiseg_stage1.tuser_client        <= multiseg_stage0.tuser_client;
      rx_st_wbc_stg1                      <= rx_st_wbc_stg0;
	  rx_st_empty1                        <= rx_st_empty0;
     end  
  else if(axis_tx_if.tready & hold_valid & multiseg_stage0.tvalid ) begin
      multiseg_stage1.tvalid              <= multiseg_stage0.tvalid ;
      multiseg_stage1.tlast               <= multiseg_stage0.tlast ;
      multiseg_stage1.tkeep               <= fifo_tkeep_mod;
      multiseg_stage1.tdata               <= multiseg_stage0.tdata;
      multiseg_stage1.tuser_last_segment  <= multiseg_stage0.tuser_last_segment;
      multiseg_stage1.tuser_sts           <= multiseg_stage0.tuser_sts;
      multiseg_stage1.tuser_client        <= multiseg_stage0.tuser_client;
      rx_st_wbc_stg1                      <= rx_st_wbc_stg0;
	  rx_st_empty1                        <= rx_st_empty0;
     end
   else  begin
     multiseg_stage1.tdata               <=  'd0;
	  multiseg_stage1.tvalid              <=  'd0;
	  multiseg_stage1.tlast               <=  'd0;
	  multiseg_stage1.tuser_last_segment  <=  'd0;
	  multiseg_stage1.tuser_sts           <=  'd0;
	  multiseg_stage1.tuser_client        <=  'd0;
	  multiseg_stage1.tkeep               <=  'd0;
	  stall_pipeline                      <=  'd0;
   end 
   end
  end 
  
  //----------------------------------------------
  // pipeline_stage2
  //---------------------------------------------- 

 axis_if #(.DATA_W(DATA_W),.USER_W(USER_W),.USER_STS_W(USER_STS_W),.USER_CLIENT_W(USER_CLIENT_W),.USER_TS_IGR_W(USER_TS_IGR_W)) multiseg_stage2();
 logic enable_next_pipe=1'b0;
 logic enable_next_pipe2=1'b0;
 
  always @(posedge i_clk) begin
 
   if(stall_pipeline & !enable_next_pipe) begin
       multiseg_stage2.tvalid             <= multiseg_stage1.tvalid ;
       multiseg_stage2.tlast              <= 1'b0;
	   enable_next_pipe                   <= 1'b1;
	   multiseg_stage2.tkeep              <= multiseg_stage1.tkeep ;
	   multiseg_stage2.tdata              <= multiseg_stage1.tdata ;
	   multiseg_stage2.tuser_last_segment <= multiseg_stage1.tuser_last_segment ;
	   multiseg_stage2.tuser_sts          <= multiseg_stage1.tuser_sts ;
	   multiseg_stage2.tuser_client       <= multiseg_stage1.tuser_client ;
     
    end
	else if (enable_next_pipe)begin
	  multiseg_stage2.tvalid             <= 1'b1;
	  multiseg_stage2.tlast              <= 1'b1;
	  multiseg_stage2.tkeep              <= hold_tkeep_del;
      multiseg_stage2.tdata              <= hold_data_del;
	  multiseg_stage2.tuser_last_segment <= hold_tuser_last_segment_del ;
	  multiseg_stage2.tuser_sts          <= multiseg_stage0.tuser_sts ;
	  multiseg_stage2.tuser_client       <= multiseg_stage0.tuser_client ;
	  enable_next_pipe                   <= 1'b0;
	  if (multiseg_stage1.tvalid)
	  begin
	    hold_data_pipe    <= multiseg_stage1.tdata ;
		hold_tkeep_pipe   <= multiseg_stage1.tkeep ;
		hold_tvalid_pipe  <= multiseg_stage1.tvalid ;
		hold_tlast_pipe   <= multiseg_stage1.tlast ;
		enable_next_pipe2 <= 1'b1;
	  end
	  
	end
	else if (enable_next_pipe2)begin
	  multiseg_stage2.tvalid             <= hold_tvalid_pipe;
	  multiseg_stage2.tlast              <= hold_tlast_pipe;
	  multiseg_stage2.tkeep              <= hold_tkeep_pipe;
      multiseg_stage2.tdata              <= hold_data_pipe;
	  multiseg_stage2.tuser_last_segment <= multiseg_stage1.tuser_last_segment ;
	  multiseg_stage2.tuser_sts          <= multiseg_stage1.tuser_sts ;
	  multiseg_stage2.tuser_client       <= multiseg_stage1.tuser_client ;
	  enable_next_pipe2                  <= 1'b0;
	end
  	else begin
	  multiseg_stage2.tvalid             <= multiseg_stage1.tvalid;
	  multiseg_stage2.tlast              <= multiseg_stage1.tlast ;
	  multiseg_stage2.tkeep              <= multiseg_stage1.tkeep ;
	  multiseg_stage2.tdata              <= multiseg_stage1.tdata ;
	  multiseg_stage2.tuser_last_segment <= multiseg_stage1.tuser_last_segment ;
	  multiseg_stage2.tuser_sts          <= multiseg_stage1.tuser_sts ;
	  multiseg_stage2.tuser_client       <= multiseg_stage1.tuser_client ;
 	end
  end

logic multiseg_stage2_tlast_latch, multiseg_stage2_tvalid_del;
  
 always @(posedge i_clk) begin
   if(!i_rstn) begin
	    multiseg_stage2_tvalid_del <=  1'b0;
   end
   else
   begin
     if (multiseg_stage2.tlast) 
	    multiseg_stage2_tvalid_del <=  1'b0;
     else if (multiseg_stage2.tvalid)
	    multiseg_stage2_tvalid_del <= 1'b1;
   end
 end
  
  //---------------------------------------------
  //Enable Output data stream
  //----------------------------------------------
  assign  axis_tx_if.tvalid                =   multiseg_stage2.tvalid ;
  assign  axis_tx_if.tdata                 =   multiseg_stage2.tdata  ;
  assign  axis_tx_if.tkeep                 =   multiseg_stage2.tkeep  ;
  assign  axis_tx_if.tlast                 =   multiseg_stage2.tlast  ;
  assign  axis_tx_if.tuser_last_segment    =   multiseg_stage2.tuser_last_segment  ;
  assign  axis_tx_if.tuser_sts             =   multiseg_stage2.tuser_sts  ;
  assign  axis_tx_if.tuser_client          =   multiseg_stage2.tuser_client  ;
  assign  axis_tx_if.tuser_ts_igr_data     =   hold_tuser_ts_igr_data; 
  assign  axis_tx_if.tuser_ts_igr_valid    =   (!multiseg_stage2_tvalid_del) & multiseg_stage2.tvalid;
  
endmodule
