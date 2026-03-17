# Xcelium/XRUN Makefile for EB UVM environment
# Intended to be run on the Linux server from:
#   /mnt/hgfs/Digital_Electronics/giesh/EB
# which maps to Windows:
#   D:\Digital_Electronics\giesh\EB

XRUN ?= /opt/rh/XCELIUM2009/tools/bin/xrun

TOP      ?= eb_tb_top
TEST     ?= eb_usb_test
SEED     ?= 1

TOP      ?= eb_tb_top

FILELIST ?= ./filelist.f
REGRESSION_DIR ?= ./REGRESSION

# Put all sim outputs under sim/<test>/ so logs are easy to find
RUN_DIR  ?= sim/$(TEST)
LOG_ELAB ?= $(RUN_DIR)/xrun_elab.log
LOG_RUN  ?= $(RUN_DIR)/xrun.log
LOG_GUI  ?= $(RUN_DIR)/xrun_gui.log
TEMP_DIR ?= $(HOME)/temp
COV_DIR  ?= $(TEMP_DIR)

# Basic options (keep it simple/portable)
XRUN_OPTS ?= \
    -64bit \
    -sv \
    -uvm \
    -access +rwc \
    +UVM_TESTNAME=$(TEST) \
    +UVM_VERBOSITY=UVM_MEDIUM \
    -svseed $(SEED) \
    -coverage all \
    -covoverwrite \
    -covworkdir $(COV_DIR) \
	-covtest $(TEST) \


# Keep compiled libs per-run to avoid collisions
XRUN_LIB_OPTS ?= -xmlibdirname $(RUN_DIR)/xcelium.d

# GUI options (SimVision)
XRUN_GUI_OPTS ?= \
	-gui \
	+UVM_TR_RECORD

.PHONY: help sim elab run gui regression_gui clean distclean

help:
	@echo "Targets:"
	@echo "  make sim TEST=<uvm_test> SEED=<n>"
	@echo "  make gui TEST=<uvm_test> SEED=<n>"
	@echo "  make regression_gui SEED=<n>  # Run full regression + IMC load"
	@echo "  make clean"
	@echo "Vars: XRUN=$(XRUN)"
	@echo "Example: make sim TEST=eb_test_base SEED=123"
	@echo "GUI Example: make gui TEST=eb_usb_test SEED=123"
	@echo "Example: make regression_gui SEED=123"

# One-shot compile+elab+run
sim: $(RUN_DIR)
	$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_ELAB) -elaborate
	$(XRUN) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_RUN) -R

# Optional split flow if you want it
elab: $(RUN_DIR)
	$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_ELAB) -elaborate

run:
	$(XRUN) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_RUN) -R

# Launch SimVision GUI (-gui) and run (-R)
gui: $(RUN_DIR)
	$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_ELAB) -elaborate
	$(XRUN) $(XRUN_LIB_OPTS) $(XRUN_OPTS) $(XRUN_GUI_OPTS) -l $(LOG_GUI) -R

# Delegate full regression orchestration to REGRESSION/Makefile
regression_gui:
	$(MAKE) -C $(REGRESSION_DIR) regression_gui XRUN=$(XRUN) SEED=$(SEED)

$(RUN_DIR):
	@mkdir -p $(RUN_DIR)

clean:
	@rm -rf xcelium.d INCA_libs waves.shm *.log *.key

