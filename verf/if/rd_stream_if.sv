interface rd_stream_if #(parameter int DATA_WIDTH = 20) (
  input logic clk,
  input logic arst_n
);
  timeunit 1ns;
  timeprecision 1ps;
  logic [DATA_WIDTH-1:0]    data_out;
  logic                     vld;

  // modport dut: connect to DUT instance
  modport dut (
    output data_out,
    output vld
  );

  // modport tb: connect to TB driver/monitor
  modport tb (
    input  data_out,
    input  vld
  );
endinterface
