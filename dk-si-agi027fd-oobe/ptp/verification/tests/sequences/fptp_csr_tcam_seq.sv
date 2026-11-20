//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//#CSR read access on TCAM0 and TCAM1 for higher range of address. 
//#Checks default value
//########################################################################
class fptp_csr_tcam_seq extends fptp_base_seq;
    
  rand int no_of_transactions ;
  rand int unsigned sequence_length = 10;

  `uvm_object_utils(fptp_csr_tcam_seq);

  /** Declare a typed sequencer object that the sequence can access */
  //`uvm_declare_p_sequencer(fptp_vir_seqr)

  function new (string name = "fptp_csr_tcam_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]     data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]            wstrb [];
    bit [31:0]                            exp_data;

    `uvm_info(get_full_name(), "Body: Entered...", UVM_DEBUG)

    data = new[1];
    wstrb = new[1];

    data[0] = 256'h0000_0000_beed_babe_0000_0000_deed_beed;
    wstrb[0] = 'hf;
    

    `uvm_info(get_full_name(), "Body: TCAM0 Starts...", UVM_DEBUG)
    exp_data = 32'h0;
    for (int i=0; i< 100 ;i++ )
    begin
      #10ns; 
      axi_master_read(
              .address(PTP_TCAM0_BASE_ADDR+i*4),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    `uvm_info(get_full_name(), "Body: TCAM0 Exiting...", UVM_DEBUG)

    `uvm_info(get_full_name(), "Body: TCAM1 Starts...", UVM_DEBUG)

    exp_data = 32'h0;
    for (int i=0; i< 100 ;i++ )
    begin
      #10ns; 
      axi_master_read(
              .address(PTP_TCAM1_BASE_ADDR+i*4),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    `uvm_info(get_full_name(), "Body: TCAM1 Exiting...", UVM_DEBUG)

  endtask: body

endclass : fptp_csr_tcam_seq
