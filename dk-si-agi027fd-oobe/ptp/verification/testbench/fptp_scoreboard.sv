//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################
//# FPTP Scoreboard
//# On TX Side, Input packets are collected in queu and on RX Side Output packets
//# are collected in queue and data comparion is done. If data mismatches happens
//# error is reported.   
//#########################################################################

`uvm_analysis_imp_decl(_axi_port)

class fptp_scoreboard extends uvm_scoreboard;

svt_axi_transaction axi_trans;
fptp_tb_config      tb_cfg;


bit[`PAYLOAD_WIDTH-1:0] axi_tx_payload_q[`CH_WIDTH-1:0][$],axi_rx_payload_q[`CH_WIDTH-1:0][$];
bit[`PAYLOAD_STRB-1:0]  axi_rx_wstrb_q[`CH_WIDTH-1:0][$];
bit dest_p0, dest_p1, dest_p2;

bit [`DESC_LENGTH-1:0] tx_payload [`CH_WIDTH][*];
bit [`DESC_LENGTH-1:0] tx_dum_payload [`CH_WIDTH][*];
bit [`DESC_LENGTH-1:0] rx_payload [`CH_WIDTH][*];

bit [8-1:0] tx_payload [`CH_WIDTH][*];
bit [8-1:0] rx_payload [`CH_WIDTH][*];

bit[`PAYLOAD_STRB-1:0]  axi_rx_wstrb_q[`CH_WIDTH-1:0][$];

bit[31:0] tx_len_q[`CH_WIDTH][$];
bit[31:0] rx_len_q[`CH_WIDTH][$];

int tx_burst_size_bytes[`CH_WIDTH];
int tx_burst_length[`CH_WIDTH];
int rx_burst_size_bytes[`CH_WIDTH];
int rx_burst_length[`CH_WIDTH];

int tx_desc_length[`CH_WIDTH];
int rx_desc_length[`CH_WIDTH];

int iter0=0;
int start;
int tstart=1;
int tx_mod[`CH_WIDTH],rx_mod[`CH_WIDTH];
bit[31:0] tx_pend_bytes[`CH_WIDTH],rx_pend_bytes[`CH_WIDTH];
int skip_addr[`CH_WIDTH];


int chk_raddr[`CH_WIDTH],next_addr[`CH_WIDTH],chk_waddr[`CH_WIDTH],next_waddr[`CH_WIDTH];

bit[`PAYLOAD_WIDTH-1:0] axi_tx_payload_q[`CH_WIDTH-1:0][$],axi_rx_payload_q[`CH_WIDTH-1:0][$];
bit[`PAYLOAD_STRB-1:0]  axi_rx_wstrb_q[`CH_WIDTH-1:0][$];
bit dest_p0, dest_p1, dest_p2;

int tx_pkt_cnt[`CH_WIDTH], rx_pkt_cnt[`CH_WIDTH];
int pkt_tx0 = 0,pkt_tx1=0,pkt_tx2=0,pkt_tx3=0,pkt_tx4=0,pkt_tx5=0;
int pkt_rx0 = 0,pkt_rx1=0,pkt_rx2=0,pkt_rx3=0,pkt_rx4=0,pkt_rx5=0;
bit [`PAYLOAD_STRB-1:0] ch_temp0_wstrb[`CH_WIDTH],ch_temp1_wstrb[`CH_WIDTH],ch_temp2_wstrb[`CH_WIDTH];
bit [`ADDR_W-1:0] temp;
bit [`DESC_LENGTH-1:0] temp_data;
bit [`ADDR_W-1:0] rdata_addr[`CH_WIDTH][*],wdata_addr[`CH_WIDTH][*];
bit [`ADDR_W-1:0] tx_addr[`CH_WIDTH][$],rx_addr[`CH_WIDTH][$],rd_desc[`CH_WIDTH][$],wr_desc[`CH_WIDTH][$];
bit [`ADDR_W-1:0] daddr,paddr,curr_addr, prev_addr;
bit [`PAYLOAD_WIDTH-1:0] top_of_queue;
bit [`PAYLOAD_WIDTH-1:0] exp0_data, obs0_data,exp1_data,obs1_data,exp2_data,obs2_data,exp3_data,obs3_data,exp4_data,obs4_data,exp5_data,obs5_data;
bit [`PAYLOAD_STRB-1:0]  obs0_wstrb,obs1_wstrb,obs2_wstrb,obs3_wstrb,obs4_wstrb,obs5_wstrb, temp_wstrb;

  `uvm_component_utils(fptp_scoreboard)
  uvm_analysis_imp_axi_port #(svt_axi_transaction, fptp_scoreboard) axi_port;

  int tx0_no_of_descs,tx1_no_of_descs,tx2_no_of_descs,tx3_no_of_descs,tx4_no_of_descs,tx5_no_of_descs;
  int agent_port;
  int agent_type;
  int address_type;
  int rdesc_cnt[`CH_WIDTH];
  int wdesc_cnt[`CH_WIDTH];
  int wbk_desc_cnt[`CH_WIDTH];
  int tx_len[`CH_WIDTH], rx_len[`CH_WIDTH];
  

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      axi_port  = new("axi_port", this);
  endfunction: build_phase
   
  virtual function void write_axi_port(svt_axi_transaction trans);
    $cast(axi_trans , trans.clone());
     agent_port = axi_trans.addr[25:23];
     address_type = axi_trans.addr[30:28];
     agent_type = axi_trans.addr[27:26];
    `uvm_info(get_type_name(),$sformatf(" SCB:: Pkt received from ACE Lite slave ENV \n %s",axi_trans.sprint()),UVM_LOW)


   // TX DESC LENGTH FETCH
   if((axi_trans.xact_type == (svt_axi_transaction::COHERENT)) && (axi_trans.transmitted_channel == (svt_axi_transaction::READ)))
   begin
      if (address_type == 3'h1)
        begin
           read_descr(axi_trans); // DESCR FETCH
        end
      else if (address_type == 3'h2) // DATA FETCH
       begin
           read_data(axi_trans);
       end
    end

   if((axi_trans.xact_type == (svt_axi_transaction::COHERENT)) && (axi_trans.transmitted_channel == (svt_axi_transaction::WRITE)))
   begin
      if (address_type == 3'h1)
        begin
           write_bk_descr(axi_trans); // DESCR FETCH
        end
      else if (address_type == 3'h2) // DATA FETCH
       begin
           write_data(axi_trans);
       end
    end
  endfunction :write_axi_port


    virtual function read_descr(svt_axi_transaction trans);
        if(agent_type==1) // H2D
        begin 
          case(agent_port)
          0   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              rdesc_cnt[agent_port] = rdesc_cnt[agent_port]+1;
                              tx_len_q[0].push_back(temp_data[95:64]);
                     end
                  end 
                end
          1   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                            tx_len_q[1].push_back(temp_data[95:64]);
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              rdesc_cnt[agent_port] = rdesc_cnt[agent_port]+1;
                     end
                  end 
                end
          2   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                            tx_len_q[2].push_back(temp_data[95:64]);
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              rdesc_cnt[agent_port] = rdesc_cnt[agent_port]+1;
                     end
                  end 
                end
          3   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                            tx_len_q[3].push_back(temp_data[95:64]);
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              rdesc_cnt[agent_port] = rdesc_cnt[agent_port]+1;
                     end
                  end 
                end
          4   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                            tx_len_q[4].push_back(temp_data[95:64]);
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              rdesc_cnt[agent_port] = rdesc_cnt[agent_port]+1;
                     end
                  end 
                end
          5   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                            tx_len_q[5].push_back(temp_data[95:64]);
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              rdesc_cnt[agent_port] = rdesc_cnt[agent_port]+1;
                     end
                  end 
                end
          endcase
        end // agent_type end
        else if (agent_type == 3'h0) 
          case(agent_port)
          0   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                            rx_len_q[0].push_back(temp_data[95:64]);
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              wdesc_cnt[agent_port] = wdesc_cnt[agent_port]+1;
                     end
                  end 
                end
          1   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                            rx_len_q[1].push_back(temp_data[95:64]);
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              wdesc_cnt[agent_port] = wdesc_cnt[agent_port]+1;
                     end
                  end 
                end
          2   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                            rx_len_q[2].push_back(temp_data[95:64]);
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              wdesc_cnt[agent_port] = wdesc_cnt[agent_port]+1;
                     end
                  end 
                end
          3   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                            rx_len_q[3].push_back(temp_data[95:64]);
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              wdesc_cnt[agent_port] = wdesc_cnt[agent_port]+1;
                     end
                  end 
                end
          4   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                            rx_len_q[4].push_back(temp_data[95:64]);
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              wdesc_cnt[agent_port] = wdesc_cnt[agent_port]+1;
                     end
                  end 
                end
          5   : begin
                  foreach(axi_trans.data[i]) begin
                     if (i==0) begin
                            temp_data =  axi_trans.data[i];
                            rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                            rx_len_q[5].push_back(temp_data[95:64]);
                     end
                     if (i==1) begin
                              temp = axi_trans.data[i];
                              wdesc_cnt[agent_port] = wdesc_cnt[agent_port]+1;
                     end
                  end 
                end
          endcase
        begin
        end
    endfunction


    virtual function write_bk_descr(svt_axi_transaction trans);
        if (agent_type == 3'h0) 
        begin
          foreach(axi_trans.data[i]) begin
             if (i==1) begin
                      temp = axi_trans.data[i];
                      wbk_desc_cnt[agent_port] = wbk_desc_cnt[agent_port]+1;
                      $display("WBK_DESC CNT[%d] = %d",agent_port,wbk_desc_cnt[agent_port]);
             end
          end
        end
    endfunction


    virtual function read_data(svt_axi_transaction trans);
        chk_raddr[agent_port] = trans.addr; 
        case(agent_port)
          0 : begin
                if(pkt_tx0 == 0) begin
                   if(chk_raddr[agent_port] == 'h24000000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h24000000+32'h600;
                   end  
                   pkt_tx0 = 1; 
                end 
              end
          1 : begin
                if(pkt_tx1 == 0) begin
                   if(chk_raddr[agent_port] == 'h24800000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h24800000+32'h600;
                   end  
                   pkt_tx1 = 1; 
                end 
              end
           2 : begin
                if(pkt_tx2 == 0) begin
                   if(chk_raddr[agent_port] == 'h25000000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h25000000+32'h600;
                   end  
                   pkt_tx2 = 1; 
                end 
               end    
           3 : begin
                if(pkt_tx3 == 0) begin
                   if(chk_raddr[agent_port] == 'h25800000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h25800000+32'h600;
                   end  
                   pkt_tx3 = 1; 
                end 
               end    
           4 : begin
                if(pkt_tx4 == 0) begin
                   if(chk_raddr[agent_port] == 'h26000000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h26000000+32'h600;
                   end  
                   pkt_tx4 = 1; 
                end 
               end    
           5 : begin
                if(pkt_tx5 == 0) begin
                   if(chk_raddr[agent_port] == 'h26800000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h26800000+32'h600;
                   end  
                   pkt_tx5 = 1; 
                end 
               end    
        endcase
        if(chk_raddr[agent_port] == next_addr[agent_port]) begin
            tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
            next_addr[agent_port] = next_addr[agent_port]+32'h600;
        end

        if(!tb_cfg.dest_p0 && !tb_cfg.dest_p1 && !tb_cfg.dest_p2) 
            tx_pkt_collect(trans,agent_port);
        else begin
        case(agent_port)
        0  : begin
               foreach(trans.data[i])
               begin
                 if(tb_cfg.dest_p0)
                 begin
                   axi_tx_payload_q[0].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p1)
                 begin
                   axi_tx_payload_q[1].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p2)
                 begin
                   axi_tx_payload_q[2].push_back(axi_trans.data[i]);
                 end
               end
             end
        1  : begin
               foreach(trans.data[i])
               begin
                 if(tb_cfg.dest_p0)
                 begin
                   axi_tx_payload_q[0].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p1)
                 begin
                   axi_tx_payload_q[1].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p2)
                 begin
                   axi_tx_payload_q[2].push_back(axi_trans.data[i]);
                 end
               end
             end
        2  : begin
               foreach(trans.data[i])
               begin
                 if(tb_cfg.dest_p0)
                 begin
                   axi_tx_payload_q[0].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p1)
                 begin
                   axi_tx_payload_q[1].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p2)
                 begin
                   axi_tx_payload_q[2].push_back(axi_trans.data[i]);
                 end
               end
             end
        3  : begin
               foreach(trans.data[i])
               begin
                 if(tb_cfg.dest_p0)
                 begin
                   axi_tx_payload_q[3].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p1)
                 begin
                   axi_tx_payload_q[4].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p2)
                 begin
                   axi_tx_payload_q[5].push_back(axi_trans.data[i]);
                 end
               end
             end
        4  : begin
               foreach(trans.data[i])
               begin
                 if(tb_cfg.dest_p0)
                 begin
                   axi_tx_payload_q[3].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p1)
                 begin
                   axi_tx_payload_q[4].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p2)
                 begin
                   axi_tx_payload_q[5].push_back(axi_trans.data[i]);
                 end
               end
             end
        5  : begin
               foreach(trans.data[i])
               begin
                 if(tb_cfg.dest_p0)
                 begin
                   axi_tx_payload_q[3].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p1)
                 begin
                   axi_tx_payload_q[4].push_back(axi_trans.data[i]);
                 end
                 else if(tb_cfg.dest_p2)
                 begin
                   axi_tx_payload_q[5].push_back(axi_trans.data[i]);
                 end
               end
             end
         endcase
      
        end // end of if 
    endfunction

    function tx_pkt_collect(svt_axi_transaction trans, int port);
       int bytes_rcvd[`CH_WIDTH],num_bytes[`CH_WIDTH];
       tx_burst_length[port] = trans.burst_length;
       tx_burst_size_bytes[port] = 2**trans.burst_size;
       if (tx_pend_bytes[port]==0 && !skip_addr[port])
       begin
          tx_desc_length[port]=tx_len_q[port].pop_front();
          tx_len[port] = tx_desc_length[port];
          tx_mod[port] = tx_desc_length[port]%16;
       end 
       if(tx_desc_length[port]!=0)
       begin
         if(skip_addr[port])
         begin
           for (int l=0; l<tx_burst_length[port]; l++) begin
             for (int b=0; b<tx_burst_size_bytes[port]; b++) begin
               tx_dum_payload[port][trans.addr+(tx_burst_size_bytes[port]*l)+b] = trans.data[l][8*b+:8];
             end
           skip_addr[port]=0; 
           end
         end
         else if(tx_mod[port]==0) 
         begin
           for (int l=0; l<tx_burst_length[port]; l++) 
           begin
             for (int b=0; b<tx_burst_size_bytes[port]; b++) 
             begin
               tx_payload[port][trans.addr+(tx_burst_size_bytes[port]*l)+b] = trans.data[l][8*b+:8];
               `uvm_info(get_full_name(),
                             $sformatf("tx_payload[%0d][%0h] = %0h",
                                        port,trans.addr+(tx_burst_size_bytes[port]*l)+b,
                                        tx_payload[port][trans.addr+(tx_burst_size_bytes[port]*l)+b]),
                             UVM_LOW)
               tx_len[port] =  tx_len[port]-1;
               tx_pend_bytes[port] =  tx_len[port];
               $display("TX DESC LENGTH in RX TXP [%d] = %d",port,tx_len[port]);
               $display("TX PEND LENGTH in RX TXP [%d] = %d",port,tx_pend_bytes[port]);
               if(tx_pend_bytes[port] == 0) begin
                  tx_burst_size_bytes[port] = 0;                     
                  tx_burst_length[port] = 0;
               end
             end
           end
         end  
         else if(tx_mod[port]!=tx_pend_bytes[port]) 
         begin
           for (int l=0; l<tx_burst_length[port]; l++) 
           begin
             for (int b=0; b<tx_burst_size_bytes[port]; b++) 
             begin
               tx_payload[port][trans.addr+(tx_burst_size_bytes[port]*l)+b] = trans.data[l][8*b+:8];
               `uvm_info(get_full_name(),
                             $sformatf("tx_payload[%0d][%0h] = %0h",
                                        port,trans.addr+(tx_burst_size_bytes[port]*l)+b,
                                        tx_payload[port][trans.addr+(tx_burst_size_bytes[port]*l)+b]),
                             UVM_LOW)
               tx_len[port] =  tx_len[port]-1;
               tx_pend_bytes[port] =  tx_len[port];
               $display("TX DESC LENGTH in RX TXP [%d] = %d",port,tx_len[port]);
               $display("TX SPEND LENGTH in RX TXP [%d] = %d",port,tx_pend_bytes[port]);
               if(tx_pend_bytes[port] == 0) begin
                  tx_burst_size_bytes[port] = 0;                     
                  tx_burst_length[port] = 0;
               end
             end
           end
         end  
         else
         begin
           num_bytes[port]=tx_mod[port];
           for (int l=0; l<tx_burst_length[port]; l++)
           begin
             for (int b=0; b<num_bytes[port]; b++) 
             begin
                tx_payload[port][trans.addr+(tx_burst_size_bytes[port]*l)+b] = trans.data[l][8*b+:8];
                `uvm_info(get_full_name(),
                              $sformatf("tx_payload[%0d][%0h] = %0h",
                                         port,trans.addr+(tx_burst_size_bytes[port]*l)+b,
                                         tx_payload[port][trans.addr+(tx_burst_size_bytes[port]*l)+b]),
                              UVM_LOW)
                tx_len[port] =  tx_len[port]-1;
                tx_pend_bytes[port] =  tx_len[port];
                $display("TX DESC LENGTH in RX TXP [%d] = %d",port,tx_len[port]);
                $display("TX PEND LENGTH in RX TXP [%d] = %d",port,tx_pend_bytes[port]);
                if(tx_pend_bytes[port]==0) begin
                     tx_burst_size_bytes[port] = 0;                     
                     tx_burst_length[port] = 0;
                     if(tx_mod[port]>8) skip_addr[port]=1;
                end
             end
           end// temp mod
         end
       end // desc1
      `uvm_info(get_type_name(),$sformatf(" H2D PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",agent_port,tx_payload[agent_port].size()),UVM_LOW);
      `uvm_info(get_type_name(),$sformatf(" H2D PAYLOAD ENTRY SIZE[%d]= 'h%h",agent_port,tx_payload[agent_port].num()),UVM_LOW);
      endfunction
    
    virtual function write_data(svt_axi_transaction trans);
        chk_waddr[agent_port] = trans.addr; 
        case(agent_port)
          0 : begin
                if(pkt_rx0 == 0) begin
                   if(chk_waddr[agent_port] == 'h20000000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h20000000+32'h600;
                       `uvm_info(get_type_name(),$sformatf("RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]),UVM_LOW);
                   end  
                   pkt_rx0 = 1; 
                end 
              end
          1 : begin
                if(pkt_rx1 == 0) begin
                   if(chk_waddr[agent_port] == 'h20800000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h20800000+32'h600;
                       `uvm_info(get_type_name(),$sformatf("RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]),UVM_LOW);
                   end  
                   pkt_rx1 = 1; 
                end 
              end
           2 : begin
                if(pkt_rx2 == 0) begin
                   if(chk_waddr[agent_port] == 'h21000000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h21000000+32'h600;
                       `uvm_info(get_type_name(),$sformatf("RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]),UVM_LOW);
                   end  
                   pkt_rx2 = 1; 
                end 
               end    
           3 : begin
                if(pkt_rx3 == 0) begin
                   if(chk_waddr[agent_port] == 'h21800000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h21800000+32'h600;
                       `uvm_info(get_type_name(),$sformatf("RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]),UVM_LOW);
                   end  
                   pkt_rx3 = 1; 
                end 
               end    
           4 : begin
                if(pkt_rx4 == 0) begin
                   if(chk_waddr[agent_port] == 'h22000000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h22000000+32'h600;
                       `uvm_info(get_type_name(),$sformatf("RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]),UVM_LOW);
                   end  
                   pkt_rx4 = 1; 
                end 
               end    
           5 : begin
                if(pkt_rx5 == 0) begin
                   if(chk_waddr[agent_port] == 'h22800000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h22800000+32'h600;
                       `uvm_info(get_type_name(),$sformatf("RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]),UVM_LOW);
                   end  
                   pkt_rx5 = 1; 
                end 
               end    
        endcase
        if(chk_waddr[agent_port] == next_waddr[agent_port]) begin
            rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
            next_waddr[agent_port] = next_waddr[agent_port]+32'h600;
        end
        if(!tb_cfg.dest_p0 && !tb_cfg.dest_p1 && !tb_cfg.dest_p2) 
          rx_pkt_collect(trans,agent_port);
        else
        begin
          rx_pkt_pcollect(trans,agent_port);
        end 
    endfunction

     function rx_pkt_pcollect ( svt_axi_transaction trans, int port);
      `uvm_info(get_type_name(),$sformatf(" SCB:: CH[%d] WRITE PACKET received from ACE Lite slave ENV \n %s",port,trans.sprint()),UVM_LOW)
      foreach(axi_trans.data[i]) begin
         axi_rx_payload_q[port].push_back(trans.data[i]);
      end
      foreach (axi_trans.wstrb[i]) begin
         axi_rx_wstrb_q[port].push_back(trans.wstrb[i]);
      end
    endfunction  



    // RX PKT COLLECTION
    function rx_pkt_collect(svt_axi_transaction trans, int port);
       int num_bytes[`CH_WIDTH];
       if (rx_pend_bytes[port]==0)
       begin
          rx_desc_length[port]=rx_len_q[port].pop_front();
          rx_len[port] = rx_desc_length[port];
          $display(" WDESC LENGTH[%d] = %d",port,rx_desc_length[port]); 
       end 
        rx_burst_length[port] = trans.burst_length;
        rx_burst_size_bytes[port] = 2**trans.burst_size;
        if(rx_desc_length[port]!=0) begin
           for (int l=0; l<rx_burst_length[port]; l++) begin
             `uvm_info(get_full_name(),
                       $sformatf("trans.data[%0d] = %0h, wstrb[%0d]=%0h",
                                  port, trans.data[l], port, trans.wstrb[l]),
                       UVM_LOW)
               case(trans.wstrb[l])
               'h0001 : num_bytes[port] = 1;
               'h0002 : num_bytes[port] = 2;
               'h0003 : num_bytes[port] = 2;
               'h0004 : num_bytes[port] = 3;
               'h0006 : num_bytes[port] = 3;
               'h0008 : num_bytes[port] = 4;
               'h000c : num_bytes[port] = 4;
               'h000f : num_bytes[port] = 4;
                    
               'h001f : num_bytes[port] = 5;
               'h0010 : num_bytes[port] = 5;
               'h002f : num_bytes[port] = 6;
               'h0020 : num_bytes[port] = 6;
               'h0030 : num_bytes[port] = 6;
               'h003f : num_bytes[port] = 6;
               'h0040 : num_bytes[port] = 7;
               'h004f : num_bytes[port] = 7;
               'h0080 : num_bytes[port] = 8;
               'h008f : num_bytes[port] = 8;
               'h00c0 : num_bytes[port] = 8;
               'h00cf : num_bytes[port] = 8;
               'h00f0 : num_bytes[port] = 8;
               'h00ff : num_bytes[port] = 8;

               'h01ff : num_bytes[port] = 9;
               'h0100 : num_bytes[port] = 9;
               'h0200 : num_bytes[port] = 10;
               'h02ff : num_bytes[port] = 10;
               'h0300 : num_bytes[port] = 10;
               'h03ff : num_bytes[port] = 10;
               'h0400 : num_bytes[port] = 11;
               'h04ff : num_bytes[port] = 11;
               'h0800 : num_bytes[port] = 12;
               'h08ff : num_bytes[port] = 12;
               'h0c00 : num_bytes[port] = 12;
               'h0cff : num_bytes[port] = 12;
               'h0fff : num_bytes[port] = 12;
               'h0f00 : num_bytes[port] = 12;

               'h1fff : num_bytes[port] = 13;
               'h1000 : num_bytes[port] = 13;
               'h2000 : num_bytes[port] = 14;
               'h2fff : num_bytes[port] = 14;
               'h3000 : num_bytes[port] = 14;
               'h3fff : num_bytes[port] = 14;
               'h4000 : num_bytes[port] = 15;
               'h4fff : num_bytes[port] = 15;
               'h8000 : num_bytes[port] = 16;
               'h8fff : num_bytes[port] = 16;
               'hc000 : num_bytes[port] = 16;
               'hcfff : num_bytes[port] = 16;
               'hffff : num_bytes[port] = 16;
               'hf000 : num_bytes[port] = 16;
               endcase  
               for (int b=0; b<num_bytes[port]; b++) begin
                 if (trans.wstrb[l][b] == 1) 
                 begin
                   `uvm_info(get_full_name(),
                            $sformatf("rx_payload[%0d][%0h] = %0h",
                                       port, trans.addr+(rx_burst_size_bytes[port]*l)+b,
                                       rx_payload[port][trans.addr+(rx_burst_size_bytes[port]*l)+b]),
                            UVM_LOW)
                   rx_payload[port][trans.addr+(rx_burst_size_bytes[port]*l)+b] = trans.data[l][8*b+:8];
                   rx_len[port] = rx_len[port]-1;
                   rx_pend_bytes[port] =  rx_len[port];
                   if(rx_pend_bytes[port] == 0) begin
                     rx_burst_size_bytes[port] = 0;                     
                     rx_burst_length[port] = 0;
                   end
                 end
               end
           end
        end
      `uvm_info(get_type_name(),$sformatf(" D2H PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",agent_port,rx_payload[agent_port].size()),UVM_LOW);
      `uvm_info(get_type_name(),$sformatf(" D2H PAYLOAD ENTRY SIZE[%d]= 'h%h",agent_port,rx_payload[agent_port].num()),UVM_LOW);
    endfunction



  //task run_phase(uvm_phase phase);
  task run_phase(uvm_phase phase);
     super.run_phase(phase);
 endtask

  virtual function void report_phase(uvm_phase phase);
    int tx_buff_addr[$];
    int rx_buff_addr[$];
    int h2d_addr, d2h_addr;
    super.final_phase(phase); 

          `uvm_info(get_type_name(),$sformatf(" H2D PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",0,tx_payload[0].size()),UVM_LOW);
          `uvm_info(get_type_name(),$sformatf(" H2D PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",1,tx_payload[1].size()),UVM_LOW);
          `uvm_info(get_type_name(),$sformatf(" H2D PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",2,tx_payload[2].size()),UVM_LOW);
          `uvm_info(get_type_name(),$sformatf(" H2D PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",3,tx_payload[3].size()),UVM_LOW);
          `uvm_info(get_type_name(),$sformatf(" H2D PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",4,tx_payload[4].size()),UVM_LOW);
          `uvm_info(get_type_name(),$sformatf(" H2D PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",5,tx_payload[5].size()),UVM_LOW);

          `uvm_info(get_type_name(),$sformatf(" D2H PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",0,rx_payload[0].size()),UVM_LOW);
          `uvm_info(get_type_name(),$sformatf(" D2H PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",1,rx_payload[1].size()),UVM_LOW);
          `uvm_info(get_type_name(),$sformatf(" D2H PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",2,rx_payload[2].size()),UVM_LOW);
          `uvm_info(get_type_name(),$sformatf(" D2H PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",3,rx_payload[3].size()),UVM_LOW);
          `uvm_info(get_type_name(),$sformatf(" D2H PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",4,rx_payload[4].size()),UVM_LOW);
          `uvm_info(get_type_name(),$sformatf(" D2H PAYLOAD ENTRY DATA SIZE[%d]= 'h%h",5,rx_payload[5].size()),UVM_LOW);


          while (axi_rx_payload_q[0].size() !=0)
          begin
             exp0_data = axi_tx_payload_q[0].pop_front();
             obs0_data = axi_rx_payload_q[0].pop_front();
             obs0_wstrb = axi_rx_wstrb_q[0].pop_front;
             `uvm_info(get_type_name(),$sformatf("CH0 EXP_DATA = `h%h", exp0_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH0 OBS_DATA = `h%h", obs0_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH0 STB_DATA = `h%h", obs0_wstrb),UVM_LOW);
             check_data (0,obs0_wstrb,exp0_data,obs0_data);
          end


          while (axi_rx_payload_q[1].size() !=0)
          begin
              exp1_data = axi_tx_payload_q[1].pop_front();
              obs1_data = axi_rx_payload_q[1].pop_front();
              obs1_wstrb = axi_rx_wstrb_q[1].pop_front;
             `uvm_info(get_type_name(),$sformatf("CH1 EXP_DATA = `h%h", exp1_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH1 OBS_DATA = `h%h", obs1_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH1 STB_DATA = `h%h", obs1_wstrb),UVM_LOW);
              check_data (1,obs1_wstrb,exp1_data,obs1_data);
          end

          while (axi_rx_payload_q[2].size() !=0)
          begin
              exp2_data = axi_tx_payload_q[2].pop_front();
              obs2_data = axi_rx_payload_q[2].pop_front();
              obs2_wstrb = axi_rx_wstrb_q[2].pop_front;
             `uvm_info(get_type_name(),$sformatf("CH2 EXP_DATA = `h%h", exp2_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH2 OBS_DATA = `h%h", obs2_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH2 STB_DATA = `h%h", obs2_wstrb),UVM_LOW);
              check_data (2,obs2_wstrb,exp2_data,obs2_data);
          end

          while (axi_rx_payload_q[3].size() !=0)
          begin
              exp3_data = axi_tx_payload_q[3].pop_front();
              obs3_data = axi_rx_payload_q[3].pop_front();
              obs3_wstrb = axi_rx_wstrb_q[3].pop_front;
             `uvm_info(get_type_name(),$sformatf("CH3 EXP_DATA = `h%h", exp3_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH3 OBS_DATA = `h%h", obs3_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH3 STB_DATA = `h%h", obs3_wstrb),UVM_LOW);
              check_data (3,obs3_wstrb,exp3_data,obs3_data);
          end

          while (axi_rx_payload_q[4].size() !=0)
          begin
              exp4_data = axi_tx_payload_q[4].pop_front();
              obs4_data = axi_rx_payload_q[4].pop_front();
              obs4_wstrb = axi_rx_wstrb_q[4].pop_front;
             `uvm_info(get_type_name(),$sformatf("CH4 EXP_DATA = `h%h", exp4_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH4 OBS_DATA = `h%h", obs4_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH4 STB_DATA = `h%h", obs4_wstrb),UVM_LOW);
              check_data (4,obs4_wstrb,exp4_data,obs4_data);
          end

          while (axi_rx_payload_q[5].size() !=0 )
          begin
              exp5_data = axi_tx_payload_q[5].pop_front();
              obs5_data = axi_rx_payload_q[5].pop_front();
              obs5_wstrb = axi_rx_wstrb_q[5].pop_front;
             `uvm_info(get_type_name(),$sformatf("CH5 EXP_DATA = `h%h", exp5_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH5 OBS_DATA = `h%h", obs5_data),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH5 STB_DATA = `h%h", obs5_wstrb),UVM_LOW);
              check_data (5,obs5_wstrb,exp5_data,obs5_data);
          end

    if(!tb_cfg.dest_p0 && !tb_cfg.dest_p1 && !tb_cfg.dest_p2) 
    begin
       foreach (tx_payload[i]) begin
         if (tx_payload[i].num() !== rx_payload[i].num())
           `uvm_error(get_full_name(),
                      $sformatf("No of bytes recvd %0d is not same as transferred %0d",
                                rx_payload[i].num(), tx_payload[i].num()))
         else
           `uvm_info(get_full_name(),
                     $sformatf("No of bytes recvd %0d same as transferred %0d",
                               rx_payload[i].num(), tx_payload[i].num()), UVM_NONE)
       end

       foreach (tx_payload[i])
         foreach (tx_payload[i][j])
           tx_buff_addr.push_back(j);

       foreach (rx_payload[i])
         foreach (rx_payload[i][j])
           rx_buff_addr.push_back(j);

       foreach (rx_payload[i]) begin
         repeat (rx_payload[i].num()) begin
           h2d_addr = tx_buff_addr.pop_front();
           d2h_addr = rx_buff_addr.pop_front();

           if (rx_payload[i][d2h_addr] !== tx_payload[i][h2d_addr])
             `uvm_error(get_full_name(),
                        $sformatf("Payload received @ %0h = %0h, not same as tx @ %0h = %0h",
                                  d2h_addr, rx_payload[i][d2h_addr], h2d_addr,
                                  tx_payload[i][h2d_addr]))
           else
             `uvm_info(get_full_name(),
                        $sformatf("Payload received @ %0h = %0h, same as tx @ %0h = %0h",
                                  d2h_addr, rx_payload[i][d2h_addr], h2d_addr,
                                  tx_payload[i][h2d_addr]), UVM_DEBUG)
         end
       end
    end


        if ((!tb_cfg.dest_p0) && (!tb_cfg.dest_p1) && (!tb_cfg.dest_p2)) begin
            if (tx_pkt_cnt[0] == rx_pkt_cnt[0]) begin
             `uvm_info(get_type_name(),$sformatf("CHO PKT CNT MATCHED TX0_PKT_CNT = 'h%h: RX0_PKT_CNT = `h%h", tx_pkt_cnt[0], rx_pkt_cnt[0]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH0 PKT CNT MISMATCHED TX0_PKT_CNT = `h%h, RX0_PKT_CNT = `h%h ",tx_pkt_cnt[0], rx_pkt_cnt[0]));
            end  

            if (tx_pkt_cnt[1] == rx_pkt_cnt[1]) begin
             `uvm_info(get_type_name(),$sformatf("CH1 PKT CNT MATCHED TX1_PKT_CNT = 'h%h: RX1_PKT_CNT = `h%h", tx_pkt_cnt[1], rx_pkt_cnt[1]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH1 PKT CNT MISMATCHED TX1_PKT_CNT = `h%h, RX1_PKT_CNT = `h%h ",tx_pkt_cnt[1], rx_pkt_cnt[1]));
            end  

            if (tx_pkt_cnt[2] == rx_pkt_cnt[2]) begin
             `uvm_info(get_type_name(),$sformatf("CH2 PKT CNT MATCHED TX2_PKT_CNT = 'h%h: RX2_PKT_CNT = `h%h", tx_pkt_cnt[2], rx_pkt_cnt[2]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH2 PKT CNT MISMATCHED TX2_PKT_CNT = `h%h, RX2_PKT_CNT = `h%h ",tx_pkt_cnt[2], rx_pkt_cnt[2]));
            end  

            if (tx_pkt_cnt[3] == rx_pkt_cnt[3]) begin
             `uvm_info(get_type_name(),$sformatf("CH3 PKT CNT MATCHED TX3_PKT_CNT = 'h%h: RX3_PKT_CNT = `h%h", tx_pkt_cnt[3], rx_pkt_cnt[3]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH3 PKT CNT MISMATCHED TX3_PKT_CNT = `h%h, RX3_PKT_CNT = `h%h ",tx_pkt_cnt[3], rx_pkt_cnt[3]));
            end  

            if (tx_pkt_cnt[4] == rx_pkt_cnt[4]) begin
             `uvm_info(get_type_name(),$sformatf("CH4 PKT CNT MATCHED TX4_PKT_CNT = 'h%h: RX4_PKT_CNT = `h%h", tx_pkt_cnt[4], rx_pkt_cnt[4]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH4 PKT CNT MISMATCHED TX4_PKT_CNT = `h%h, RX4_PKT_CNT = `h%h ",tx_pkt_cnt[4], rx_pkt_cnt[4]));
            end  

            if (tx_pkt_cnt[5] == rx_pkt_cnt[5]) begin
             `uvm_info(get_type_name(),$sformatf("CH5 PKT CNT MATCHED TX5_PKT_CNT = 'h%h: RX5_PKT_CNT = `h%h", tx_pkt_cnt[5], rx_pkt_cnt[5]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH5 PKT CNT MISMATCHED TX5_PKT_CNT = `h%h, RX5_PKT_CNT = `h%h ",tx_pkt_cnt[5], rx_pkt_cnt[5]));
            end  


            // CHECK DESC CNT
            if(rdesc_cnt[0]==wdesc_cnt[0]) begin
             `uvm_info(get_type_name(),$sformatf("CHO DESC CNT MATCHED TX0_DESC_CNT = 'h%h: RX0_DESC_CNT = `h%h", rdesc_cnt[0], wdesc_cnt[0]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CHO WBK_DESC CNT = 'h%h", (wbk_desc_cnt[0])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH0 DESC CNT MISMATCHED TX0_DESC_CNT = `h%h, RX0_DESC_CNT = `h%h ",rdesc_cnt[0], wdesc_cnt[0]));
             `uvm_info(get_type_name(),$sformatf("CHO WBK_DESC CNT = 'h%h", (wbk_desc_cnt[0])/3),UVM_LOW);
            end  
            if(rdesc_cnt[1]==wdesc_cnt[1]) begin
             `uvm_info(get_type_name(),$sformatf("CH1 DESC CNT MATCHED TX1_DESC_CNT = 'h%h: RX1_DESC_CNT = `h%h", rdesc_cnt[1], wdesc_cnt[1]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH1 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[1])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH1 DESC CNT MISMATCHED TX1_DESC_CNT = `h%h, RX1_DESC_CNT = `h%h ",rdesc_cnt[1], wdesc_cnt[1]));
             `uvm_info(get_type_name(),$sformatf("CH1 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[1])/3),UVM_LOW);
            end  
            if(rdesc_cnt[2]==wdesc_cnt[2]) begin
             `uvm_info(get_type_name(),$sformatf("CH2 DESC CNT MATCHED TX2_DESC_CNT = 'h%h: RX2_DESC_CNT = `h%h", rdesc_cnt[2], wdesc_cnt[2]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH2 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[2])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH2 DESC CNT MISMATCHED TX2_DESC_CNT = `h%h, RX2_DESC_CNT = `h%h ",rdesc_cnt[2], wdesc_cnt[2]));
             `uvm_info(get_type_name(),$sformatf("CH2 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[2])/3),UVM_LOW);
            end  
            if(rdesc_cnt[3]==wdesc_cnt[3]) begin
             `uvm_info(get_type_name(),$sformatf("CH3 DESC CNT MATCHED TX3_DESC_CNT = 'h%h: RX3_DESC_CNT = `h%h", rdesc_cnt[3], wdesc_cnt[3]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH3 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[3])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH3 DESC CNT MISMATCHED TX3_DESC_CNT = `h%h, RX3_DESC_CNT = `h%h ",rdesc_cnt[3], wdesc_cnt[3]));
             `uvm_info(get_type_name(),$sformatf("CH3 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[3])/3),UVM_LOW);
            end  
            if(rdesc_cnt[4]==wdesc_cnt[4]) begin
             `uvm_info(get_type_name(),$sformatf("CH4 DESC CNT MATCHED TX4_DESC_CNT = 'h%h: RX4_DESC_CNT = `h%h", rdesc_cnt[4], wdesc_cnt[4]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH4 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[4])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH4 DESC CNT MISMATCHED TX4_DESC_CNT = `h%h, RX4_DESC_CNT = `h%h ",rdesc_cnt[4], wdesc_cnt[4]));
             `uvm_info(get_type_name(),$sformatf("CH4 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[4])/3),UVM_LOW);
            end  
            if(rdesc_cnt[5]==wdesc_cnt[5]) begin
             `uvm_info(get_type_name(),$sformatf("CH5 DESC CNT MATCHED TX5_DESC_CNT = 'h%h: RX5_DESC_CNT = `h%h", rdesc_cnt[5], wdesc_cnt[5]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH5 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[5])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH5 DESC CNT MISMATCHED TX5_DESC_CNT = `h%h, RX5_DESC_CNT = `h%h ",rdesc_cnt[5], wdesc_cnt[5]));
             `uvm_info(get_type_name(),$sformatf("CH5 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[5])/3),UVM_LOW);
            end  
        end
  endfunction

   function check_data (int port, bit [15:0] wstrb, bit [127:0] exp_data, bit [127:0] obs_data); 
     case(wstrb)
     'h01: begin
             if (exp_data[7:0] == obs_data[7:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[7:0], obs_data[7:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[7:0], obs_data[7:0], wstrb));
             end
           end  
     'h03: begin
             if (exp_data[15:0] == obs_data[15:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[15:0], obs_data[15:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[15:0], obs_data[15:0], wstrb));
             end
           end
     'h07: begin
             if (exp_data[23:0] == obs_data[23:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[23:0], obs_data[23:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[23:0], obs_data[23:0], wstrb));
             end
           end
     'h0F: begin
             if (exp_data[31:0] == obs_data[31:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[31:0], obs_data[31:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[31:0], obs_data[31:0], wstrb));
             end
           end
     'h1F: begin
             if (exp_data[39:0] == obs_data[39:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[39:0], obs_data[39:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[39:0], obs_data[39:0], wstrb));
             end
           end
     'h3F: begin
             if (exp_data[47:0] == obs_data[47:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[47:0], obs_data[47:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[47:0], obs_data[47:0], wstrb));
             end
           end
     'h7F: begin
             if (exp_data[55:0] == obs_data[55:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[55:0], obs_data[55:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[55:0], obs_data[55:0], wstrb));
             end
           end
     'hFF: begin
             if (exp_data[63:0] == obs_data[63:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[63:0], obs_data[63:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[63:0], obs_data[63:0], wstrb));
             end
           end
     'h1FF: begin
             if (exp_data[71:0] == obs_data[71:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[71:0], obs_data[71:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[71:0], obs_data[71:0], wstrb));
             end
           end
     'h3FF: begin
             if (exp_data[79:0] == obs_data[79:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[79:0], obs_data[79:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[79:0], obs_data[79:0], wstrb));
             end
           end
     'h7FF: begin
             if (exp_data[87:0] == obs_data[87:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[87:0], obs_data[87:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[87:0], obs_data[87:0], wstrb));
             end
           end
     'hFFF: begin
             if (exp_data[95:0] == obs_data[95:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[95:0], obs_data[95:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[95:0], obs_data[95:0], wstrb));
             end
           end
     'h1FFF: begin
             if (exp_data[103:0] == obs_data[103:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[103:0], obs_data[103:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[103:0], obs_data[103:0], wstrb));
             end
           end
     'h3FFF: begin
             if (exp_data[111:0] == obs_data[111:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[111:0], obs_data[111:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[111:0], obs_data[111:0], wstrb));
             end
           end
     'h7FFF: begin
             if (exp_data[119:0] == obs_data[119:0]) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[119:0], obs_data[119:0], wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[119:0], obs_data[119:0], wstrb));
             end
           end
     'hFFFF: begin
             if (exp_data == obs_data) begin
                `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data, obs_data, wstrb),UVM_LOW);
             end
             else begin
                `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data, obs_data, wstrb));
             end
           end
     endcase
   endfunction //else

endclass : fptp_scoreboard
