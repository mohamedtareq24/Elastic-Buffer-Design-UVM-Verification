`ifndef RD_DRIVER_SV
`define RD_DRIVER_SV

class rd_driver extends uvm_driver#(rd_item);
  `uvm_component_utils(rd_driver)

  virtual rd_stream_if#(20) vif;

  function new(string name = "rd_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual rd_stream_if#(20))::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"virtual rd_stream_if must be set for: ", get_full_name(), ".vif"})
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    rd_item tr;

    wait (vif.arst_n === 1'b1);

    forever begin
      seq_item_port.get_next_item(tr);

      repeat (tr.hold_cycles) begin
        @(posedge vif.clk);
        vif.rdy <= tr.ready;
      end

      seq_item_port.item_done();
    end
  endtask

endclass

`endif
