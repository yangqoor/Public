%   二维直方图最大熵法
%   算法参考文献: 龚坚,李立源,陈维南. 二维熵阈值分割的快速算法. 东南大学学报,1996,26(4):31-36
function [Th,segImg] = entropy_2D(cX)
    [m,n]=size(cX);
    
    cX=double(cX);
    
    %计算原图象的8邻域灰度图
    myfilt=[1/8,1/8,1/8;1/8,0,1/8;1/8,1/8,1/8];
    g=round(filter2(myfilt,cX));
    
    %构建二维直方图
    h_2d=zeros(256);    %初始化
    for i=1:m
        for j=1:n
            r=cX(i,j)+1;c=g(i,j)+1;
            h_2d(r,c)=h_2d(r,c)+1;
        end
    end
    
    %归一化直方图
    p=h_2d/(m*n);    
    
    %累加二维直方图
    Ps=cumsum(cumsum(p,1),2);
    temp=(p+eps).*(p==0)+p;
    Hs=cumsum(cumsum(-p.*log(temp),1),2);
    
    temp=(Ps+eps).*(Ps==0)+Ps;
    H0=log(temp)+Hs./temp;

    Ps=1-Ps;
    temp=(Ps+eps).*(Ps==0)+Ps;
    H1=log(temp)+(Hs(256,256)-Hs)./temp;

    ResultMatrix=H0+H1;
    
%     H=[H0(:),H1(:)];
%     
%     temp=min(H,[],2);
%     
%     ResultMatrix=reshape(temp,256,256);

    %求出最大值所在的行 
    [MaxRow,RowIndex]=max(ResultMatrix);
    %求出最大值所在的列
    [MaxCol,ColIndex]=max(MaxRow);
    T=ColIndex;
    Th=RowIndex(T);

    segImg=(cX>Th);
