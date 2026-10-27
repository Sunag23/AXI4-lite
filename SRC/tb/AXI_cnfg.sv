class axi_cnfg extends uvm_object;
	`uvm_object_utils(axi_cnfg)

	virtual axi_if vif;

	function new(string name="axi_cnfg");
		super.new(name);
	endfunction

	uvm_active_passive_enum input_agent=UVM_ACTIVE;
	uvm_active_passive_enum output_agent=UVM_PASSIVE;

endclass