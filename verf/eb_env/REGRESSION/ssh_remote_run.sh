#!/bin/bash

################################################################################
# Remote EB Regression Runner
#
# Description:
#   Simple wrapper to run the regression script and capture output
#   Designed for remote SSH execution
#
# Usage:
#   ssh_remote_run.sh
#
# This script will:
#   1. Navigate to the EB env directory
#   2. Run the regression suite
#   3. Display real-time output
#   4. Log all output to regression_output.log
#
################################################################################

# Ensure we're in the right directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

# Create timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_LOG="regression_output_${TIMESTAMP}.log"
OUTPUT_LOG_CLEAN="regression_output_${TIMESTAMP}_clean.log"
SUMMARY_LOG="regression_summary.log"

echo "================================================================================"
echo "EB Regression Suite - Remote Execution"
echo "Start Time: $(date)"
echo "Color Log File: $OUTPUT_LOG"
echo "Clean Log File: $OUTPUT_LOG_CLEAN"
echo "================================================================================"
echo ""

# Run regression and capture output
# Keep ANSI colors in terminal and color log, while producing a clean text log.
./run_regression.sh "$@" 2>&1 | tee "$OUTPUT_LOG" >(sed -r 's/\x1B\[[0-9;]*[[:alpha:]]//g' > "$OUTPUT_LOG_CLEAN")
EXIT_CODE=$?

# Create a summary file with timestamp
{
    echo "================================================================================"
    echo "EB Regression Summary"
    echo "Run Time: $(date)"
    echo "================================================================================"
    echo ""
    tail -n 20 "$OUTPUT_LOG_CLEAN"
} > "${SUMMARY_LOG}"

echo ""
echo "================================================================================"
echo "Summary saved to: $SUMMARY_LOG"
echo "Color log saved to: $OUTPUT_LOG"
echo "Clean log saved to: $OUTPUT_LOG_CLEAN"
echo "Log directory: $(pwd)/sim/"
echo "================================================================================"

exit $EXIT_CODE
