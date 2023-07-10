#!/bin/sh
#Copy all needed files for MDSPTK demonstaration from Matlab class foldes.

#ssource
cp ./@ssource/ssourceTB.m ./

#fanalyzer
cp ./@fanalyzer/fanalyzerTB.m ./

#fsaver
cp ./@fsaver/fsaverTB.m ./
#fsaver c-header
cp ./@fsaver/fsaver.h ./
#fsaver c-source demos
cp ./@fsaver/*.c ./



