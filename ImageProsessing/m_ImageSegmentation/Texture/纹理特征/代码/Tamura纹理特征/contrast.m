%调用举例：  
%注意这个函数因为涉及到方差，要求输入类型为double，因此我这里在源代码上做了适当的修改  
%image=rgb2gray(imread('example.jpg'));  
%f=contrast(image)  
function Fcon=contrast(graypic) %graypic为待处理的灰度图片  
graypic=double(graypic);%这一句我自己做了修改，否则原博文中的代码不能直接运行  
x=graypic(:); %二维向量一维化  
M4=mean((x-mean(x)).^4); %四阶矩  
delta2=var(x,1); %方差  
alfa4=M4/(delta2^2); %峰度  
delta=std(x,1); %标准差  
Fcon=delta/(alfa4^(1/4)); %对比度  
end 
