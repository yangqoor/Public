%   ֱ��ͼ˫�巨
function [th,segImg]=th_DA(X,map)
    [m,n]=size(X);
    vHist=imhist(X,map);
    p=vHist(find(vHist>0))/(m*n);   %��ÿһ��Ϊ��ĻҶ�ֵ�ĸ���
    c1=sum((find(vHist>0))./p);     %��Ϊ��ĻҶ�ֵ���ʵ����ļ�Ȩ�ۼӺ�
    c2=sum(ones(size(p))./p);       %��Ϊ��ĻҶ�ֵ���ʵ������ۼӺ�
    th=c1/c2;                       %����Ҷ�ֵ�ļ�Ȩƽ��ֵ,��Ϊ������ֵ
    segImg=(X>th);