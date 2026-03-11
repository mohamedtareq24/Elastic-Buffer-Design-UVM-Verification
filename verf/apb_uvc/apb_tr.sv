class apb_tr extends uvm_sequence_item;
    `uvm_object_utils(apb_tr)
    
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit        wr_en;  // 1 for write, 0 for read

    function new(string name = "apb_tr");
        super.new(name);
    endfunction

    // Compare method with per-field mismatch reporting
    function bit compare(apb_tr rhs , apb_tr rhs_);
        bit pass;
        pass = 1'b1;

        if (rhs == null || rhs_ == null) begin
            `uvm_error("COMPARE", $sformatf("Null handle(s) in compare: rhs=%p rhs_=%p", rhs, rhs_))
            return 1'b0;
        end

        if (rhs.addr !== rhs_.addr) begin
            `uvm_error("COMPARE", $sformatf("ADDR mismatch: lhs=0x%08h rhs=0x%08h", rhs.addr, rhs_.addr))
            pass = 1'b0;
        end

        if (rhs.data !== rhs_.data) begin
            `uvm_error("COMPARE", $sformatf("DATA mismatch: lhs=0x%08h rhs=0x%08h", rhs.data, rhs_.data))
            pass = 1'b0;
        end

        if (rhs.wr_en !== rhs_.wr_en) begin
            `uvm_error("COMPARE", $sformatf("WR_EN mismatch: lhs=%0b rhs=%0b", rhs.wr_en, rhs_.wr_en))
            pass = 1'b0;
        end

        return pass;
    endfunction

    // Convert to string for printing
    function string stringify();
        return $sformatf("addr=0x%08h data=0x%08h wr_en=%0b", addr, data, wr_en);
    endfunction

endclass