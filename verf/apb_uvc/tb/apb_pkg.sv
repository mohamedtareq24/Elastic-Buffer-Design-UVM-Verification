// APB Wrapper Package
// Contains all components for APB wrapper verification
package apb_wrapper_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import apb_pkg::*;

    // Include all APB wrapper verification components
    `include "apb_wrapper_seq_lib.sv"
    `include "apb_wrapper_env.sv"
    `include "apb_wrapper_test.sv"

endpackage
