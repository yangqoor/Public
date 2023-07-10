% %��������ɢ����Ҷ�仯
% clear;
% V=63;
% K=32;
% L=16;
% D=[0 5 6 10 12 15 16 17 18 20 24 25 26 29 32 34 35 37 38 39 41 42 45 46 48 50 52 53 54 55 56 57];
% % %��D��ȷ��һ���ɡ�1���͡�0����ɵ���������
% % A=zeros(1,V);
% % for m=1:K
% %     A(D(m)+1)=1;
% % end
% % %������A��FFT
% % AF1=fft(A,V);%63��fft
% % AF2=fft(A,V*10);%630��fft
% % AF1=abs(AF1);
% % AF2=abs(AF2);
% % AF1=fftshift(AF1);
% % AF2=fftshift(AF2);
% % 
% % figure(1);
% % plot(AF1,'k');
% % hold on;
% % plot(AF1,'k.');
% % grid on;
% % figure(2);
% % plot(AF2,'k');
% % grid on;
% % 
%��D��ȷ��һ���ɡ�1���͡�0����ɵĶ�ά����
% M=7,N=9;
% As=zeros(M,N);
% for m=1:K
%     As(mod(D(m),M)+1,mod(D(m),N)+1)=1;
% end
% %������As��FFT
% AF3=fft2(As);
% AF3=abs(AF3);
% AF3=fftshift(AF3);
% AF4=fft2(As,10*M,10*N);
% AF4=abs(AF4);
% AF4=fftshift(AF4);
% [X,Y]=meshgrid(1:N,1:M);
% figure(3);
% plot3(X,Y,AF3,'ko','markersize',6);
% hold on;
% plot3(X,Y,AF3,'k--','linewidth',2);
% grid on;
% figure(4);
% surf(AF4);
% grid on;
%--------------------------------------------------------------------------
% %��������ɢ����Ҷ�仯
clear;
V=15;
K=8;
L=4;
D=[3,4,5,6,8,10,11,14];
%��D��ȷ��һ���ɡ�1���͡�0����ɵ���������
A=zeros(1,V);
for m=1:K
    A(D(m)+1)=1;
end
%������A��FFT
AF1=fft(A,V);%V��fft
AF2=fft(A,V*10);%V*10��fft
AF1=abs(AF1);
AF2=abs(AF2);
AF1=fftshift(AF1);
AF2=fftshift(AF2);

figure(1);
plot(1:V,AF1,'ko','LineWidth',3);
hold on;
plot(1:V,AF1,'k:');
grid on;
plot(1:V,2*ones(1,V),'k--','LineWidth',2);
hold off;
axis([1,15,1,9]);
set(gca,'Xtick',[1,6,10,15],'Ytick',[1,2,4,6,8,9]);
xlabel('\fontsize{16}\bfԪ�����');
ylabel('\fontsize{16}\bfA_{15}��15��FFTʾ��ͼ');
figure(2);
hold on;
plot(1:V*10,AF2,'k','LineWidth',2);
grid on;
plot(1:V*10,2*ones(1,V*10),'k--','LineWidth',2);
hold off;
axis([1,150,1,8]);
set(gca,'Xtick',[1,30,60,90,120,150],'Ytick',[1,2,3,6,7,8]);
xlabel('\fontsize{16}\bfԪ�����');
ylabel('\fontsize{16}\bfA_{15}��150��FFTʾ��ͼ');