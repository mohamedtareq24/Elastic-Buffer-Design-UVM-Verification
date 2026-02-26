`ifndef RD_ITEM_SV
`define RD_ITEM_SV

class rd_item extends uvm_sequence_item;
  `uvm_object_utils(rd_item)
  // Ready driving item
  rand bit        ready;
  rand int unsigned hold_cycles;



  constraint c_hold { hold_cycles inside {[1:1000]}; }

  function new(string name = "rd_item");
    super.new(name);
  endfunction
endclass

`endif
