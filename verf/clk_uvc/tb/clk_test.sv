import uvm_pkg::*;
import clk_pkg::*;
`include "uvm_macros.svh"

class clk_test extends uvm_test;
  `uvm_component_utils(clk_test)

    clk_agent     agent   ;
    clk_base_seq  seq     ;

  function new(string name = "clk_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent  = clk_agent::type_id::create("agent", this);
    seq    = clk_base_seq::type_id::create("seq");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    seq.start(agent.sequencer);

    phase.drop_objection(this);
  endtask

endclass

class usb_clk_test extends clk_test;
  `uvm_component_utils(usb_clk_test)

  function new(string name = "usb_clk_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(base_clk_transaction::get_type(), usb_clk_transaction::get_type());
    super.build_phase(phase);
  endfunction


endclass : usb_clk_test
  