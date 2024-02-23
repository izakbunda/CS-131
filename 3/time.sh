#!/bin/bash

# Define the input file
input="/usr/local/cs/jdk-21.0.2/lib/modules"

# Ensure Java class is compiled
javac Pigzj.java

# # gzip compression
# echo "Running gzip..."
# time gzip -c <"$input" >gzip.gz

# pigz compression
echo "Running pigz..."
time pigz -c -p1 <"$input" >pigz.gz

# Java Pigzj compression
echo "Running Java Pigzj..."
time java Pigzj -p2 <"$input" >Pigzj.gz

# List the file sizes
ls -l gzip.gz pigz.gz Pigzj.gz