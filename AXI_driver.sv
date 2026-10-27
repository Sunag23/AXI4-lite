class axi_driver extends uvm_driver#(axi_seq_item);

	`uvm_component_utils(axi_driver)

	axi_seq_item drv_pkt;

	virtual axi_if.DRIVER vif;

	function new(string name="axi_driver", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual axi_if.DRIVER)::get(this, "", "vif", vif))
			`uvm_fatal(get_type_name(), "Failed to get virtual interface")
	endfunction

	task run_phase(uvm_phase phase);

		vif.drv_cb.AWVALID <= 0;
		vif.drv_cb.WVALID  <= 0;
		vif.drv_cb.ARVALID <= 0;
		vif.drv_cb.BREADY  <= 0;
		vif.drv_cb.RREADY  <= 0;

		forever begin

			seq_item_port.get_next_item(drv_pkt);

			if (drv_pkt.AWVALID && drv_pkt.ARVALID)
				drive_write_read();
			else if (drv_pkt.AWVALID)
				drive_write();
			else if (drv_pkt.ARVALID)
				drive_read();

			seq_item_port.item_done();

		end

	endtask

	virtual task drive_aw();
				repeat(drv_pkt.aw_delay) @(vif.drv_cb);
				vif.drv_cb.AWADDR  <= drv_pkt.AWADDR;
				vif.drv_cb.AWPROT  <= drv_pkt.AWPROT;
				vif.drv_cb.AWVALID <= 1;

				@(vif.drv_cb);
				while (!vif.drv_cb.AWREADY) @(vif.drv_cb);
				vif.drv_cb.AWVALID <= 0;
	endtask
			
	virtual task drive_w();	
		repeat(drv_pkt.w_delay) @(vif.drv_cb);
		vif.drv_cb.WDATA  <= drv_pkt.WDATA;
		vif.drv_cb.WSTRB  <= drv_pkt.WSTRB;
		vif.drv_cb.WVALID <= 1;

		@(vif.drv_cb);
		while (!vif.drv_cb.WREADY) @(vif.drv_cb);
		vif.drv_cb.WVALID <= 0;
	endtask
	

	virtual task drive_write();
		if(drv_pkt.w_delay < drv_pkt.aw_delay)
		begin
		drive_w();
		drive_aw();
		end
		else
		begin
		drive_aw();
		drive_w();
		end
		vif.drv_cb.BREADY <= 1;
		@(vif.drv_cb);
		while (!vif.drv_cb.BVALID) @(vif.drv_cb);

		drv_pkt.BRESP = vif.drv_cb.BRESP;
		vif.drv_cb.BREADY <= 0;

	endtask

	task drive_read();

		vif.drv_cb.ARADDR  <= drv_pkt.ARADDR;
		vif.drv_cb.ARPROT  <= drv_pkt.ARPROT;
		vif.drv_cb.ARVALID <= 1;

		@(vif.drv_cb);
		while (!vif.drv_cb.ARREADY) @(vif.drv_cb);

		vif.drv_cb.ARVALID <= 0;

		vif.drv_cb.RREADY <= 1;
		@(vif.drv_cb);
		while (!vif.drv_cb.RVALID) @(vif.drv_cb);

		drv_pkt.RDATA = vif.drv_cb.RDATA;
		drv_pkt.RRESP = vif.drv_cb.RRESP;
		vif.drv_cb.RREADY <= 0;

	endtask

	task drive_write_read();
		begin
			drive_write();
			drive_read();
		end
	endtask

endclass