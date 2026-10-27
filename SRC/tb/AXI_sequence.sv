class axi_sequence extends uvm_sequence#(axi_seq_item);
  `uvm_object_utils(axi_sequence)

  axi_seq_item req;

  function new(string name = "axi_sequence");
    super.new(name);
  endfunction

  task body();
    req = axi_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize())
      `uvm_error(get_type_name(), "randomize failed")
    finish_item(req);
  endtask
endclass

class axi_write_only_sequence extends axi_sequence;
  `uvm_object_utils(axi_write_only_sequence)

  function new(string name = "axi_write_only_sequence");
    super.new(name);
  endfunction

  task body();    
    req = axi_seq_item::type_id::create("req");
    start_item(req);
    assert (req.randomize() with {
      AWVALID == 1;
      WVALID  == 1;
      ARVALID == 0;
      AWADDR[31:0] inside {[32'h00:32'h3c]};
      WSTRB inside {[0:15]};
    });
    finish_item(req);
  endtask
endclass

class axi_write_fsm_seq extends axi_sequence;
  `uvm_object_utils(axi_write_fsm_seq)

  function new(string name = "axi_write_fsm_seq");
    super.new(name);
  endfunction

  task body();
    repeat (30) begin
      req = axi_seq_item::type_id::create("req");
      start_item(req);
      assert (req.randomize() with {
        AWVALID == 1;
        WVALID  == 1;
        ARVALID == 0;
      });
      finish_item(req);
    end
  endtask
endclass

class axi_read_only_sequence extends axi_sequence;
  `uvm_object_utils(axi_read_only_sequence)

  function new(string name = "axi_read_only_sequence");
    super.new(name);
  endfunction

  task body();
    req = axi_seq_item::type_id::create("req");
    start_item(req);
    assert (req.randomize() with {
      AWVALID == 0;
      WVALID  == 0;
      ARVALID == 1;
      ARADDR[31:0] inside {[32'h00:32'h3c]};
    });
    finish_item(req);
  endtask
endclass

class axi_write_read_sequence extends axi_sequence;
  `uvm_object_utils(axi_write_read_sequence)

  function new(string name = "axi_write_read_sequence");
    super.new(name);
  endfunction

  task body();
    repeat (20) begin
      req = axi_seq_item::type_id::create("req");
      start_item(req);
      assert (req.randomize() with {
        AWVALID == 1;
        WVALID  == 1;
        ARVALID == 1;
       
      });
      finish_item(req);
    end
  endtask
endclass

class axi_data_before_addr_seq extends axi_sequence;
  `uvm_object_utils(axi_data_before_addr_seq)

  function new(string name = "axi_data_before_addr_seq");
    super.new(name);
  endfunction

  task body();
    req = axi_seq_item::type_id::create("req");
    start_item(req);
    assert (req.randomize() with {
      AWVALID == 1;
      WVALID  == 1;
      ARVALID == 0;
      aw_delay == 5; 
      w_delay  == 0;
    });
    finish_item(req);
  endtask
endclass

class axi_error_seq extends axi_sequence;
  `uvm_object_utils(axi_error_seq)
  
  function new(string name = "axi_error_seq");
    super.new(name);
  endfunction

  task body();
    req = axi_seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { AWVALID == 1; WVALID == 1; ARVALID == 0; AWADDR[1:0] != 2'b00; });
    finish_item(req);

    req = axi_seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { AWVALID == 1; WVALID == 1; ARVALID == 0; AWADDR inside {32'd40, 32'd44, 32'd48}; });
    finish_item(req);

    req = axi_seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { ARVALID == 1; AWVALID == 0; WVALID == 0; ARADDR inside {32'd52, 32'd56}; });
    finish_item(req);

    req = axi_seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { AWVALID == 1; WVALID == 1; ARVALID == 0; AWADDR >= 32'd64; });
    finish_item(req);
    
    req = axi_seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { ARVALID == 1; AWVALID == 0; WVALID == 0; ARADDR >= 32'd64; });
    finish_item(req);
  endtask
endclass

class axi_partial_strobe_seq extends axi_sequence;
  `uvm_object_utils(axi_partial_strobe_seq)

  function new(string name = "axi_partial_strobe_seq");
    super.new(name);
  endfunction

  task body();
    repeat(10) begin
      req = axi_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with { 
        AWVALID == 
         1; 
        WVALID  == 1; 
        ARVALID == 0;
        AWADDR < 32'd40; 
        AWADDR[1:0] == 2'b00; 
        WSTRB inside {4'b0000, 4'b0001, 4'b0010, 4'b0100, 4'b1000, 4'b0101, 4'b1010}; 
      });
      finish_item(req);
    end
  endtask
endclass

class axi_cross_coverage_seq extends axi_sequence;
  `uvm_object_utils(axi_cross_coverage_seq)

  function new(string name = "axi_cross_coverage_seq");
    super.new(name);
  endfunction

  task body();
    req = axi_seq_item::type_id::create("req");
    start_item(req);
    req.is_write = 0;
    assert(req.randomize() with { ARVALID == 1; AWVALID == 0; WVALID == 0; ARADDR == 32'h28; });
    finish_item(req);

    req = axi_seq_item::type_id::create("req");
    start_item(req);
    req.is_write = 1;
    assert(req.randomize() with { AWVALID == 1; WVALID == 1; ARVALID == 0; AWADDR == 32'h34; WSTRB == 4'hF; });
    finish_item(req);

    req = axi_seq_item::type_id::create("req");
    start_item(req);
    req.is_write = 1;
    assert(req.randomize() with { AWVALID == 1; WVALID == 1; ARVALID == 0; AWADDR == 32'h28; WSTRB == 4'hF; });
    finish_item(req);

    req = axi_seq_item::type_id::create("req");
    start_item(req);
    req.is_write = 0;
    assert(req.randomize() with { ARVALID == 1; AWVALID == 0; WVALID == 0; ARADDR == 32'h34; });
    finish_item(req);

    req = axi_seq_item::type_id::create("req");
    start_item(req);
    req.is_write = 1;
    assert(req.randomize() with { AWVALID == 1; WVALID == 1; ARVALID == 0; AWADDR == 32'h40; WSTRB == 4'hF; });
    finish_item(req);

    req = axi_seq_item::type_id::create("req");
    start_item(req);
    req.is_write = 0;
    assert(req.randomize() with { ARVALID == 1; AWVALID == 0; WVALID == 0; ARADDR == 32'h40; });
    finish_item(req);
    
    req = axi_seq_item::type_id::create("req");
    start_item(req);
    req.is_write = 0;
    assert(req.randomize() with { ARVALID == 1; AWVALID == 0; WVALID == 0; ARADDR == 32'h01; });
    finish_item(req);
  endtask
endclass
