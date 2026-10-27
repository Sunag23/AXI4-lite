class axi_base_test extends uvm_test;
  `uvm_component_utils(axi_base_test)

  axi_env env_h;

  function new(string name = "axi_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_top.set_timeout(1_000_000, 0);
    env_h = axi_env::type_id::create("env_h", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass

class axi_seq1 extends axi_base_test;
  `uvm_component_utils(axi_seq1)

  axi_write_only_sequence wo_seq;
  axi_read_only_sequence  ro_seq;
  axi_write_read_sequence wr_rd_seq;

  function new(string name = "axi_seq1", uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    repeat(400) begin
      wo_seq = axi_write_only_sequence::type_id::create("wo_seq");
      wo_seq.start(env_h.agnt_h.sqr_h);
    end
    
    repeat(400) begin
      ro_seq = axi_read_only_sequence::type_id::create("ro_seq");
      ro_seq.start(env_h.agnt_h.sqr_h);
    end
    
    repeat (3000) begin
      wr_rd_seq = axi_write_read_sequence::type_id::create("wr_rd_seq");
      wr_rd_seq.start(env_h.agnt_h.sqr_h);
    end

    phase.drop_objection(this);
  endtask
endclass

class axi_fsm_corner_test extends axi_base_test;
  `uvm_component_utils(axi_fsm_corner_test)

  function new(string name = "axi_fsm_corner_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_data_before_addr_seq corner_seq;
    phase.raise_objection(this);
    
    corner_seq = axi_data_before_addr_seq::type_id::create("corner_seq");
    corner_seq.start(env_h.agnt_h.sqr_h); 
    
    phase.drop_objection(this);
  endtask
endclass

class axi_write_fsm_test extends axi_base_test;
  `uvm_component_utils(axi_write_fsm_test)

  function new(string name = "axi_write_fsm_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_write_fsm_seq fsm_seq;
    
    phase.raise_objection(this);
    
    fsm_seq = axi_write_fsm_seq::type_id::create("fsm_seq");
    fsm_seq.start(env_h.agnt_h.sqr_h);
    
    phase.drop_objection(this);
  endtask
endclass

class axi_error_test extends axi_base_test;
  `uvm_component_utils(axi_error_test)

  function new(string name = "axi_error_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_error_seq         err_seq;
    axi_partial_strobe_seq strobe_seq;
    
    phase.raise_objection(this);
    
    err_seq = axi_error_seq::type_id::create("err_seq");
    err_seq.start(env_h.agnt_h.sqr_h);
    
    strobe_seq = axi_partial_strobe_seq::type_id::create("strobe_seq");
    strobe_seq.start(env_h.agnt_h.sqr_h);
    
    phase.drop_objection(this);
  endtask
endclass

class axi_cross_coverage_test extends axi_base_test;
  `uvm_component_utils(axi_cross_coverage_test)

  function new(string name = "axi_cross_coverage_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_cross_coverage_seq cross_seq;
    phase.raise_objection(this);
    
    cross_seq = axi_cross_coverage_seq::type_id::create("cross_seq");
    cross_seq.start(env_h.agnt_h.sqr_h); 
    
    phase.drop_objection(this);
  endtask
endclass