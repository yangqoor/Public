function qiyi(n)
L=1;
T=1;
h=1/n;%�ռ䲽��
dt=T/n;%ʱ�䲽��
for j=1:n+1
   v(j)=(j*pi)^(-2);%����ֵ
end
for j=1:n+1
    t(j)=j*dt;%��ʱ����ɢ
end
b=(t-(t).^3)/6;%�Ҷ������
delta=0;%�Ŷ�ˮƽ
q=length(b);
for i=1:q
   y(i)=b(i)*(1+(2*rand-1)*delta);
    %V(i)=V(i)+(2*rand-1)*delta;%����������Ŷ�
end
y;
W=zeros(n+1,1);
for j=1:n+1;
    V=((1/v(j))*(y*((2^(1/2))*sin(j*pi*t))')*(2^(1/2))*sin(j*pi*t))';
    W=W+V;
end
W%�����򻯽�
zhenjie=-t;%���
alpha=1e+7;%���򻯲���
A=zeros(n+1,1);
for j=1:n+1;
    Z=((v(j)/((v(j))^2+alpha))*(y*((2^(1/2))*sin(j*pi*t))')*(2^(1/2))*sin(j*pi*t))';
    A=A+Z;
end
A%���򻯽�
err1=norm(W-zhenjie')/norm(zhenjie')%�����򻯽�������������
err2=norm(A-zhenjie')/norm(zhenjie')%���򻯽�������������
plot(t,zhenjie,'+r')%����ͼ��
hold on
plot(t,W)%�����򻯽��ͼ�� 
hold on
plot(t,A,'og')%���򻯽��ͼ��
legend('���','��ֵ��','���򻯽�',1)
xlabel('t')
ylabel('x')
