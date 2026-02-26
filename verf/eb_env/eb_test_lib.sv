//=============================================================================
// eb_test_base
//=============================================================================
// Base test class for all elastic buffer tests.
// 
// Description:
//   Provides common infrastructure for elastic buffer verification:
//   - Instantiates the eb_env environment
//   - Creates default clock and write sequences
//   - Implements reset_phase: applies reset and starts clock generation
//   - Implements main_phase: starts write sequence
//   - Handles topology printing and configuration checking
// 

//=============================================================================
class eb_test_base extends uvm_test;
  `uvm_component_utils(eb_test_base)
  eb_env env;
  clk_base_seq clk_seq;
  wr_seq_base wr_seq;

  function new(string name = "eb_test_base", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = eb_env::type_id::create("env", this);

    clk_seq = clk_base_seq::type_id::create("clk_seq");
    wr_seq  = wr_seq_base ::type_id::create("wr_seq");
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

    `uvm_info(get_type_name(), $sformatf("Starting clock sequence of type: %s", clk_seq.get_type_name()), UVM_LOW)
    clk_seq.start(env.clk_ag.sequencer);
    
    phase.drop_objection(this);
  endtask

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Entered main_phase()", UVM_LOW)

    `uvm_info(get_type_name(), $sformatf("Starting write sequence of type: %s", wr_seq.get_type_name()), UVM_LOW)
    wr_seq.start(env.wr_ag.sequencer);

    phase.drop_objection(this);
  endtask
endclass


//=============================================================================
// fifo_test
//=============================================================================
// FIFO mode test using synchronous clocking.
// 
// Description:
//   Tests the elastic buffer operating in FIFO mode with the same clock domain
//   for both write and read interfaces. This verifies basic functionality without
//   clock domain crossing complexities.
// 
// Sequences Used:
//   - clk_fifo_seq: Generates synchronous clock for both interfaces
//   - wr_counting_seq: Writes incrementing data patterns for easy verification
// 
// Test Focus:
//   - Basic write/read functionality
//   - Data integrity in synchronous mode
//   - FIFO fill/empty conditions
//=============================================================================
class fifo_test extends eb_test_base;
  `uvm_component_utils(fifo_test)

  function new(string name = "fifo_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(wr_seq_base::get_type(), wr_counting_seq::get_type());
    set_type_override_by_type(clk_base_seq::get_type(), clk_fifo_seq::get_type());
    super.build_phase(phase);
  endfunction

endclass



//=============================================================================
// eb_counting_test
//=============================================================================
// USB mode test with counting data pattern for data integrity verification.
// 
// Description:
//   Similar to eb_usb_test but uses incrementing data patterns to simplify
//   data integrity checking in the scoreboard. The test uses USB-specific
//   transaction items and operates with asynchronous clocking.
// 
// Sequences Used:
//   - clk_usb_seq: Generates asynchronous clocks for USB operation
//   - wr_usb_seq_counting: Writes incrementing data with periodic SKPs
// 
// Item Override:
//   - Uses usb_wr_item instead of base wr_item for USB-specific fields
// 
// Test Focus:
//   - Data integrity verification with predictable patterns
//   - USB clock compensation mechanism
//   - Correct data ordering after SKP removal
//=============================================================================
class eb_counting_test extends eb_test_base;
  `uvm_component_utils(eb_counting_test)

  function new(string name = "eb_counting_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(clk_base_seq::get_type(), clk_usb_seq::get_type());
    set_type_override_by_type(wr_seq_base::get_type(), wr_counting_seq::get_type());
      set_type_override_by_type(wr_item::get_type(), usb_wr_item::get_type());
    super.build_phase(phase);
  endfunction
endclass

//=============================================================================
// eb_wr_skp_test
//=============================================================================
// SKP ordered set drop functionality test.
// 
// Description:
//   Tests the elastic buffer's SKP drop mechanism when the buffer fill level
//   exceeds the SKP drop threshold. The test first fills the buffer with
//   non-SKP data, then sends random SKP ordered sets to exercise the drop logic.
// 
// Sequences Used:
//   - wr_skp_clk: Custom clock sequence for SKP drop testing
//   - fastest cdr clock and slowest sys clock
//   - wr_skp_drop_seq: Two-phase sequence:
//     1. Sends 100 counting transactions (no SKPs) to fill buffer
//     2. Sends 10000 transactions with random SKP distribution (1% SKPs)
// 
// Test Focus:
//   - SKP ordered set drop when buffer is above threshold
//   - Buffer overflow prevention via SKP removal
//   - Elastic buffer depth management under high SKP density
//   - Data integrity while dropping SKPs
//=============================================================================
class eb_wr_skp_test extends eb_test_base;
  `uvm_component_utils(eb_wr_skp_test)

  function new(string name = "eb_wr_skp_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(clk_base_seq::get_type(), wr_skp_drop_clk::get_type());
    set_type_override_by_type(wr_seq_base::get_type(), wr_skp_drop_seq::get_type());
    set_type_override_by_type(wr_item::get_type(), usb_wr_item::get_type());
    super.build_phase(phase);
  endfunction
endclass

class eb_rd_skp_test extends eb_test_base; 
  `uvm_component_utils(eb_rd_skp_test) 
  function new(string name = "eb_rd_skp_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(clk_base_seq::get_type(), rd_skp_insert_clk::get_type());
    set_type_override_by_type(wr_seq_base::get_type(), wr_skp_multi_packet_seq::get_type());
    set_type_override_by_type(wr_item::get_type(), usb_wr_item::get_type());
    super.build_phase(phase);
  endfunction
endclass


// =============================================================================
// eb_usb_test
// =============================================================================
// USB 3.0 Gen1 compliant test with periodic SKP ordered sets.

// Description:
//   Tests the elastic buffer in USB 3.0 Gen1 operation mode with asynchronous
//   clocking. Verifies proper handling of SKP ordered sets that are inserted
//   periodically according to USB 3.0 specification (approximately every 354 symbols).

// Sequences Used:
//   - clk_usb_seq: Generates asynchronous clocks simulating USB PHY behavior
//   - wr_usb_seq: Writes data with periodic SKP ordered sets per USB 3.0 spec

// Test Focus:
//   - Asynchronous clock domain crossing
//   - USB 3.0 SKP ordered set handling
//   - Clock compensation via SKP insertion/removal
//   - Elastic buffer depth management
// =============================================================================
class eb_usb_test extends eb_test_base;

  `uvm_component_utils(eb_usb_test)

  function new(string name = "eb_usb_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(clk_base_seq::get_type(), clk_max_ssc_seq::get_type());
    set_type_override_by_type(wr_seq_base::get_type(), wr_skp_multi_packet_seq::get_type());
    set_type_override_by_type(wr_item::get_type(), usb_wr_item::get_type());
    super.build_phase(phase);
  endfunction

endclass


