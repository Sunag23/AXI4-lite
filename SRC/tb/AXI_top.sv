module top;
  import uvm_pkg::*;
  import test_pkg::*;

  bit ACLK, ARESETn;
  initial ACLK = 0;
  always #5 ACLK = ~ACLK;

  axi_if vif(ACLK, ARESETn);

  axi4_lite_slave #(
    .DATA_WIDTH(`DATA_WIDTH),
    .ADDR_WIDTH(`ADDR_WIDTH),
    .MEM_DEPTH (`MEM_DEPTH)
  ) dut (
    .ACLK    (vif.ACLK),
    .ARESETn (vif.ARESETn),
    .AWADDR  (vif.AWADDR),
    .AWPROT  (vif.AWPROT),
    .AWVALID (vif.AWVALID),
    .AWREADY (vif.AWREADY),
    .WDATA   (vif.WDATA),
    .WSTRB   (vif.WSTRB),
    .WVALID  (vif.WVALID),
    .WREADY  (vif.WREADY),
    .BRESP   (vif.BRESP),
    .BVALID  (vif.BVALID),
    .BREADY  (vif.BREADY),
    .ARADDR  (vif.ARADDR),
    .ARPROT  (vif.ARPROT),
    .ARVALID (vif.ARVALID),
    .ARREADY (vif.ARREADY),
    .RDATA   (vif.RDATA),
    .RRESP   (vif.RRESP),
    .RVALID  (vif.RVALID),
    .RREADY  (vif.RREADY)
  );

  bind dut axi4_lite_sva sva_inst (
    .ACLK    (ACLK),
    .ARESETn (ARESETn),
    .AWADDR  (AWADDR),
    .AWPROT  (AWPROT),
    .AWVALID (AWVALID),
    .AWREADY (AWREADY),
    .WDATA   (WDATA),
    .WSTRB   (WSTRB),
    .WVALID  (WVALID),
    .WREADY  (WREADY),
    .BRESP   (BRESP),
    .BVALID  (BVALID),
    .BREADY  (BREADY),
    .ARADDR  (ARADDR),
    .ARPROT  (ARPROT),
    .ARVALID (ARVALID),
    .ARREADY (ARREADY),
    .RDATA   (RDATA),
    .RRESP   (RRESP),
    .RVALID  (RVALID),
    .RREADY  (RREADY)
  );

  initial begin
    ARESETn = 1'b1;
    #1;
    ARESETn = 1'b0;
    #1;
    ARESETn = 1'b1;
  end

  initial begin
      ARESETn = 1'b0;
      #10;
      ARESETn = 1'b1;
  end

  initial begin
    uvm_config_db#(virtual axi_if.DRIVER)::set(null, "*", "vif", vif);
    uvm_config_db#(virtual axi_if.MONITOR)::set(null, "*", "vif", vif);
    uvm_config_db#(virtual axi_if.MONITOR_OUT)::set(null, "*", "vif", vif);

    run_test();
  end

endmodule