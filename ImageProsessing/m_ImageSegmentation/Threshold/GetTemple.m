%-- 10/17/04  17:00 PM --%
%��K��ֵ����ͼ����е��޼ල����
function [zc,retImg]=GetTemple(X,N)

%Ԥ����ģʽ��ΪN

%��ȡ�ļ���С
[r,c]=size(X);
%������������
t=r*c;

%��ͼ�����ݾ���ת��Ϊ��������
x=double(X(:));

%���¼��д����������N������ֵ
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

%����ֵ:����õ��ľ�������
zc=zeros(N,1);      
%��ʼ������ͼ�����ݾ���
retImg=zeros(r,c);

zp=zeros(N,1);      %ÿ�ε����ĳ�ʼ��������
%�����⼸������ֵ,��ԭͼ��ȡ����ʼ��������ĵ�ֵ
for nloop=1:N
    zp(nloop)=x(randPos(nloop));
end;
delta=zeros(N,t);

%��������
itNum=1;

while(itNum<t)    

    %����ÿһ������������ĵ����̾���,
    for i=1:N;
        delta(i,:)=(abs(ones(t,1)*zp(i)-x))';
    end;
    
    % v���洢������������������ĵ����,
    %��:��v(3)=2��ʾ������������ڶ��������������
    [ans,v]=min(delta);
    
    %���¼����������
    i=1;
    for i=1:N;
        y=x(v==i);
        if(isempty(y))
            zc(i)=zp(i);
        else
            zc(i)=mean(y);
        end;
    end;

    %�ж��Ƿ�����
    if sum(sum(abs(zc-zp)))<0.001
        break;
    end;
    %�ݴ��µľ�������,Ϊ�´����Ƿ�����ʱ��
    zp=zc;
    
    %����������һ
    itNum=itNum+1;
end;

%���ɾ�ģʽ�����ķ���ͼ��
for i=1:N;
    retImg(v==i)=i;
end;
