`ifndef CLK_MONITOR_SV
`define CLK_MONITOR_SV

class clk_monitor extends uvm_component;
  `uvm_component_utils(clk_monitor)

  virtual clk_if vif;
  uvm_analysis_port#(clk_mon_tr) ap;

  realtime prev_sys_edge_time;
  realtime prev_cdr_edge_time;
  longint unsigned sys_edge_count;
  longint unsigned cdr_edge_count;
  bit sys_tr_ready = 0 ;
  bit cdr_tr_ready = 0 ;
  // Logging controls (keep output readable)
  int unsigned print_first_n = 20;
  bit          print_on_change = 1'b1;
  realtime     last_sys_period;
  realtime     last_cdr_period;

  function new(string name = "clk_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual clk_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"virtual clk_if must be set for: ", get_full_name(), ".vif"})
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    clk_mon_tr tr; // Create a transaction 


    fork
      monitor_sys_clk();
      monitor_cdr_clk();
    join_none

  endtask

  task automatic monitor_sys_clk();

    realtime t;
    realtime period_rt;
    clk_mon_tr tr;
    forever begin
      @(posedge vif.sys_clk);
      t = $realtime;
      sys_edge_count++;
      if (sys_edge_count > 1) begin
        tr = clk_mon_tr::type_id::create("tr");

        period_rt = t - prev_sys_edge_time;
        last_sys_period        = (period_rt);
        // Mirror measured values onto the interface for waveform viewing.
        vif.sys_period_meas    = time'(period_rt);
        vif.cdr_period_meas    = time'(last_cdr_period);

        if ((sys_edge_count <= (print_first_n + 1)) ||
            (print_on_change && (last_sys_period != 0) && (period_rt != last_sys_period))) begin
          `uvm_info("CLKMON",$sformatf("sys_clk period=%f ns", (period_rt) ),UVM_HIGH)
        end
        prev_sys_edge_time = t;

        tr.cdr_period = longint'(last_cdr_period);
        tr.sys_period = longint'(last_sys_period);
        ap.write(tr);
      end
    end
  endtask

  task automatic monitor_cdr_clk();

    realtime t;
    realtime period_rt;
    clk_mon_tr tr;
    forever begin
      @(posedge vif.cdr_clk);
      t = $realtime;
      cdr_edge_count++;
      if (cdr_edge_count > 1) begin
        tr = clk_mon_tr::type_id::create("tr");

        period_rt = t - prev_cdr_edge_time;
        last_cdr_period        = (period_rt);
        // Mirror measured values onto the interface for waveform viewing.
        vif.sys_period_meas    = time'(last_sys_period);
        vif.cdr_period_meas    = time'(period_rt);

        if ((cdr_edge_count <= (print_first_n + 1)) ||
            (print_on_change && (last_cdr_period != 0) && (period_rt != last_cdr_period))) begin
          `uvm_info("CLKMON",$sformatf("cdr_clk period=%f ns", (period_rt) ),UVM_HIGH)
        end
        prev_cdr_edge_time = t;

        tr.cdr_period = longint'(last_cdr_period);
        tr.sys_period = longint'(last_sys_period);
        ap.write(tr);
      end
    end
  endtask
endclass

`endif
