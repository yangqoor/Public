%���þ�����  
%ע�����������Ϊ�漰�����Ҫ����������Ϊdouble�������������Դ�����������ʵ����޸�  
%image=rgb2gray(imread('example.jpg'));  
%f=contrast(image)  
function Fcon=contrast(graypic) %graypicΪ������ĻҶ�ͼƬ  
graypic=double(graypic);%��һ�����Լ������޸ģ�����ԭ�����еĴ��벻��ֱ������  
x=graypic(:); %��ά����һά��  
M4=mean((x-mean(x)).^4); %�Ľ׾�  
delta2=var(x,1); %����  
alfa4=M4/(delta2^2); %���  
delta=std(x,1); %��׼��  
Fcon=delta/(alfa4^(1/4)); %�Աȶ�  
end 
