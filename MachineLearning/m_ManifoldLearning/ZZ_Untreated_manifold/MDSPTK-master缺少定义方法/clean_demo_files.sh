#!/bin/sh
#Remove all files for MDSPTK demonstaration.

#MATLAB test-benches
rm -r -f *.m

#C sources and headers
rm -r -f *.c *.h

#data files
rm -r -f *.dat

#Exe
rm plane_data
rm fir_demo
rm iir_demo
rm sos_demo

