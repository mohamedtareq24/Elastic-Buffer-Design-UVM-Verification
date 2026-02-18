`ifndef CLK_MON_TR_SV
`define CLK_MON_TR_SV




class clk_mon_tr extends uvm_sequence_item;
  integer              sys_period;
  integer              cdr_period;

  `uvm_object_utils_begin(clk_mon_tr)
    `uvm_field_int(sys_period, UVM_ALL_ON)
    `uvm_field_int(cdr_period, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "clk_mon_tr");
    super.new(name);
  endfunction
endclass

`endif
