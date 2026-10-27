`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act_wr)
`uvm_analysis_imp_decl(_act_rd)

class axi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_scoreboard)

  uvm_analysis_imp_exp #(axi_seq_item, axi_scoreboard) exp_port;
  uvm_analysis_imp_act_wr #(axi_seq_item, axi_scoreboard) act_wr_port;
  uvm_analysis_imp_act_rd #(axi_seq_item, axi_scoreboard) act_rd_port;

  axi_seq_item exp_wr_q[$];
  axi_seq_item exp_rd_q[$];
  
 
  axi_seq_item act_wr_q[$];
  axi_seq_item act_rd_q[$];

  int pass_count = 0;
  int fail_count = 0;

  function new(string name = "axi_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    exp_port    = new("exp_port", this);
    act_wr_port = new("act_wr_port", this);
    act_rd_port = new("act_rd_port", this);
  endfunction

  function void write_exp(axi_seq_item t);
    if (t.AWVALID)
      exp_wr_q.push_back(t);
    else if (t.ARVALID)
      exp_rd_q.push_back(t);
  endfunction

 
  function void write_act_wr(axi_seq_item t);
    act_wr_q.push_back(t);
  endfunction

  
  function void write_act_rd(axi_seq_item t);
    act_rd_q.push_back(t);
  endfunction

  
  task run_phase(uvm_phase phase);
    fork
     
      forever begin
        axi_seq_item exp_pkt, act_pkt;
        wait (exp_wr_q.size() > 0 && act_wr_q.size() > 0);
        
        exp_pkt = exp_wr_q.pop_front();
        act_pkt = act_wr_q.pop_front();

        if ((exp_pkt.BRESP  === act_pkt.BRESP)  &&
            (exp_pkt.AWADDR === act_pkt.AWADDR) &&
            (exp_pkt.WDATA  === act_pkt.WDATA)  &&
            (exp_pkt.WSTRB  === act_pkt.WSTRB)) begin
          pass_count++;
          `uvm_info(get_type_name(), $sformatf("WRITE MATCH: exp_AWADDR=0x%0h act_AWADDR=0x%0h  exp_WDATA=0x%0h  act_WDATA=0x%0h", exp_pkt.AWADDR, act_pkt.AWADDR, exp_pkt.WDATA, act_pkt.WDATA ), UVM_LOW)
        end else begin
          fail_count++;
          `uvm_error(get_type_name(), $sformatf("WRITE MISMATCH: exp_BRESP=0x%0h act_BRESP=0x%0h, exp_WDATA=0x%0h  act_WDATA=0x%0h", exp_pkt.BRESP, act_pkt.BRESP, exp_pkt.WDATA, act_pkt.WDATA ))
        end
      end

      // Read comparison thread
      forever begin
        axi_seq_item exp_pkt, act_pkt;
        wait (exp_rd_q.size() > 0 && act_rd_q.size() > 0);
        
        exp_pkt = exp_rd_q.pop_front();
        act_pkt = act_rd_q.pop_front();

        if ((exp_pkt.RDATA  === act_pkt.RDATA) &&
            (exp_pkt.RRESP  === act_pkt.RRESP) &&
            (exp_pkt.ARADDR === act_pkt.ARADDR)) begin
          pass_count++;
          `uvm_info(get_type_name(), $sformatf("READ MATCH: exp_ARADDR=0x%0h act_ARADDR=0x%0h exp_RDATA=0x%0h, act_RDATA=0x%0h", exp_pkt.ARADDR, act_pkt.ARADDR, exp_pkt.RDATA, act_pkt.RDATA), UVM_LOW)
        end else begin
          fail_count++;
          `uvm_error(get_type_name(), $sformatf("READ MISMATCH: exp_ARADDR=0x%0h act_ARADDR=0x%0h exp_RDATA=0x%0h act_RDATA=0x%0h", exp_pkt.ARADDR, act_pkt.ARADDR, exp_pkt.RDATA, act_pkt.RDATA))
        end
      end
    join
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Total Passed : %0d", pass_count), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("Total Failed : %0d", fail_count), UVM_NONE)
    if (exp_wr_q.size() > 0 || act_wr_q.size() > 0)
       `uvm_error(get_type_name(), $sformatf("Leftover Writes! Exp: %0d, Act: %0d", exp_wr_q.size(), act_wr_q.size()))
  endfunction
endclass