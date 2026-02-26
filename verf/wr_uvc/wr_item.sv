class wr_item extends uvm_sequence_item;
  `uvm_object_utils(wr_item)
  rand bit [19:0] data;
  rand logic      is_skp;
  


  function new(string name = "wr_item");
    super.new(name);
  endfunction
endclass

class usb_wr_item extends wr_item;
  `uvm_object_utils(usb_wr_item)

  function new(string name = "usb_wr_item");
    super.new(name);
  endfunction
  constraint c_skp_dist {
    is_skp dist { 1 := 1, 0 := 176 };
  }

  constraint c_skp_data {
    if (is_skp) {
      data == eb_common_pkg::USB_SKP_VAL_1 ||
      data == eb_common_pkg::USB_SKP_VAL_2;
    }
    else {
      data != eb_common_pkg::USB_SKP_VAL_1;
      data != eb_common_pkg::USB_SKP_VAL_2;
    }
    // solve is_skp before data;
  }

endclass : usb_wr_item