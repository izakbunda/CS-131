#!/bin/bash

# Define the input file
input_file="/usr/local/cs/jdk-21.0.2/lib/modules"

# Define output files for strace logs
gzip_log="gzip_strace.log"
pigz_log="pigz_strace.log"
pigzj_log="pigzj_strace.log"

# Ensure Pigzj is compiled and accessible, e.g., in the current directory or in the PATH

# Run gzip with strace
strace -c gzip -c $input_file > gzip_output.gz 2> $gzip_log

# Run pigz with strace
strace -c pigz -c $input_file > pigz_output.gz 2> $pigz_log

# Run Pigzj with strace, assuming Pigzj reads from standard input and writes to standard output
strace -c java Pigzj < $input_file > pigzj_output.gz 2> $pigzj_log

# Output the results
echo "System calls count for gzip:"
cat $gzip_log

echo "System calls count for pigz:"
cat $pigz_log

echo "System calls count for Pigzj:"
cat $pigzj_log
