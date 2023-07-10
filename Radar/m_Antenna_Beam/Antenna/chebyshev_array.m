%�����б�ѩ�����ʽ������Ԫ��Ϊ���������з���ͼ
clear,clf;
blog=-20; %Ԥ�������ƽdb
b=10^(-blog/20);
N=17;%��Ԫ��
M=N-1;%����ʽ�Ľ���
x0=cosh(acosh(b)/M);
l=linspace(M/2,1,M/2);%����ʽ���ĸ�����һ��
x=cos((2*l-1)*pi/2/M);%����ʽ�����,������
u1=2*acos(x/x0);
u0=[-u1 u1];
w=exp(i*u0);
I=poly(w);
%����ͼ
theta0=pi/2;%����ȼ�ࡢ�Ǿ��ȵ������ȷֲ������Բ���������λ�����еķ���ͼ
theta=0:pi/1000:pi;
K=length(theta);
lemda=1;
d=lemda/2;
k=2*pi/(lemda);
u=k*d*(cos(theta)-cos(theta0));
S=I(M/2+1)*ones(1,K);%equally spaced, ununiform amplitude, linear stepped phase
for n=1:M/2
    S=S+2*I(M/2+1-n)*cos(n*u);
end
Slog=20*log10(abs(S)/max(S));
figure(1);
plot(theta*180/pi,Slog);
grid on;
%%%%%%%%%%%%%%%%%%%%
%ȷ�����еĿ������
% c=3e8;%����
% B=20e9:-1e9:1e9;%8e9:1e8:10e9 %�����ڶ��Ƶ��
% fh=B(12);%floor(length(B)/2));
% lemdah=c/fh;
% d0=lemdah/2*(1:M/2);
% theta0=pi/2;
% res=501;
% theta=linspace(0,pi,res);
% mrsl=zeros(1,length(B));
% mlbw=zeros(1,length(B));    
% 
% u=cos(theta')-cos(theta0);
% for m=1:length(B)
%     S=I(M/2+1)*zeros(length(u),1);
%     f=B(m);
%     lemda=c/f;
%     k=2*pi/lemda;
%     for n=1:M/2
%         S=S+2*I(M/2+1-n)*cos(k*d0(n)*u);
%     end
%     S=abs(S);
%     S=20*log10(S/max(S));
%     for p=1:(res-1)/2
%         if S(p)>S(p+1),brk=p;end
%     end
%     BS=S(1:brk);
%     mrsl(m)=max(BS);
%     mlbw(m)=2*(theta0-theta(brk));
% end
% figure(1);
% plot(B/1e9,mrsl,'k');
% hold on;
% plot(B/1e9,mrsl,'ko');
% grid on;
% hold off;
% figure(2);
% plot(B/1e9,mlbw*180/pi,'k');
% hold on;
% plot(B/1e9,mlbw*180/pi,'ko');
% grid on;
% hold off;