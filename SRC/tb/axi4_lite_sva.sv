module axi4_lite_sva (
    input logic        ACLK,
    input logic        ARESETn,
    input logic [31:0] AWADDR,
    input logic [ 2:0] AWPROT,
    input logic        AWVALID,
    input logic        AWREADY,
    input logic [31:0] WDATA,
    input logic [ 3:0] WSTRB,
    input logic        WVALID,
    input logic        WREADY,
    input logic [ 1:0] BRESP,
    input logic        BVALID,
    input logic        BREADY,
    input logic [31:0] ARADDR,
    input logic [ 2:0] ARPROT,
    input logic        ARVALID,
    input logic        ARREADY,
    input logic [31:0] RDATA,
    input logic [ 1:0] RRESP,
    input logic        RVALID,
    input logic        RREADY
);

  default disable iff (!ARESETn);

  property p_awvalid_stable;
    @(posedge ACLK) (AWVALID && !AWREADY) |-> ##1 AWVALID;
  endproperty
  A_AWVALID_STABLE: assert property (p_awvalid_stable) 
    else $error("AXI4-Lite Protocol Error: AWVALID changed before AWREADY handshake!");

  property p_wvalid_stable;
    @(posedge ACLK) (WVALID && !WREADY) |-> ##1 WVALID;
  endproperty
  A_WVALID_STABLE: assert property (p_wvalid_stable) 
    else $error("AXI4-Lite Protocol Error: WVALID changed before WREADY handshake!");

  property p_arvalid_stable;
    @(posedge ACLK) (ARVALID && !ARREADY) |-> ##1 ARVALID;
  endproperty
  A_ARVALID_STABLE: assert property (p_arvalid_stable) 
    else $error("AXI4-Lite Protocol Error: ARVALID changed before ARREADY handshake!");

  property p_bvalid_handshake_cov;
    @(posedge ACLK) (BVALID && BREADY);
  endproperty
  C_BVALID_HANDSHAKE: cover property (p_bvalid_handshake_cov);

  property p_rvalid_handshake_cov;
    @(posedge ACLK) (RVALID && RREADY);
  endproperty
  C_RVALID_HANDSHAKE: cover property (p_rvalid_handshake_cov);

endmodule