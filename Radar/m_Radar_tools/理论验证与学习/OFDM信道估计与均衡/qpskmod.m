%qpskmod.m
%Function to perform QPSK modulation

function [iout,qout]=qpskmod(paradata,para,nd,ml)
%**************************variables********************************
%paradata: input data (para-by-nd matrix)
%iout: output Ich data
%qout: output Qch data
%para: Number of parallel channels
%nd: Number of data
%ml: Number of modulation levels
%(QPSK-2 16QAM-4)

%*******************************************************************
m2=ml./2;
paradata2=paradata.*2-1;
count2=0;
for jj=1:nd
    isi=zeros(para,1);
    isq=zeros(para,1);
    for ii=1:m2
        isi=isi+2.^(m2-ii)...
            .*paradata2((1:para),ii+count2);
        isq=isq+2.^(m2-ii)...
            .*paradata2((1:para),m2+ii+count2);
    end
    iout((1:para),jj)=isi;
    qout((1:para),jj)=isq;
    count2=count2+ml;
end
%**************************end of file*******************************