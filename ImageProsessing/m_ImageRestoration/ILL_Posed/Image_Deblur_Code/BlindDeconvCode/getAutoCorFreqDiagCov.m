function A=getAutoCorFreqDiagCov(freqxcov,k_sz1,k_sz2)

[M1,M2]=size(freqxcov);
M=M1*M2;


pfreqxcov=ifft2(freqxcov)*M;


ssd=[pfreqxcov(end-k_sz1+2:end,end-k_sz2+2:end),...
     pfreqxcov(end-k_sz1+2:end,1:k_sz2);...
     pfreqxcov(1:k_sz1,end-k_sz2+2:end),...
     pfreqxcov(1:k_sz1,1:k_sz2)];


A=im2col(ssd,[k_sz1,k_sz2],'sliding');
A=A(:,end:-1:1)';
