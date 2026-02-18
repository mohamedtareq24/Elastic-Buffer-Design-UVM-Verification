`ifndef RD_BASE_SEQ_SV
`define RD_BASE_SEQ_SV


class rd_base_seq extends uvm_sequence#(rd_item);
  `uvm_object_utils(rd_base_seq)

  // Defaults: always ready
  rand int unsigned num_items;

  constraint c_items { num_items inside {[10:200]}; }

  function new(string name = "rd_base_seq");
    super.new(name);
  endfunction

  virtual task body();
    rd_item tr;

    for (int unsigned i = 0; i < num_items; i++) begin
      tr = rd_item::type_id::create($sformatf("tr_%0d", i));
      start_item(tr);
      tr.ready       = 1'b1;
      tr.hold_cycles = 1000;
      finish_item(tr);
    end
  endtask

endclass

`endif
