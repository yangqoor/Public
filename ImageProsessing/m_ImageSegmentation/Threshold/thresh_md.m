%   最大类间差阈值法
%   算法参考文献:  孙兆林. MATLAB6.x图像处理. 清华大学出版社, 2002: 261-262.
function [th,segImg]=thresh_md(cX,map)
count=imhist(cX,map);
[m,n]=size(cX);
N=m*n-sum(sum(find(cX==0),1));
L=size(count);      %求图像灰度等级
count=count/N;      %求各个灰度出现的概率
%找出出现概率不为0的最小灰度
for i=2:L
  if count(i)~=0
    st=i-1;
    break;
  end
end
%找出出现概率不为0的最大灰度
for i=L:-1:1
  if count(i)~=0
    nd=i-1;
    break;
  end
end
f=count(st+1:nd+1);
p=st;q=nd-st;       %p,q分别为灰度起始和结束值
%计算灰度的平均值
u=0;
for i=1:q
  u=u+f(i)*(p+i-1);
  ua(i)=u;
end;
%计算图像的平均灰度
for i=1:q
  w(i)=sum(f(1:i));
end;
%计算出选择不同k值时,A区域的概率
d=(u*w-ua).^2./(w.*(1-w));
%求出最大方差对应的灰度级
[y,tp]=max(d);
%th即为最佳阈值
th=tp+p;

segImg=(cX>th);

