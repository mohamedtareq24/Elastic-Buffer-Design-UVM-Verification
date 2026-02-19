`ifndef EB_ENV_SV
`define EB_ENV_SV


class eb_env extends uvm_env;
  `uvm_component_utils(eb_env)

  clk_agent clk_ag;
  wr_agent  wr_ag;
  rd_agent  rd_ag;

  eb_scoreboard scoreboard  ;
  eb_coverage_collector coverage_collector;

  function new(string name = "eb_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    clk_ag = clk_agent::type_id::create("clk_ag", this);
    wr_ag  = wr_agent ::type_id::create("wr_ag",  this);
    rd_ag  = rd_agent ::type_id::create("rd_ag",  this);
    
    scoreboard  = eb_scoreboard::type_id::create("scoreboard", this);
    coverage_collector = eb_coverage_collector::type_id::create("coverage_collector", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    // Push observed input/output transactions into the scoreboard.
    wr_ag.monitor.ap.connect(scoreboard.wr_fifo.analysis_export);
    rd_ag.monitor.ap.connect(scoreboard.rd_fifo.analysis_export);
    // Connect monitor analysis ports to coverage collector.
    wr_ag.monitor.ap.connect(coverage_collector.wr_mon_imp);
    rd_ag.monitor.ap.connect(coverage_collector.rd_mon_imp);
  endfunction

endclass

`endif
