`ifndef RD_MON_TR_SV
`define RD_MON_TR_SV

class rd_mon_tr extends uvm_sequence_item;
  logic [19:0] data;

  `uvm_object_utils_begin(rd_mon_tr)
    `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "rd_mon_tr");
    super.new(name);
  endfunction
endclass

`endif
