%-- 10/17/04  17:00 PM --%
%用K均值法对图像进行的无监督聚类
function [zc,retImg]=GetTemple(X,N)

%预定的模式数为N

%获取文件大小
[r,c]=size(X);
%计算总像素数
t=r*c;

%将图像数据矩阵转化为单列向量
x=double(X(:));

%以下几行代码随机产生N个坐标值
randPos=ones(N);
randPos(1)=round(rand*t);
nloop=2;
while nloop<=N
    randPos(nloop)=round(rand*t);
    if randPos(nloop-1)==randPos(nloop)
        continue;
    end;
    nloop=nloop+1;
end;    

%返回值:计算得到的聚类中心
zc=zeros(N,1);      
%初始化返回图像数据矩阵
retImg=zeros(r,c);

zp=zeros(N,1);      %每次迭代的初始聚类中心
%根据这几个坐标值,在原图中取出初始聚类的中心点值
for nloop=1:N
    zp(nloop)=x(randPos(nloop));
end;
delta=zeros(N,t);

%迭代次数
itNum=1;

while(itNum<t)    

    %计算每一样本距聚类中心的棋盘距离,
    for i=1:N;
        delta(i,:)=(abs(ones(t,1)*zp(i)-x))';
    end;
    
    % v将存储各样本距最近聚类中心的序号,
    %如:若v(3)=2表示第三个样本距第二个聚类中心最近
    [ans,v]=min(delta);
    
    %重新计算聚类中心
    i=1;
    for i=1:N;
        y=x(v==i);
        if(isempty(y))
            zc(i)=zp(i);
        else
            zc(i)=mean(y);
        end;
    end;

    %判断是否收敛
    if sum(sum(abs(zc-zp)))<0.001
        break;
    end;
    %暂存新的聚类中心,为下次判是否收敛时用
    zp=zc;
    
    %迭代次数增一
    itNum=itNum+1;
end;

%生成经模式分类后的分类图像
for i=1:N;
    retImg(v==i)=i;
end;
