#!/bin/bash

# Check PINTOS_HOME is set
if [ -z "$PINTOS_HOME" ]; then
  echo "[ERROR] PINTOS_HOME is not set. Please set it before running this script."
  exit 1
fi

# Set key paths
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"
BUILD_PATH="$PINTOS_HOME/threads/build"
TEST_DIR="$BUILD_PATH/tests/threads"
RESULTS_FILE="$SCRIPT_PATH/results"
GRADING_FILE="$PINTOS_HOME/tests/threads/Grading"
MAKE_GRADE_SCRIPT="$PINTOS_HOME/tests/make-grade"

# Check build directory
if [ ! -d "$BUILD_PATH" ]; then
  echo "[ERROR] Build directory does not exist: $BUILD_PATH"
  echo "Please run 'make' in $PINTOS_HOME/threads before running this script."
  exit 1
fi

# echo "[INFO] Generating results file from test outputs..."

# Clear previous results
rm -f "$RESULTS_FILE"

# Collect result files
shopt -s nullglob
result_files=($TEST_DIR/*.result)
shopt -u nullglob

if [ ${#result_files[@]} -eq 0 ]; then
  echo "[WARNING] No .result files found in $TEST_DIR"
  echo "[INFO] Skipping grading. No tests have been run yet."
  exit 0
fi

for result_file in "${result_files[@]}"; do
  test_name=$(basename "$result_file" .result)
  verdict=$(cat "$result_file")
  if [[ "$verdict" == "PASS" ]]; then
    echo "pass tests/threads/$test_name" >> "$RESULTS_FILE"
  else
    echo "FAIL tests/threads/$test_name" >> "$RESULTS_FILE"
  fi
done

# echo "[INFO] Results written to $RESULTS_FILE"

# Check required files
if [ ! -f "$GRADING_FILE" ]; then
  echo "[ERROR] Grading file not found: $GRADING_FILE"
  exit 1
fi

if [ ! -f "$MAKE_GRADE_SCRIPT" ]; then
  echo "[ERROR] make-grade script not found: $MAKE_GRADE_SCRIPT"
  exit 1
fi

echo
"$MAKE_GRADE_SCRIPT" "$PINTOS_HOME" "$RESULTS_FILE" "$GRADING_FILE" | awk '/^DETAILS OF /{exit} {print}'
