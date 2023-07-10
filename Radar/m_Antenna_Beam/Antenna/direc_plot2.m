%����ȼ�ࡢ�Ǿ��ȵ������ȷֲ������Բ���������λ�����еĹ��ʷ���ͼ
clear;
theta0=pi/2;
N=5;%��Ԫ��
theta=0:pi/100:pi/2-pi/100;
K=length(theta);
lemda=1;
d=lemda/2;
k=2*pi/lemda;
u=k*d*(sin(theta)-sin(theta0));
%equally spaced, ununiform amplitude, linear stepped phase
I=[1 1.6 1.95 1.6 1];%[linspace(0.1,1,N/2),linspace(1,0.1,N/2)]; %equally spaced, ununiform amplitude, linear stepped phase
S=sum(I.^2)*zeros(1,K);
for i=1:N-1
    for j=0:N-1-i
        S=S+2*I(j+1)*I(i+j+1)*cos(i*u);
    end
end
Slog=20*log10(abs(S)/max(S));
figure(2);
plot(u,Slog);