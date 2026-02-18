class clk_base_seq extends uvm_sequence#(base_clk_transaction);
  `uvm_object_utils(clk_base_seq)

  function new(string name = "clk_base_seq");
    super.new(name);
  endfunction

  virtual task body();
    base_clk_transaction tr;
    tr = base_clk_transaction::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize()) begin
      `uvm_fatal("CLKSEQ", "Failed to randomize base/usb clock transaction")
    end
    finish_item(tr);
  endtask
endclass

class clk_fifo_seq extends clk_base_seq;
  `uvm_object_utils(clk_fifo_seq)

  function new(string name = "clk_fifo_seq");
    super.new(name);
  endfunction

  virtual task body();
    base_clk_transaction tr;
    tr = base_clk_transaction::type_id::create("tr");
    start_item(tr);
    assert(tr.randomize() with {
        run_cycles == 64 ;
      })else`uvm_fatal("CLKSEQ", "Failed to randomize fifo clock transaction")

    finish_item(tr);
  endtask
endclass


class clk_usb_seq extends clk_base_seq;
  `uvm_object_utils(clk_usb_seq)

  function new(string name = "clk_usb_seq");
    super.new(name);
  endfunction

  virtual task body();
    usb_clk_transaction tr;
    tr = usb_clk_transaction::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize()) begin
      `uvm_fatal("CLKSEQ", "Failed to randomize usb clock transaction")
    end
    finish_item(tr);
  endtask
endclass

class clk_usb_seq_over_flow extends clk_usb_seq;
  `uvm_object_utils(clk_usb_seq_over_flow)

  function new(string name = "clk_usb_seq_over_flow");
    super.new(name);
  endfunction

  virtual task body();
    usb_clk_transaction tr;
    tr = usb_clk_transaction::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize() with {
        sys_clk_period_ps    == 4001 ;
        cdr_clk_period_ps    == 3999 ;
        sys_ssc_ppm          == 5000 ;
        cdr_ssc_ppm          == 0 ;
        sys_ssc_dir          == 1 ; // up
        cdr_ssc_dir          == 0 ; // down
        sys_curnt_offset_ps  == 0 ;
        cdr_curnt_offset_ps  == 0 ;
        ssc_enable           == 1 ;
      }) begin
      `uvm_fatal("CLKSEQ", "Failed to randomize usb clock transaction (worst-case)")
    end
    finish_item(tr);
  endtask

endclass

class clk_usb_seq_under_flow extends clk_usb_seq;

  `uvm_object_utils(clk_usb_seq_under_flow)

  function new(string name = "clk_usb_seq_under_flow");
    super.new(name);
  endfunction

  virtual task body();
    usb_clk_transaction tr;
    tr = usb_clk_transaction::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize() with {
        sys_clk_period_ps    == 3999 ;
        cdr_clk_period_ps    == 4001 ;
        sys_ssc_ppm          == 0 ;
        cdr_ssc_ppm          == 5000 ;
        sys_ssc_dir          == 0 ; // down
        cdr_ssc_dir          == 1 ; // up
        sys_curnt_offset_ps  == 0 ;
        cdr_curnt_offset_ps  == 0 ;
        ssc_enable           == 1 ;
      }) begin
      `uvm_fatal("CLKSEQ", "Failed to randomize usb clock transaction (best-case)")
    end
    finish_item(tr);
  endtask

endclass