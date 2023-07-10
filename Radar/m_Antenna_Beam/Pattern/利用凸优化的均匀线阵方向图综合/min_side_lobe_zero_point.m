%���ġ�����͹�Ż�����������������԰귽��ͼ�ۺϡ�
%�ķ���,�����
clc;
clear all;
close all;

ima=sqrt(-1);
f=5e9;
lamda=3e8/f;
d=0.5*lamda;
C_num=10;%��Ԫ��
theta0=60;%Ŀ��
null_point=[95 110 120 140 170];%���
beamwidth=40;
theta=[1:180];

side_l=theta0-beamwidth/2;
side_u=theta0+beamwidth/2;
ind=find(0<=theta&theta<=side_l | side_u<=theta&theta<=180);

A=exp(-ima*2*pi*d*cosd(theta')*[0:C_num-1]/lamda);%������ʽ
Am=A(find(theta==theta0),:);
As=A(ind,:);
A_null=A(null_point,:);
%===============�Ż���ʽ=================%
cvx_begin 
   variable w(C_num) complex
   minimize(max(abs(As*w)))
   subject to
     Am*w==1;%��1
     A_null*w==0;%����
cvx_end


%=========����ͼ�γ�=======%

for n=1:length(theta)
    a=exp(ima*2*pi*d*cos(theta(n)*pi/180)*[0:C_num-1]'/lamda);
    gain(n)=w'*a;
end
G=abs(gain);
G=20*log10(G);
G=max(G,-40);

%  ��ͼ
figure(1);
plot(theta,G);
grid on,hold on


xlabel('��λ��/��');
ylabel('����/dB');
title('���������ۺϷ���ͼ')

   
   