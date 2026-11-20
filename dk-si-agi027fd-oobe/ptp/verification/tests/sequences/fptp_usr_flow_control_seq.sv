//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# User traffic are sent on PKT CLIEN0. The packets reaches HSSI, gets looped back and routed back 
//# respective PKT CLIENT1 based on the configuration in PTP Bridge (TCAM)
//# This test also does link down up for HSSI SS. It writes into HSSI register to apply eio_sys_rst
//# and then revokes the reset and ensures the link (pcs_ready) goes low and comes up
//# again. During this link down HSSI SS will flow control PTP Bridge and PTP Bridge
//# will flow control Packet client blocks. Once the link comes up these flow control
//# are revoked and traffic flow continues.
//########################################################################
class fptp_usr_flow_control_seq extends uvm_sequence;
  `uvm_declare_p_sequencer(svt_axi_system_sequencer)

    
  `uvm_object_utils(fptp_usr_flow_control_seq);

  fptp_data_traffic_cfg_seq cfg_csr_seq;
  fptp_ptp_bridge_cfg_usr_seq ptp_cfg_usr_seq;
  fptp_user_pcs_check_seq pcs_seq;
  fptp_user_traffic_check_seq check_seq;

  function new (string name = "fptp_usr_flow_control_seq");
    super.new(name);
  endfunction : new

  bit [47:0] u0_da;
  bit [47:0] u0_sa;
  bit [47:0] u1_da;
  bit [47:0] u1_sa;
  bit [31:0] cnt;

  task body();

    super.body();
   u0_da  = 'h222222222222;
   u0_sa  = 'h111111111111;
   u1_da  = 'hEEEEEEEEEEEE;
   u1_sa  = 'hBBBBBBBBBBBB;
   cnt    = 'h1F4;  // 500

    `uvm_info(get_full_name(), "Body:STARTS in USER PATH SEQ.", UVM_DEBUG) 
      `uvm_do_with (ptp_cfg_usr_seq, {
                    usr_pri      == 1;
                    usr0_eth_key0 == u0_da[31:0];
                    usr0_eth_key1 == {u0_sa[15:0], u0_da[47:32]};
                    usr0_eth_key2 == u0_sa[47:16];
                    usr1_eth_key0 == u1_da[31:0];
                    usr1_eth_key1 == {u1_sa[15:0], u1_da[47:32]};
                    usr1_eth_key2 == u1_sa[47:16];
                   }
                   )
      begin
        wait (ptp_cfg_usr_seq.ptp_cfg_usr_done==1);
      end
      #100ns;      

      `uvm_do_with (cfg_csr_seq, {
                    usr_en == 2'h3;
                    usr_pkt == cnt;
                   }
                   )
      begin
        wait (cfg_csr_seq.h2f_cfg_done==1);
      end
      #5us;
      `uvm_do(pcs_seq)
      `uvm_do_with(check_seq,{
                      pkt_cnt == cnt;
                    }
                  )
                                
     `uvm_info(get_full_name(), "Body:ENDS in USER PATH SEQ...", UVM_DEBUG) 

  endtask: body

endclass : fptp_usr_flow_control_seq
