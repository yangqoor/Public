function [ mi,mf,ni,nf ] = quadrante( dir,M,N )
%UNTITLED5 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
if(dir==0||dir==1)
   mi=1;
   mf=M/2;
   ni=N/2+1;
   nf=N;
end
if(dir==4||dir==5)
    mi=M/2+1;
    mf=M;
    ni=1;
    nf=N/2;
end
if(dir==6||dir==7)
   mi=M/2+1;
   mf=M;
   ni=N/2+1;
   nf=N;
end
end

