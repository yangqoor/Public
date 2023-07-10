%   直方图双峰法
function [th,segImg]=th_DA(X,map)
    [m,n]=size(X);
    vHist=imhist(X,map);
    p=vHist(find(vHist>0))/(m*n);   %求每一不为零的灰度值的概率
    c1=sum((find(vHist>0))./p);     %求不为零的灰度值概率倒数的加权累加和
    c2=sum(ones(size(p))./p);       %求不为零的灰度值概率倒数的累加和
    th=c1/c2;                       %求出灰度值的加权平均值,即为待求阈值
    segImg=(X>th);