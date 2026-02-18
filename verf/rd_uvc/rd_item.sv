`ifndef RD_ITEM_SV
`define RD_ITEM_SV

class rd_item extends uvm_sequence_item;
  // Ready driving item
  rand bit        ready;
  rand int unsigned hold_cycles;

  `uvm_object_utils_begin(rd_item)
    `uvm_field_int(ready,       UVM_ALL_ON)
    `uvm_field_int(hold_cycles, UVM_ALL_ON)
  `uvm_object_utils_end

  constraint c_hold { hold_cycles inside {[1:1000]}; }

  function new(string name = "rd_item");
    super.new(name);
  endfunction
endclass

`endif
