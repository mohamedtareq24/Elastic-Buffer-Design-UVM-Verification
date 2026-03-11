// Base APB sequence
class apb_base_seq extends uvm_sequence#(apb_tr);
    `uvm_object_utils(apb_base_seq)
    
    function new(string name = "apb_base_seq");
        super.new(name);
    endfunction
    
    bit [31:0] base_addr = 32'hA000_0000;
    
    // Task to write to APB register
    task write_reg(bit [31:0] addr, bit [31:0] data);
        apb_tr tr;
        tr = apb_tr::type_id::create("tr");
        start_item(tr);
        tr.addr  = addr;
        tr.data  = data;
        tr.wr_en = 1;
        finish_item(tr);
    endtask

    // Task to read from APB register
    task read_reg(bit [31:0] addr, output bit [31:0] data);
        apb_tr tr;
        tr = apb_tr::type_id::create("tr");
        start_item(tr);
        tr.addr  = addr;
        tr.wr_en = 0;
        finish_item(tr);
    endtask

    virtual task body();
        write_reg(base_addr + 32'h00, {31'h0, 1'b1});      // EB_CTRL
    endtask

endclass

// Sequence to configure APB wrapper registers
class apb_config_seq extends apb_base_seq;
    `uvm_object_utils(apb_config_seq)
    
    rand bit [5:0]  cor_max;
    rand bit [5:0]  cor_min;
    rand bit [19:0] cor_seq1;
    rand bit [19:0] cor_seq2;
    rand bit        enable;
    
    // Default constraints
    constraint defaults {
        cor_max  inside {[20:40]};
        cor_min  inside {[5:15]};
        cor_seq1 inside {[0:20'hFFFFF]};
        cor_seq2 inside {[0:20'hFFFFF]};
        enable   == 1;
    }
    
    function new(string name = "apb_config_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [31:0] dummy_data;
        
        `uvm_info("APB_CFG_SEQ", "Configuring APB wrapper registers", UVM_LOW)
        
        // Write configuration registers
        write_reg(base_addr + 32'h04, {26'h0, cor_max});       // EB_COR_CFG_MAX
        write_reg(base_addr + 32'h08, {26'h0, cor_min});       // EB_COR_CFG_MIN
        write_reg(base_addr + 32'h0C, {12'h0, cor_seq1});      // EB_COR_SEQ1
        write_reg(base_addr + 32'h10, {12'h0, cor_seq2});      // EB_COR_SEQ2
        write_reg(base_addr + 32'h00, {31'h0, enable});        // EB_CTRL
        
        `uvm_info("APB_CFG_SEQ", "Configuration complete", UVM_LOW)
    endtask

endclass

// Sequence to read status registers
class apb_status_read_seq extends apb_base_seq;
    `uvm_object_utils(apb_status_read_seq)
    
    function new(string name = "apb_status_read_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [31:0] data;
        
        `uvm_info("APB_STAT_SEQ", "Reading APB wrapper status registers", UVM_LOW)
        
        // Read status registers
        read_reg(base_addr + 32'h14, data); // EB_FILL_LEVEL
        read_reg(base_addr + 32'h18, data); // EB_SKP_ADD_CNT
        read_reg(base_addr + 32'h1C, data); // EB_SKP_RM_CNT
        read_reg(base_addr + 32'h20, data); // EB_SKP_EVENT
        read_reg(base_addr + 32'h24, data); // EB_ERR_STATUS
        
        `uvm_info("APB_STAT_SEQ", "Status read complete", UVM_LOW)
    endtask

endclass