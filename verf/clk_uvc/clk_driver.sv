`ifndef CLK_DRIVER_SV
`define CLK_DRIVER_SV
class clk_driver extends uvm_driver#(base_clk_transaction);
    `uvm_component_utils(clk_driver)

    virtual clk_if vif;

    // Live clock configuration (updated by incoming sequence items)
    int unsigned sys_period_ps;
    int unsigned cdr_period_ps;
    bit          ssc_enable;
    int unsigned sys_ssc_ppm;
    int unsigned cdr_ssc_ppm;

    // SSC triangle ramp state (driver-owned state; persists across calls)
    real sys_current_delta_ps;
    real cdr_current_delta_ps;
    int  sys_ramp_dir;
    int  cdr_ramp_dir;

    function new(string name = "clk_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual clk_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", {"virtual clk_if must be set for: ", get_full_name(), ".vif"})
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        base_clk_transaction  base_tr;

        fork
            drive_sys_clk();
            drive_cdr_clk();
        join_none

        forever begin
            seq_item_port.get_next_item(base_tr);

            // Print the received transaction (useful for debug/bring-up)
            `uvm_info("CLKDRV", {"Got base_clk_transaction:\n", base_tr.sprint()}, UVM_MEDIUM)

            sys_period_ps = base_tr.sys_clk_period_ps;
            cdr_period_ps = base_tr.cdr_clk_period_ps;

            ssc_enable = base_tr.ssc_enable;
            sys_ssc_ppm = (base_tr.ssc_enable) ? base_tr.sys_ssc_ppm : 0;
            cdr_ssc_ppm = (base_tr.ssc_enable) ? base_tr.cdr_ssc_ppm : 0;

            if (ssc_enable) begin
                sys_current_delta_ps = real'(base_tr.sys_curnt_offset_ps);
                cdr_current_delta_ps = real'(base_tr.cdr_curnt_offset_ps);
                sys_ramp_dir = (base_tr.sys_ssc_dir) ? 1 : -1;
                cdr_ramp_dir = (base_tr.cdr_ssc_dir) ? 1 : -1;
            end

            // Run for requested duration, then accept the next item
            repeat (base_tr.run_cycles) @(posedge vif.sys_clk);

            seq_item_port.item_done();
        end
    endtask

    task automatic drive_sys_clk();
        // Toggle sys_clk forever. Period is updated dynamically via shared vars.
        vif.sys_clk = 1'b0;
        forever begin
            real period_ps;
            real half_period_ps;
            period_ps = get_next_period_ps(real'(sys_period_ps), sys_ssc_ppm, sys_current_delta_ps, sys_ramp_dir);
            if (period_ps != 0.0) 
            begin
                half_period_ps = period_ps / 2.0 ;
                #(half_period_ps * 1ps);
                vif.sys_clk = ~vif.sys_clk;
            end
            else begin
                #(100 * 1ps);
            end
        end
    endtask

    task automatic drive_cdr_clk();
        // Toggle cdr_clk forever. Period is updated dynamically via shared vars.
        vif.cdr_clk = 1'b0;
        forever begin
            real period_ps;
            real half_period_ps;
            period_ps = get_next_period_ps(real'(cdr_period_ps), cdr_ssc_ppm, cdr_current_delta_ps, cdr_ramp_dir);
            if (period_ps != 0.0) 
            begin
                half_period_ps = period_ps / 2.0;
                #(half_period_ps * 1ps);
                vif.cdr_clk = ~vif.cdr_clk;
            end
            else begin
                #(100 * 1ps);
            end
        end
    endtask

    
    function automatic real get_next_period_ps(
        input real base_period_ps, // e.g., 4000.0
        input int  ssc_ppm,        // e.g., 4000 ~ 5000 PPM

        ref   real current_delta,  // STATE: Where we are in the triangle (e.g., 12.5 ps)
        ref   int  ramp_dir        // STATE: +1 (Slowing) or -1 (Speeding)
    );
        real max_delta_ps;
        real step_ps;
        
        // 1. Calculate Limits
        // Max deviation = 4000 * 0.005 = 20 ps
        max_delta_ps = base_period_ps * (real'(ssc_ppm) / 1_000_000.0);
        
        // 2. How many clk cycles per ramp ?
        // Steps per ramp = (1 / 33kHz) / 4ns  ~= 7576 steps
        
        // If ppm is 0, step is 0.
        if (ssc_ppm > 0)
            step_ps = max_delta_ps / 7576.0;  // divide by steps per ramp
        else 
            step_ps = 0;

        // 3. Update the Ramp State (The Accumulation)
        if (ssc_ppm > 0) begin
            if (ramp_dir == 1) begin
                current_delta += step_ps;
                // If we hit the peak (20ps), start going down
                if (current_delta >= max_delta_ps) ramp_dir = -1;
            end 
            else begin
                current_delta -= step_ps;
                // If we hit the bottom (0ps), start going up
                if (current_delta <= 0.0) ramp_dir = 1;
            end
        end else begin
            current_delta = 0.0;
        end

        // 4. Return Final Period
        return base_period_ps + current_delta;
        
    endfunction

endclass
    
`endif
