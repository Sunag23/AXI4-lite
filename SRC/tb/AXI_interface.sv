`include "axi_define.svh"

interface axi_if(input bit ACLK,ARESETn);


  logic [`ADDR_WIDTH-1:0] AWADDR;
  logic [2:0] AWPROT;
  logic AWVALID;
  logic AWREADY;

  logic [`DATA_WIDTH-1:0] WDATA;
  logic [(`DATA_WIDTH/8)-1:0] WSTRB;
  logic WVALID;
  logic WREADY;

  logic [1:0] BRESP;
  logic BVALID;
  logic BREADY;

  logic [`ADDR_WIDTH-1:0] ARADDR;
  logic [2:0] ARPROT;
  logic ARVALID;
  logic ARREADY;

  logic [`DATA_WIDTH-1:0] RDATA;
  logic [1:0] RRESP;
  logic RVALID;
  logic RREADY;

  clocking drv_cb@(posedge ACLK);
    default input #1 output #1;
    output AWADDR, AWPROT, AWVALID;
    output WDATA, WVALID, WSTRB;
    output BREADY;
    output ARADDR, ARPROT, ARVALID;
    output RREADY;

    input AWREADY;
    input WREADY;
    input BRESP, BVALID;
    input ARREADY;
    input RDATA, RRESP, RVALID;
  endclocking

  clocking mon_cb@(posedge ACLK);
    default input #1 output #1;
    input AWADDR, AWPROT, AWVALID, AWREADY;
    input WDATA, WSTRB, WVALID, WREADY;
    input BRESP, BVALID, BREADY;
    input ARADDR, ARPROT, ARVALID, ARREADY;
    input RDATA, RRESP, RVALID, RREADY;
  endclocking

  clocking MNR_cb@(posedge ACLK);
    default input #1 output #1;
    input AWADDR, AWPROT, AWVALID, AWREADY;
    input WDATA, WSTRB, WVALID, WREADY;
    input BRESP, BVALID, BREADY;
    input ARADDR, ARPROT, ARVALID, ARREADY;
    input RDATA, RRESP, RVALID, RREADY;
  endclocking

  modport DRIVER      (clocking drv_cb, input ACLK, ARESETn);
  modport MONITOR     (clocking mon_cb, input ACLK, ARESETn);
  modport MONITOR_OUT (clocking MNR_cb, input ACLK, ARESETn);

endinterface