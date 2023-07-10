%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        fsaverTB.m
% Dependencies:    -
% 
% MATLAB v:        8.0.0 (R2012b)
% 
% Organization:    SAL
% Design by:       
% Feedback:                 
%                  ___
%
% License:         MIT
% 
% 
%  ADDITIONAL NOTES:
%  _________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;

%% savePlaneData demo
pData = [0.1, 0.2, 0.3, 0.4; 0.6, 0.7, 0.8, 0.9]
fsaver.savePlaneData('./pdata.dat',pData, 2,'SavePlaneData() testing');

%Build and run
system('gcc -o ./plane_data ./plane_data_demo.c ./fsaver.h');
system('./plane_data');


%% saveFIR demo
%Two sensless 4-th order FIRs, print coefficients
firOrder = 4;
firb1 = fir1(firOrder, 0.3)
firb2 = fir1(firOrder, 0.7)

firData(1,:) = firb1; firData(2,:) = firb2;
fsaver.saveFIR('./fir.dat', firData, firOrder, 2, 'SaveFIR() testing');

%Build and run
system('gcc -o ./fir_demo ./fir_demo.c ./fsaver.h');
system('./fir_demo');


%% saveIIR demo
%Two Butterworth LP filters for example
iirOrder = 4;
[iirb1, iira1] = butter(iirOrder, 0.3)
[iirb2, iira2] = butter(iirOrder, 0.7)

iirNumData(1,:) = iirb1; iirNumData(2,:) = iirb2;
iirDenumData(1,:) = iira1; iirDenumData(2,:) = iira2;
 
fsaver.saveIIR('./iir.dat', iirNumData, iirDenumData, iirOrder, 2, 'SaveIIR() testing');

%Build and run
system('gcc -o ./iir_demo ./iir_demo.c ./fsaver.h');
system('./iir_demo');

%% saveSOS demo
%Two Butterworth LP filters for example, and convert it to sos and print it
sosOrder = 3;
[iirb1, iira1] = butter(sosOrder, 0.3); [sos1,g1]=tf2sos(iirb1, iira1)
[iirb2, iira2] = butter(sosOrder, 0.7); [sos2,g2]=tf2sos(iirb2, iira2)

g(1) = g1; g(2) = g2;
sos(1,:,:) = sos1;
sos(2,:,:) = sos2;

fsaver.saveSOS('./sos.dat', g, sos, sosOrder, 2, 'SaveSOS() testing');

%Build and run
system('gcc -o ./sos_demo ./sos_demo.c ./fsaver.h');
system('./sos_demo');

%% clean all
system('rm *.dat');
system('rm plane_data');
system('rm fir_demo');
system('rm iir_demo');
system('rm sos_demo');
