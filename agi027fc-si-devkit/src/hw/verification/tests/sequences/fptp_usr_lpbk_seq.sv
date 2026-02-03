//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# User traffic are sent on PKT CLIEN0. The packets reaches HSSI, gets looped back and routed back 
//# respective PKT CLIENT1 lpbkd on the configuration in PTP Bridge (TCAM)
//########################################################################
class fptp_usr_lpbk_seq extends uvm_sequence;
  `uvm_declare_p_sequencer(svt_axi_system_sequencer)

    
  `uvm_object_utils(fptp_usr_lpbk_seq);

  fptp_data_traffic_cfg_seq cfg_csr_seq;
  fptp_ptp_bridge_cfg_usr_seq ptp_cfg_usr_seq;
  fptp_user_traffic_check_seq check_seq;

  function new (string name = "fptp_usr_lpbk_seq");
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
   cnt    = 'h40;  //60

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
      #15us;
      `uvm_do_with(check_seq,{
                      pkt_cnt == cnt;
                    }
                  )
                                
     `uvm_info(get_full_name(), "Body:ENDS in USER PATH SEQ...", UVM_DEBUG) 

  endtask: body

endclass : fptp_usr_lpbk_seq
