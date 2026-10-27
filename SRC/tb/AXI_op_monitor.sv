class axi_op_monitor extends uvm_monitor;
  `uvm_component_utils(axi_op_monitor)

  virtual axi_if.MONITOR_OUT vif;
  uvm_analysis_port#(axi_seq_item) wr_port;
  uvm_analysis_port#(axi_seq_item) rd_port;

  function new(string name = "axi_op_monitor", uvm_component parent);
    super.new(name, parent);
    wr_port = new("wr_port", this);
    rd_port = new("rd_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if.MONITOR_OUT)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "failed to get virtual interface")
  endfunction

  task run_phase(uvm_phase phase);
    wait (vif.ARESETn === 1'b1);
    fork
      sample_write();
      sample_read();
    join
  endtask

  task sample_write();
    axi_seq_item tr;
    bit aw_done, w_done;
    bit [`ADDR_WIDTH-1:0]   aw_addr_cap;
    bit [`DATA_WIDTH-1:0]   w_data_cap;
    bit [`DATA_WIDTH/8-1:0] w_strb_cap;

    forever begin
      aw_done = 0;
      w_done  = 0;

      while (!(aw_done && w_done)) begin
        @(vif.MNR_cb);
        if (!aw_done && vif.MNR_cb.AWVALID && vif.MNR_cb.AWREADY) begin
          aw_addr_cap = vif.MNR_cb.AWADDR;
          aw_done = 1;
        end
        if (!w_done && vif.MNR_cb.WVALID && vif.MNR_cb.WREADY) begin
          w_data_cap = vif.MNR_cb.WDATA;
          w_strb_cap = vif.MNR_cb.WSTRB;
          w_done = 1;
        end
      end

      while (!(vif.MNR_cb.BVALID && vif.MNR_cb.BREADY))
        @(vif.MNR_cb);

      tr = axi_seq_item::type_id::create("tr");
      tr.is_write = 1;
      tr.AWADDR   = aw_addr_cap;
      tr.WDATA    = w_data_cap;
      tr.WSTRB    = w_strb_cap;
      tr.BRESP    = vif.MNR_cb.BRESP;

      wr_port.write(tr);
    end
  endtask

  task sample_read();
    axi_seq_item tr;
    bit [`ADDR_WIDTH-1:0] ar_addr_cap;

    forever begin
      do @(vif.MNR_cb);
      while (!(vif.MNR_cb.ARVALID && vif.MNR_cb.ARREADY));
      ar_addr_cap = vif.MNR_cb.ARADDR;

      do @(vif.MNR_cb);
      while (!(vif.MNR_cb.RVALID && vif.MNR_cb.RREADY));

      tr = axi_seq_item::type_id::create("tr");
      tr.is_write = 0;
      tr.ARADDR   = ar_addr_cap;
      tr.RDATA    = vif.MNR_cb.RDATA;
      tr.RRESP    = vif.MNR_cb.RRESP;

      rd_port.write(tr);
    end
  endtask

endclass