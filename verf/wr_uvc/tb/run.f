
# Xcelium run file for standalone Write UVC bring-up
#
# Example:
#   xrun -f verf/wr_uvc/tb/run.f -top wr_tb_top +UVM_TESTNAME=wr_uvc_test +ntb_random_seed=1 -R

-64bit
-sv
-uvm
-access +rwc
// default timescale
-timescale 1ps/1fs
+UVM_TESTNAME=wr_uvc_test
+UVM_VERBOSITY=UVM_MEDIUM

+incdir+./
+incdir+./tb
+incdir+../if

../if/wr_stream_if.sv
./wr_pkg.sv
./tb/wr_uvc_test.sv
./tb/wr_tb_top.sv
