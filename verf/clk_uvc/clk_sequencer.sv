`ifndef CLK_SEQUENCER_SV
`define CLK_SEQUENCER_SV

class clk_sequencer extends uvm_sequencer#(base_clk_transaction);
  `uvm_component_utils(clk_sequencer)

  function new(string name = "clk_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass

`endif
