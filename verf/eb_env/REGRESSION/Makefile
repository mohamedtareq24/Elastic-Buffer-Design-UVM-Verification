# Regression orchestration Makefile
# Runs full suite, then loads merged coverage in IMC.

SHELL := /bin/bash

SEED ?= 1
XRUN ?= /opt/rh/XCELIUM2009/tools/bin/xrun
PARENT_DIR := ..
COV_DB := $(PARENT_DIR)/cov_work/cov_work/scope/all

.PHONY: help regression imc_load regression_gui

help:
	@echo "Targets:"
	@echo "  make regression SEED=<n>    # Run run_regression.sh"
	@echo "  make imc_load               # Load merged coverage DB in IMC"
	@echo "  make regression_gui SEED=<n> # regression + imc_load"

regression:
	XRUN=$(XRUN) ./run_regression.sh --seed $(SEED)

imc_load:
	@if ! command -v imc > /dev/null 2>&1; then \
		echo "Error: imc not found in PATH"; \
		exit 1; \
	fi
	@if [ ! -d "$(COV_DB)" ]; then \
		echo "Error: merged coverage DB not found at $(COV_DB)"; \
		exit 1; \
	fi
	imc -load $(COV_DB)
	@echo "IMC load completed. Log: imc.log"

regression_gui: regression imc_load
	@echo "Regression GUI flow complete: regression finished and coverage DB loaded in IMC."
