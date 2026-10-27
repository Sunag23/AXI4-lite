`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)

class axi_coverage extends uvm_component;
  `uvm_component_utils(axi_coverage)

  uvm_analysis_imp_wr #(axi_seq_item, axi_coverage) wr_export;
  uvm_analysis_imp_rd #(axi_seq_item, axi_coverage) rd_export;

  bit [31:0] addr_cov;
  bit [3:0]  wstrb_cov;
  bit [1:0]  resp_cov;
  bit        is_write;
  bit        is_read;

  covergroup axi_cg;
    option.per_instance = 1;
    option.name = "axi_functional_coverage";

    cp_operation_type: coverpoint {is_write, is_read} {
      bins write_op = {2'b10};
      bins read_op  = {2'b01};
    }

    cp_address_region: coverpoint addr_cov {
      bins normal_rw     = {[32'h00:32'h24], 32'h3C};
      bins read_only     = {32'h28, 32'h2C, 32'h30};
      bins write_only    = {32'h34, 32'h38};
      bins out_of_bounds = {[32'h40:32'hFFFFFFFF]};
    }

    cp_write_strobe: coverpoint wstrb_cov iff (is_write == 1) {
      bins strobe_combinations[] = {[4'b0000:4'b1111]};
    }

    cp_axi_response: coverpoint resp_cov {
      bins resp_okay   = {2'b00}; 
      bins resp_slverr = {2'b10}; 
      bins resp_decerr = {2'b11}; 
    }

    cross_op_x_address: cross cp_operation_type, cp_address_region;
    cross_op_x_response: cross cp_operation_type, cp_axi_response;
  endgroup

  function new(string name="axi_coverage", uvm_component parent=null);
    super.new(name, parent);
    axi_cg = new();
    wr_export = new("wr_export", this);
    rd_export = new("rd_export", this);
  endfunction

  virtual function void write_wr(axi_seq_item t);
    is_write  = 1; 
    is_read   = 0;
    addr_cov  = t.AWADDR;
    wstrb_cov = t.WSTRB;
    resp_cov  = t.BRESP;
    axi_cg.sample();
  endfunction

  virtual function void write_rd(axi_seq_item t);
    is_write  = 0; 
    is_read   = 1;
    addr_cov  = t.ARADDR;
    wstrb_cov = 4'b0000;
    resp_cov  = t.RRESP;
    axi_cg.sample();
  endfunction
endclass