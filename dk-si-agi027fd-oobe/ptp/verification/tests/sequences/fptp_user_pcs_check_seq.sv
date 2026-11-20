//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# Checks the Pkt client registers status for data integrity.
//########################################################################
class fptp_user_pcs_check_seq extends fptp_base_seq;
    
  rand int no_of_transactions ;
  rand int unsigned check_sequence_length = 10;

  `uvm_object_utils(fptp_user_pcs_check_seq);

  function new (string name = "fptp_user_pcs_check_seq");
    super.new(name);
  endfunction : new

    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]     data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]        wstrb [];
    bit [31:0]                            exp_data,hssi8_data,hssi9_data,obs_data,addr;
    bit [7:0]                             idle_cycle;   
    bit [1:0]                             mode_len;   
    bit                                   pkt_gap;   
    bit                                   pkt_chk_en;   
    bit                                   dyn_mode;   
    bit                                   traff_en;   
    bit [31:0]                            csr_wdata;   
    bit                                   h2f_check_done; 
    bit                                   pktcli0_start_check=0;
    bit                                   pktcli1_start_check=0;

  task body();
     super.body();

    `uvm_info(get_full_name(), "Body: Entered...", UVM_DEBUG)

    data = new[1];
    wstrb = new[1];
    h2f_check_done = 0;

    data[0] = 256'h0000_0000_beed_babe_0000_0000_deed_beed;
    wstrb[0] = 'hf;
    csr_wdata = 'h0;
    //APPLY SOFT RESET HSSI0 SS PORT8
    `uvm_info(get_full_name(), "Body: HSSI0 P8 SOFT RESET ...", UVM_DEBUG) 
    axi_master_read(
              .address(HSSI0_SS_BASE_ADDR+'h120_0000+'h108),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
    );
    
    hssi8_data = data[0][31:0];
    hssi8_data[0]=1;
    data[0] = hssi8_data;
    axi_master_write(
            .address(HSSI0_SS_BASE_ADDR+'h120_0000+'h108),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    `uvm_info(get_full_name(), "Body: HSSI P9 SOFT RESET ...", UVM_DEBUG) 
    axi_master_read(
              .address(HSSI1_SS_BASE_ADDR+'h140_0000+'h108),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
    );
    
    hssi9_data = data[0][31:0];
    hssi9_data[0]=1;
    data[0] = hssi9_data;
    axi_master_write(
            .address(HSSI1_SS_BASE_ADDR+'h140_0000+'h108),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
   

    `uvm_info(get_full_name(), "Body:USER TRAFFIC CHECK START...", UVM_DEBUG) 
    `uvm_info(get_full_name(), " CHECK PKTCLIENT0 is enabled..", UVM_DEBUG)
    while (data[0][4])
      begin
      #1us;
      axi_master_read(
              .address(PKTCLI0_STAT_SYSTEM_MISC),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    if (!data[0][4]) begin
       `uvm_info(get_full_name(), " HSSI0 PCS READY IS DEASSERTED AND THE LINK IS LOW..", UVM_DEBUG)
    end

    while (data[0][4])
      begin
      #1us;
      axi_master_read(
              .address(PKTCLI1_STAT_SYSTEM_MISC),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    if (!data[0][4]) begin
       `uvm_info(get_full_name(), " HSSI1 PCS READY IS DEASSERTED AND THE LINK IS LOW..", UVM_DEBUG)
    end

    `uvm_info(get_full_name(), "Body: HSSI P8 SOFT RESET DEASSERT ...", UVM_DEBUG) 
    #5us;
    hssi8_data[0]=0;
    data[0] = hssi8_data;
    hssi8_data[0] = 0;
    axi_master_write(
            .address(HSSI0_SS_BASE_ADDR+'h120_0000+'h108),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    `uvm_info(get_full_name(), "Body: HSSI P9 SOFT RESET DEASSERT ...", UVM_DEBUG) 
    #5us;
    hssi9_data[0]=0;
    data[0] = hssi9_data;
    hssi9_data[0] = 0;
    axi_master_write(
            .address(HSSI1_SS_BASE_ADDR+'h140_0000+'h108),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );


    `uvm_info(get_full_name(), "Body: CHECK PCS READY ASSERTED for P8 ...", UVM_DEBUG) 
    data[0] = 0;
    while (!data[0][4])
      begin
      #10us;
      axi_master_read(
              .address(PKTCLI0_STAT_SYSTEM_MISC),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    if (data[0][4]) begin
       `uvm_info(get_full_name(), " HSSI0 PCS READY IS ASSERTED AND THE LINK IS UP AGAIN..", UVM_DEBUG)
    end

    `uvm_info(get_full_name(), "Body: CHECK PCS READY ASSERTED for P9 ...", UVM_DEBUG) 
    data[0] = 0;
    while (!data[0][4])
      begin
      #1us;
      axi_master_read(
              .address(PKTCLI1_STAT_SYSTEM_MISC),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    if (data[0][4]) begin
       `uvm_info(get_full_name(), " HSSI1 PCS READY IS ASSERTED AND THE LINK IS UP AGAIN..", UVM_DEBUG)
    end

    `uvm_info(get_full_name(), "Body:ENDS...", UVM_DEBUG) 
  endtask: body
endclass : fptp_user_pcs_check_seq
