`ifndef CLK_MON_TR_SV
`define CLK_MON_TR_SV




class clk_mon_tr extends uvm_sequence_item;
  integer              sys_period;
  integer              cdr_period;

  `uvm_object_utils(clk_mon_tr)


  function new(string name = "clk_mon_tr");
    super.new(name);
  endfunction
endclass

`endif
