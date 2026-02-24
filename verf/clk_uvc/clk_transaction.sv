`ifndef CLK_TRANSACTION_SV
`define CLK_TRANSACTION_SV
class base_clk_transaction extends uvm_sequence_item;

  rand int unsigned sys_clk_period_ps;
  rand int unsigned cdr_clk_period_ps;
  rand int unsigned sys_ssc_ppm;    
  rand int unsigned cdr_ssc_ppm;    

  rand bit sys_ssc_dir;  // Ramp Direction:  0=down, 1=up
  rand bit cdr_ssc_dir;  // 0=down, 1=up

  rand int unsigned sys_curnt_offset_ps; // where are we in the ramp (ps)
  rand int unsigned cdr_curnt_offset_ps;  

  rand bit          ssc_enable;

  `uvm_object_utils_begin(base_clk_transaction)
    `uvm_field_int(sys_clk_period_ps, UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(cdr_clk_period_ps, UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(sys_ssc_ppm,       UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(cdr_ssc_ppm,       UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(sys_ssc_dir,       UVM_ALL_ON)
    `uvm_field_int(cdr_ssc_dir,       UVM_ALL_ON)
    `uvm_field_int(ssc_enable,       UVM_ALL_ON)
  `uvm_object_utils_end
  

  constraint c_periods {
    sys_clk_period_ps == 4000 ;  // 4ns +/- 1ps
    cdr_clk_period_ps == 4000 ;
  }

  constraint c_ssc {
    sys_ssc_ppm   == 0    ; 
    cdr_ssc_ppm   == 0    ;
  }
  
  constraint ssc_enable_c {
    ssc_enable == 0 ;
  }

  constraint c_sys_curnt_offset_ps {
    sys_curnt_offset_ps   == 0 ;  
    cdr_curnt_offset_ps   == 0 ;  
  }

  function new(string name = "base_clk_transaction");
    super.new(name);
  endfunction
endclass

class usb_clk_transaction extends base_clk_transaction;
  `uvm_object_utils(usb_clk_transaction)
  constraint c_periods {
    sys_clk_period_ps inside {[3999:4001]};  // 4ns +/- 1ps
    cdr_clk_period_ps inside {[3999:4001]};
  }

  constraint ssc_enable_c {
    ssc_enable == 1 ;
  }
  constraint c_ssc {
    sys_ssc_ppm inside {[4000:5000]} ; 
    cdr_ssc_ppm inside {[4000:5000]} ;

    (ssc_enable == 0) -> (sys_ssc_ppm == 0);
    (ssc_enable == 0) -> (cdr_ssc_ppm == 0);
  }

  constraint c_sys_curnt_offset_ps {
    sys_curnt_offset_ps inside {[0:20]}; 
    cdr_curnt_offset_ps inside {[0:20]};
  }

  function new(string name = "usb_clk_transaction");
    super.new(name);
  endfunction

endclass : usb_clk_transaction
`endif