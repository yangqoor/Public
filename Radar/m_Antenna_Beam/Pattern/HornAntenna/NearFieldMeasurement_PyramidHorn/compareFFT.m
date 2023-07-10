clc
clear all
W=100;       %����Ƶ��
dx=1/(2*W);  %���岽��
N=2048;      %�������
n=0:N-1;

%%%%%%%%%%%%%%%%%%%%%%%%% ���ۼ���ֵ  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

w = 0:.0001:W;
FP=2./(1+(2*pi*w).^2);


%% %%%%%%%%%%%%%%%%%%%%%    ֱ�����      %%%%%%%%%%%%%%%%%%%%%%%%%
tic   %ϵͳ��ʱ
for n1=0:N-1
    FS1=0;
    for k=0:N-1;
    FS2=dx.*exp(-abs((k-N/2).*dx)).*exp(1i*2*pi*k*n1/N);
    FS1=FS2+FS1;
    end
    FS(1,n1+1)=(-1).^n1.*FS1;
end
FS=abs(FS);
toc


%% %%%%%%%%%%%%%%%%%%%%%    FFT�㷨      %%%%%%%%%%%%%%%%%%%%%%%%%
k=0:N-1;
w1=n./(N*dx);  %�����Ժ��Ƶ��
Fk=dx.*exp(-abs((k-N/2).*dx));
tic
FF=fft(Fk,N);
FF=abs(FF);
toc

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
title('ֱ����ͼ����������۽��','FontName','��������',...
      'FontWeight','Bold','FontSize',16)
hold on
grid on;
plot(w,FP,'--r','LineWidth',1.5);
stem(w1,FS);

legend('���۷����','ֱ����ͽ��')
axis([0 2 0 2]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
title('FFT�����������۽��','FontName','��������',...
      'FontWeight','Bold','FontSize',16)
hold on;
grid on;

plot(w,FP,'--r','LineWidth',1.5);
stem(w1,FF);

legend('���۽��','FFT������')
axis([0 2 0 2]) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(3)
title('���ַ����Ƚ�','FontName','��������',...
      'FontWeight','Bold','FontSize',16)
hold on
grid on;

plot(w,FP,'--r','LineWidth',1.5);
stem(w1,FS);
plot(w1,FF,'*k');

legend('���۽��','ֱ����ͽ��','FFT������')
axis([0 2 0 2]);
