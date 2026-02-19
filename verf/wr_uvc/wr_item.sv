class wr_item extends uvm_sequence_item;
  rand bit [19:0] data;
  rand logic      is_skp;

  `uvm_object_utils_begin(wr_item)
    `uvm_field_int(data,   UVM_ALL_ON)
    `uvm_field_int(is_skp, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "wr_item");
    super.new(name);
  endfunction
endclass

class usb_wr_item extends wr_item;
  `uvm_object_utils(usb_wr_item)

  function new(string name = "usb_wr_item");
    super.new(name);
  endfunction

  function post_randomize();
    if (is_skp) begin
      if ($urandom_range(0, 1) == 0) begin
        data = USB_SKP_VAL_1;
      end else begin
        data = USB_SKP_VAL_2;
      end
    end
  endfunction
endclass : usb_wr_item