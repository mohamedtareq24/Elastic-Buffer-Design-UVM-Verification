`ifndef EB_CFG_SV
`define EB_CFG_SV

class eb_cfg extends uvm_object;
  `uvm_object_utils(eb_cfg)
  // TO BE REPLACED WITH FIELDS FROM a Register Model
  int unsigned fifo_depth;
  bit [19:0] skp_val_1;
  bit [19:0] skp_val_2;
  bit [19:0] cor_min; 
  bit [19:0] cor_max;


function new(string name = "eb_cfg");
  super.new(name);
  // Default SKP ordered sets from global enum
  skp_val_1 = USB_SKP_VAL_1;
  skp_val_2 = USB_SKP_VAL_2;
endfunction
endclass

`endif
