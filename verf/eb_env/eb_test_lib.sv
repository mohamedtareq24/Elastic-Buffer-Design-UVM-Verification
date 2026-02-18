class eb_test_base extends uvm_test;
  `uvm_component_utils(eb_test_base)
  eb_env env;
  clk_base_seq clk_seq;
  wr_base_seq wr_seq;

  function new(string name = "eb_test_base", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = eb_env::type_id::create("env", this);

    clk_seq = clk_base_seq::type_id::create("clk_seq");
    wr_seq  = wr_base_seq ::type_id::create("wr_seq");
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Printing Test Topology...", UVM_LOW)
    uvm_top.print_topology(); 
  endfunction

  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);  
    `uvm_info(get_type_name(), "Checking for unused configurations...", UVM_LOW)
    check_config_usage();
  endfunction

  //-------------------------------------------------------------------------
  // UVM Runtime Phases
  //-------------------------------------------------------------------------
  // reset_phase: Apply reset via clk interface
  // main_phase: Start clock + write sequences
  //-------------------------------------------------------------------------

  virtual task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Entered reset_phase()", UVM_LOW)
    
    // Apply reset via clock interface
    env.clk_ag.driver.vif.apply_reset(10);
    
    phase.drop_objection(this);
  endtask

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Entered main_phase()", UVM_LOW)

    // Start clock and write sequences in parallel
    fork
      begin
        `uvm_info(get_type_name(), $sformatf("Starting clock sequence of type: %s", clk_seq.get_type_name()), UVM_LOW)
        clk_seq.start(env.clk_ag.sequencer);
      end
      begin
        `uvm_info(get_type_name(), $sformatf("Starting write sequence of type: %s", wr_seq.get_type_name()), UVM_LOW)
        wr_seq.start(env.wr_ag.sequencer);
      end
    join_any

    phase.drop_objection(this);
  endtask

endclass


class fifo_test extends eb_test_base;
/*
  fifo_test
  =========
  A test that uses the same clock for writing and reading.
*/
  `uvm_component_utils(fifo_test)

  function new(string name = "fifo_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(wr_base_seq::get_type(), wr_counting_seq::get_type());
    set_type_override_by_type(clk_base_seq::get_type(), clk_fifo_seq::get_type());
    super.build_phase(phase);
  endfunction

endclass


class eb_usb_test extends eb_test_base;

  `uvm_component_utils(eb_usb_test)

  function new(string name = "eb_usb_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(clk_base_seq::get_type(), clk_usb_seq::get_type());
    set_type_override_by_type(wr_base_seq::get_type(), wr_usb_seq::get_type());
    super.build_phase(phase);
  endfunction

endclass

class eb_counting_test extends eb_test_base;
  `uvm_component_utils(eb_counting_test)

  function new(string name = "eb_counting_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(clk_base_seq::get_type(), clk_usb_seq::get_type());
    set_type_override_by_type(wr_base_seq::get_type(), wr_usb_seq_counting::get_type());
    set_type_override_by_type(wr_item::get_type(), usb_wr_item::get_type());
    super.build_phase(phase);
  endfunction
endclass

