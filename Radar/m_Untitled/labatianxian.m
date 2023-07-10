% https://wenku.baidu.com/view/4d2084dcb9f3f90f76c61b2c.html

clc 
clear 
%a=input('�������׶����˿�ȣ�H�棩��λmm a=') 
a=23; 
a=a*10.^(-3); 
%b=input('�������׶����˿�ȣ�E�棩��λmm b=') 
b=10; 
b=b*10.^(-3); 
%D1=input('�������׶�ھ���ȣ�H�棩��λmm A=') 
D1=238; 
D1=D1*10.^(-3); 
%D2=input('�������׶�ھ���ȣ�E�棩��λmm B=') 
D2=176; 
D2=D2*10.^(-3); 
%h=input('���������ȿڳ��� ��λmm H=') 
h=465; 
h=h*10.^(-3); 
%f=input('�����빤��Ƶ�� ��λMHz f=') 
f=9375; 
f=f*10.^6; 
lamd=3*10.^8/f; 
R2=h/(1-b/D2); 
theta=-60:0.2:60; 
k=2*pi/lamd; 
theta1=theta.*pi/180; 
t1_1=sqrt(k/(pi*R2)).*(-(D2/2)-R2.*sin(theta1));
t2_1=sqrt(k/(pi*R2)).*((D2/2)-R2.*sin(theta1)); 
EE=exp(1j.*(k.*R2.*(sin(theta1))./2)).*F(t1_1,t2_1); 
FE=-1j.*(a*sqrt(pi*k*R2)/8).*(-(1+cos(theta1))*(2/pi)*(2/pi).*EE); 
FE1=abs(FE); 
FE1=FE1./max(FE1); 
FEdB=20*log10(FE1);
figure
plot(theta,FEdB);
grid on 
title('��׶����E�淽��ͼ') 
xlabel('Angle(\theta) \circ') 
ylabel('Gain(\theta)')  
% H�淽��ͼ�� 
R1=h/(1-a/D1); 
theta=-60:0.2:60; 
k=2*pi/lamd; 
theta1=theta.*pi/180; 
kx_1=k.*sin(theta1)+pi/D1; 
kx_11=k.*sin(theta1)-pi/D1;
f1=kx_1.*kx_1*R1/(2*k); 
f2=kx_11.*kx_11*R1/(2*k); 
t1_1=sqrt(1/(pi*k*R1)).*(-(k*D1/2)-kx_1*R1); 
t2_1=sqrt(1/(pi*k*R1)).*((k*D1/2)-kx_1*R1); 
t1_11=sqrt(1/(pi*k*R1)).*(-(k*D1/2)-kx_11*R1); 
t2_11=sqrt(1/(pi*k*R1)).*((k*D1/2)-kx_11*R1); 
FF=exp(j.*f1).*F(t1_1,t2_1)+exp(j.*f2).*F(t1_11,t2_11); 

FH=j.*(b/8).*sqrt((k*R1/pi)).*((1+cos(theta1)).*FF); 
FH1=abs(FH); 
FH1=FH1./max(FH1); 
FHdB=20*log10(FH1); 
figure
plot(theta,FHdB);
grid on 
title('��׶����H�淽��ͼ') 
xlabel('Angle(\theta) \circ') 
ylabel('Gain(\theta)')  



