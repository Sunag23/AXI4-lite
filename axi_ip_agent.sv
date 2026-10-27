class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)

  axi_sequencer sqr_h;
  axi_driver    drv_h;
  axi_monitor   mon_h;

  function new(string name = "axi_agent", uvm_component parent);
    super.new(name, parent);
    is_active = UVM_ACTIVE;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (get_is_active() == UVM_ACTIVE) begin
      sqr_h = axi_sequencer::type_id::create("sqr_h", this);
      drv_h = axi_driver::type_id::create("drv_h", this);
    end
    mon_h = axi_monitor::type_id::create("mon_h", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE)
      drv_h.seq_item_port.connect(sqr_h.seq_item_export);
  endfunction

endclass