class axi_ref_model extends uvm_subscriber #(axi_seq_item);
  `uvm_component_utils(axi_ref_model)

  uvm_analysis_port#(axi_seq_item) exp_port;

  bit [`DATA_WIDTH-1:0] mem [0:15];

  function new(string name = "axi_ref_model", uvm_component parent);
    super.new(name, parent);
    exp_port = new("exp_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    foreach (mem[i])
      mem[i] = 0;
  endfunction

  function void write(axi_seq_item t);
    axi_seq_item exp_pkt;
    bit [3:0] word_addr;
    bit       unaligned;
    bit       addr_ok;
    bit       ro_region;
    bit       wo_region;

    exp_pkt = axi_seq_item::type_id::create("exp_pkt");

    if (t.AWVALID) begin
      word_addr = t.AWADDR[5:2];
      unaligned = |t.AWADDR[1:0];
      addr_ok   = (t.AWADDR < 64);
      ro_region = (word_addr >= 10) && (word_addr <= 12);

      exp_pkt.AWADDR  = t.AWADDR;
      exp_pkt.AWPROT  = t.AWPROT;
      exp_pkt.WDATA   = t.WDATA;
      exp_pkt.WSTRB   = t.WSTRB;
      exp_pkt.AWVALID = 1;
      exp_pkt.WVALID  = 1;
      exp_pkt.ARVALID = 0;

      if (!addr_ok) begin
        exp_pkt.BRESP = 2'b11;
      end else if (ro_region || unaligned) begin
        exp_pkt.BRESP = 2'b10;
      end else begin
        if (t.WSTRB[0]) mem[word_addr][ 7: 0] = t.WDATA[ 7: 0];
        if (t.WSTRB[1]) mem[word_addr][15: 8] = t.WDATA[15: 8];
        if (t.WSTRB[2]) mem[word_addr][23:16] = t.WDATA[23:16];
        if (t.WSTRB[3]) mem[word_addr][31:24] = t.WDATA[31:24];
        exp_pkt.BRESP = 2'b00;
      end

      exp_port.write(exp_pkt);
    end
    else if (t.ARVALID) begin
      word_addr = t.ARADDR[5:2];
      unaligned = |t.ARADDR[1:0];
      addr_ok   = (t.ARADDR < 64);
      wo_region = (word_addr >= 13) && (word_addr <= 14);

      exp_pkt.ARADDR  = t.ARADDR;
      exp_pkt.ARPROT  = t.ARPROT;
      exp_pkt.ARVALID = 1;
      exp_pkt.AWVALID = 0;

      if (!addr_ok) begin
        exp_pkt.RRESP = 2'b11;
        exp_pkt.RDATA = 0;
      end else if (wo_region || unaligned) begin
        exp_pkt.RRESP = 2'b10;
        exp_pkt.RDATA = 0;
      end else begin
        exp_pkt.RRESP = 2'b00;
        exp_pkt.RDATA = mem[word_addr];
      end

      exp_port.write(exp_pkt);
    end
  endfunction

endclass