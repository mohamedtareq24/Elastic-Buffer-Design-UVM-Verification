`ifndef WR_SEQUENCER_SV
`define WR_SEQUENCER_SV

class wr_sequencer extends uvm_sequencer#(wr_item);
  `uvm_component_utils(wr_sequencer)

  function new(string name = "wr_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass

`endif
