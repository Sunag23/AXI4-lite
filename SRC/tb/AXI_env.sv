class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)

  axi_agent      agnt_h;
  axi_op_agent   agnt_op;
  axi_scoreboard scr_h;
  axi_ref_model  ref_h;
  axi_coverage   cvg_h;

  function new(string name = "axi_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agnt_h  = axi_agent::type_id::create("agnt_h", this);
    agnt_op = axi_op_agent::type_id::create("agnt_op", this);
    scr_h   = axi_scoreboard::type_id::create("scr_h", this);
    ref_h   = axi_ref_model::type_id::create("ref_h", this);
    cvg_h   = axi_coverage::type_id::create("cvg_h", this); 
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    agnt_h.mon_h.wr_port.connect(ref_h.analysis_export);
    agnt_h.mon_h.rd_port.connect(ref_h.analysis_export);

    ref_h.exp_port.connect(scr_h.exp_port);

    agnt_op.monr_h.wr_port.connect(scr_h.act_wr_port);
    agnt_op.monr_h.rd_port.connect(scr_h.act_rd_port);
    
    agnt_h.mon_h.wr_port.connect(cvg_h.wr_export);
    agnt_h.mon_h.rd_port.connect(cvg_h.rd_export);

  endfunction

endclass