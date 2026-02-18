`ifndef WR_DRIVER_SV
`define WR_DRIVER_SV

class wr_driver extends uvm_driver#(wr_item);
  `uvm_component_utils(wr_driver)

  virtual wr_stream_if#(20) vif;

  function new(string name = "wr_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual wr_stream_if#(20))::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"virtual wr_stream_if must be set for: ", get_full_name(), ".vif"})
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    wr_item tr;

    vif.vld     <= 1'b0;
    vif.data_in <= '0;

    forever begin
      seq_item_port.get_next_item(tr);
      `uvm_info("WRDRV", {"Driving wr_item:\n", tr.sprint()}, UVM_HIGH)
      @(posedge vif.clk);
      vif.data_in <= tr.data;
      vif.vld     <= 1'b1;

      // @(posedge vif.clk);
      // vif.vld     <= 1'b0;

      seq_item_port.item_done();
    end
  endtask

endclass

`endif
