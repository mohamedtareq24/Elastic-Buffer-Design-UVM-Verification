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
    assert(tr.randomize())
    else `uvm_fatal("CLKSEQ", "Failed to randomize fifo clock transaction")

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

// Testing Write controller SKP handling
// Write clock period is set faster than read clock to trigger SKP drops in the write controller 
//when the buffer exceeds the max threshold
class wr_skp_drop_clk extends clk_base_seq;
  `uvm_object_utils(wr_skp_drop_clk)

  function new(string name = "wr_skp_drop_clk");
    super.new(name);
  endfunction
  
  base_clk_transaction tr;

  virtual task body();
    tr = base_clk_transaction::type_id::create("tr");
    start_item(tr);
    assert(tr.randomize() with {
        ssc_enable == 0 ;          
      }) else `uvm_fatal("CLKSEQ", "Failed to randomize SKP insert clock transaction")
    tr.ssc_enable = 0; // Force SSC off to simplify SKP insertion testing
    tr.sys_clk_period_ps = 4020; 
    tr.cdr_clk_period_ps = 3999; 
    finish_item(tr);
  endtask
endclass


// For Testing Read controller SKP handling
// Read clock period is set slower than write clock to trigger SKP insertions in the read controller 
//when the buffer is lower than min threshold
class rd_skp_insert_clk extends clk_base_seq;
  `uvm_object_utils(rd_skp_insert_clk)

  function new(string name = "rd_skp_insert_clk");
    super.new(name);
  endfunction
  
  base_clk_transaction tr;

  virtual task body();
    tr = base_clk_transaction::type_id::create("tr");
    start_item(tr);
    assert(tr.randomize() with {
        ssc_enable == 0 ;          
      }) else `uvm_fatal("CLKSEQ", "Failed to randomize SKP insert clock transaction")
    tr.ssc_enable = 0; // Force SSC off to simplify SKP insertion testing
    tr.sys_clk_period_ps = 3999; 
    tr.cdr_clk_period_ps = 4020; 
    finish_item(tr);
  endtask
  endclass
