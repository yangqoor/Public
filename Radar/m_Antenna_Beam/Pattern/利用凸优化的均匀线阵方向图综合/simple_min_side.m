%���ġ�����͹�Ż�����������������԰귽��ͼ�ۺϡ�
%�ķ���,�԰��ֵ��С,û���������
clc;
clear all;
close all;
%================��������===============%
ima=sqrt(-1);
f=5.4e9;
lamda=3e8/f;
d=0.5*lamda;
C_num=10;  %%��Ԫ��
theta0=60; %%Ŀ��
beamwidth=40; %%�����
theta=[0:180];

side_l=theta0-beamwidth/2;
side_u=theta0+beamwidth/2;
ind=find(0<=theta&theta<=side_l | side_u<=theta&theta<=180);

A=exp(-ima*2*pi*d*cosd(theta')*[0:C_num-1]/lamda);
Am=A(find(theta==theta0),:);%�������ĵ���ʸ��
As=A(ind,:);         %�԰����ĵ���ʸ��


%===============�Ż���ʽ================%
cvx_begin 
   variable w(C_num) complex
   minimize(max(abs(As*w)))   
   subject to
     Am*w==1;
          
cvx_end


%================����ͼ�γ�===============%
% w1=w/max(abs(w));
for n=1:length(theta)
    a=exp(ima*2*pi*d*cos(theta(n)*pi/180)*[0:C_num-1]'/lamda);
    gain(n)=w'*a;
end
G=abs(gain)/max(abs(gain));
G=20*log10(G);
G=max(G,-40);

%  ��ͼ
figure(1);
plot(theta,G);
grid on,hold on


xlabel('��λ��/��');
ylabel('����/dB');
title('���������ۺϷ���ͼ')

   
   