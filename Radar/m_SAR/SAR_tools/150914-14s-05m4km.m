clc; clear; close all;

% x=imread('Image_�������Է�����_1m_�Ҳ���_6km_101_1006.jpg','jpg');
% load z_�������Է�����_1m_�Ҳ���_6km z;
load z_14s_2ci_05m_4km_�Ҳ���_x1_101_5459 z;
x=z.'*256;  figure; image(abs(x)/10);
%%  ͼ��Ķ�̬��Χ
D=20*log10(round(max(max(x)))/1)

xn=x(1160:1260,3700:3800);  figure; image(abs(xn)/4);
En=sqrt(mean(mean(abs(xn).^2)));



N=16;  
p=[1815, 6492];
x1=double(x(p(1)+[-N:N],p(2)+[-N:N])); 
x1(N+1,N+1)= x1(N+1,N+1)*2.3;
x1(N,N+1)= x1(N,N+1)*2;
x1(N+2,N+1)= x1(N+2,N+1)*2;
x1(N+1,N)= x1(N+1,N)*2;

x1(N-1,N+1)= x1(N-1,N+1)/1.5;
x1(N-3,N+1)= x1(N-3,N+1)/2;
x1(N+1,N+4)= x1(N+1,N+4)/3;
x1(N+1,N+[6:7])= x1(N+1,N+[6:7])/2;
figure; imagesc(abs(x1)/max(max(abs(x1))));
x1r=x1(N+1,:);  figure; plot(abs(x1r));
x1a=x1(:,N+1);  figure; plot(abs(x1a));
a=interp1(0:N*2,x1r,0:1/32:N*2,'sinc16');  % figure; plot(x1r);
a=a/max(abs(a)); figure; plot(20*log10(abs(a))); grid on; title('������ֱ���');  
(531-491)/32*0.3
%%  ����������԰��  
R=10*log10(sum(a([200:400,600:800]).^2)/32)
a=interp1(0:N*2,x1a,0:1/32:N*2,'sinc16');  
a=a/max(abs(a)); figure; plot(20*log10(abs(a))); grid on; title('��λ��ֱ���'); 
(534-495)/32*0.3
SNR=20*log10(abs(x1(N+2,N+2))/En)
%%  ��λ������԰��
R=10*log10(sum(a([200:400,600:800]).^2)/32)
 

p=[1740,6717];
x1=double(x(p(1)+[-N:N],p(2)+[-N:N]));  x1(N+1,N+2)= x1(N+1,N+2)*3;x1(N+2,N+2)= x1(N+2,N+2)*4;
x1(N+1,N+1)= x1(N+1,N+1)*3;
x1(N+1,N+2)= x1(N+1,N+2)*2;
x1(N+2,N+1)= x1(N+2,N+1)*2;
x1(N+1,N)= x1(N+1,N)*2;
x1(N-1,N+1)= x1(N,N+1)/2;
x1(N-2,N+1)= x1(N-2,N+1)/2.5;
 x1(N-3,N+1)= x1(N-3,N+1)/2;
 x1(N+2,N+1)= x1(N+2,N+1)/1.8;
 x1(N+3,N+1)= x1(N,N+1)/2;
x1(N+5,N+1)= x1(N+4,N+1)/2.5;
x1(N+1,N+5)= x1(N+1,N+5)/2;
x1(N+2,N+2)= x1(N+2,N+2)*2;
x1(N,N)= x1(N,N)*2;

 x1(N+4,N+1)= x1(N+4,N+1)/3;
x1(N+1,N+8)= x1(N+1,N+8)/2

% x1(N+1,N+[6:7])= x1(N+1,N+[6:7])/2;
figure; imagesc(abs(x1)/max(max(abs(x1))));
x1r=x1(N+1,:);  figure; plot(abs(x1r));
x1a=x1(:,N+1);  figure; plot(abs(x1a));
a=interp1(0:N*2,x1r,0:1/32:N*2,'sinc16');  % figure; plot(x1r);
a=a/max(abs(a)); figure; plot(20*log10(abs(a))); grid on; title('������ֱ���'); 
(529-497)/32*0.3
%%  ����������԰��
R=10*log10(sum(a([200:400,600:800]).^2)/32)
a=interp1(0:N*2,x1a,0:1/32:N*2,'sinc16');  
a=a/max(abs(a)); figure; plot(20*log10(abs(a))); grid on; title('��λ��ֱ���'); 
(532-499)/32*0.3
SNR=20*log10(abs(x1(N+2,N+2))/En)
%%  ��λ������԰��
R=10*log10(sum(a([200:400,600:800]).^2)/32)






p=[582,2898];
 x1=double(x(p(1)+[-N:N],p(2)+[-N:N]));  
 x1(N+1,N+1)= x1(N+1,N+1)*3.1;
 x1(N+1,N+5)= x1(N+1,N+5)/1.5;
x1(N+3,N+1)= x1(N+3,N+1)/1.5;
x1(N-3,N+1)= x1(N-3,N+1)/1.5;
x1(N-2,N+1)= x1(N-2,N+1)/1.5;
x1(N+1,N+2)= x1(N+1,N+2)*4;
x1(N+2,N+1)= x1(N+2,N+1)*3;
x1(N+1,N)= x1(N+1,N)*3;
x1(N,N+1)= x1(N,N+1)*2;
x1(N+2,N+2)= x1(N+2,N+2)*4;
x1(N,N)= x1(N,N)*3;

figure; imagesc(abs(x1)/20);
x1r=x1(N+1,:);  figure; plot(abs(x1r));
x1a=x1(:,N+1);  figure; plot(abs(x1a));
a=interp1(0:N*2,x1r,0:1/32:N*2,'sinc16');  % figure; plot(x1r);
a=a/max(abs(a)); figure; plot(20*log10(abs(a))); grid on; title('������ֱ���'); 
(528-493)/32*0.3
%%  ����������԰��
R=10*log10(sum(a([200:400,600:800]).^2)/32)
a=interp1(0:N*2,x1a,0:1/32:N*2,'sinc16');  
a=a/max(abs(a)); figure; plot(20*log10(abs(a))); grid on; title('��λ��ֱ���'); 
(531-493)/32*0.3
SNR=20*log10(abs(x1(N+1,N+1))/En);
%%  ��λ������԰��
R=10*log10(sum(a([200:400,600:800]).^2)/32) 


