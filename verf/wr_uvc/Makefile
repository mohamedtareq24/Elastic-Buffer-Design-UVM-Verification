# Xcelium/XRUN Makefile for Write UVC standalone testing
# Intended to be run on the Linux server from:
#   /mnt/hgfs/Digital_Electronics/giesh/Design-and-Verification-of-an-Elastic-Buffer/verf/wr_uvc
# which maps to Windows:
#   D:\Digital_Electronics\giesh\Design-and-Verification-of-an-Elastic-Buffer\verf\wr_uvc

XRUN ?= /opt/rh/XCELIUM2009/tools/bin/xrun

TOP      ?= wr_tb_top
TEST     ?= wr_uvc_test
SEED     ?= 1

FILELIST ?= ./tb/run.f

# Put all sim outputs under sim/<test>/ so logs are easy to find
RUN_DIR  ?= sim/$(TEST)
LOG_ELAB ?= $(RUN_DIR)/xrun_elab.log
LOG_RUN  ?= $(RUN_DIR)/xrun.log
LOG_GUI  ?= $(RUN_DIR)/xrun_gui.log

# Basic options (keep it simple/portable)
XRUN_OPTS ?= \
	-64bit \
	-sv \
	-uvm \
	-access +rwc \
	+UVM_TESTNAME=$(TEST) \
	+UVM_VERBOSITY=UVM_MEDIUM \
	+ntb_random_seed=$(SEED)

# Keep compiled libs per-run to avoid collisions
XRUN_LIB_OPTS ?= -xmlibdirname $(RUN_DIR)/xcelium.d

# GUI options (SimVision)
XRUN_GUI_OPTS ?= \
	-gui \
	+UVM_TR_RECORD

.PHONY: help sim elab run gui clean distclean check

help:
	@echo "Targets:"
	@echo "  make sim TEST=<uvm_test> SEED=<n>"
	@echo "  make gui TEST=<uvm_test> SEED=<n>"
	@echo "  make clean"
	@echo "Vars: XRUN=$(XRUN)"
	@echo "Filelist: $(FILELIST)"
	@echo "Example: make sim TEST=wr_uvc_test SEED=123"

check:
	@command -v $(XRUN) >/dev/null 2>&1 || { echo "ERROR: XRUN not found: $(XRUN)"; exit 1; }
	@test -f $(FILELIST) || { echo "ERROR: FILELIST not found: $(FILELIST)"; exit 1; }

# One-shot compile+elab+run
sim: check $(RUN_DIR)
	$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_ELAB) -elaborate
	$(XRUN) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_RUN) -R

# Optional split flow if you want it
elab: check $(RUN_DIR)
	$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_ELAB) -elaborate

run: check
	$(XRUN) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_RUN) -R

# Launch SimVision GUI (-gui) and run (-R)
gui: check $(RUN_DIR)
	$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_ELAB) -elaborate
	$(XRUN) $(XRUN_LIB_OPTS) $(XRUN_OPTS) $(XRUN_GUI_OPTS) -l $(LOG_GUI) -R

$(RUN_DIR):
	@mkdir -p $(RUN_DIR)

# For completeness if xrun drops other outputs later
clean:
	@rm -rf xcelium.d INCA_libs waves.shm *.log *.key sim/
