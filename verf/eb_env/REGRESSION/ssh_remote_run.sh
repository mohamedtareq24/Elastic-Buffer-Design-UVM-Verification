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
SUMMARY_LOG="regression_summary.log"

echo "================================================================================"
echo "EB Regression Suite - Remote Execution"
echo "Start Time: $(date)"
echo "Log File: $OUTPUT_LOG"
echo "================================================================================"
echo ""

# Run regression and capture output
./run_regression.sh "$@" 2>&1 | tee "$OUTPUT_LOG"
EXIT_CODE=$?

# Create a summary file with timestamp
{
    echo "================================================================================"
    echo "EB Regression Summary"
    echo "Run Time: $(date)"
    echo "================================================================================"
    echo ""
    tail -n 20 "$OUTPUT_LOG"
} > "${SUMMARY_LOG}"

echo ""
echo "================================================================================"
echo "Summary saved to: $SUMMARY_LOG"
echo "Full log saved to: $OUTPUT_LOG"
echo "Log directory: $(pwd)/sim/"
echo "================================================================================"

exit $EXIT_CODE
