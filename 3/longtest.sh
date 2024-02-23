#!/bin/bash

javac CompressionThread.java
javac Pigzj.java
java Pigzj </usr/local/cs/jdk-21.0.2/lib/modules >test3.gz
gzip -dk test3.gz