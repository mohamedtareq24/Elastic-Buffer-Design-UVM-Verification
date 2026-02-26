`ifndef RD_MON_TR_SV
`define RD_MON_TR_SV

class rd_mon_tr extends uvm_sequence_item;
  `uvm_object_utils(rd_mon_tr)
  logic [19:0] data;




  function new(string name = "rd_mon_tr");
    super.new(name);
  endfunction
endclass

`endif
