interface wr_stream_if #(parameter int DATA_WIDTH = 20) (
  input logic clk,
  input logic arst_n
);
  timeunit 1ns;
  timeprecision 1ps;
  logic [DATA_WIDTH-1:0]    data_in;
  logic                     vld;
  logic                     rdy;

  // modport dut
  modport dut (
    input  data_in,
    input  vld,
    output rdy
  );

  // modport tb
  modport tb (
    output data_in,
    output vld,
    input  rdy
  );
endinterface
