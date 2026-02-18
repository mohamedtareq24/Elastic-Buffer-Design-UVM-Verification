
interface apb_if #(parameter int ADDR_WIDTH = 32, parameter int DATA_WIDTH = 32) (
  input logic pclk,
  input logic preset_n
);

  logic                   psel;
  logic                   penable;
  logic                   pwrite;
  logic [ADDR_WIDTH-1:0]  paddr;
  logic [DATA_WIDTH-1:0]  pwdata;
  logic [DATA_WIDTH-1:0]  prdata;
  logic                   pready;

  // modport dut: connect to APB slave (apb_wrapper)
  modport dut (
    input  pclk,
    input  preset_n,
    input  psel,
    input  penable,
    input  pwrite,
    input  paddr,
    input  pwdata,
    output prdata,
    output pready
  );

  // modport tb: connect to APB driver/monitor
  modport tb (
    input  pclk,
    input  preset_n,
    output psel,
    output penable,
    output pwrite,
    output paddr,
    output pwdata,
    input  prdata,
    input  pready
  );
endinterface
