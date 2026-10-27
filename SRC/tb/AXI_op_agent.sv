class axi_op_agent extends uvm_agent;
  `uvm_component_utils(axi_op_agent)

  axi_op_monitor monr_h;

  function new(string name = "axi_op_agent", uvm_component parent);
    super.new(name, parent);
    is_active = UVM_PASSIVE;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monr_h = axi_op_monitor::type_id::create("monr_h", this);
  endfunction

endclass