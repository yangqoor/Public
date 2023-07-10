function S=WidebandArray(N,num,fh,u,v)
%����Ϊ����
Nf=num;
c=3e8;%����
lemdah=c/fh;%��߹���Ƶ���µĲ���
lemda=[lemdah,(N/(N-2)).^(1:Nf-1)*lemdah];%������Ƶ���µĲ���
%ȷ������Ԫλ������
dx=zeros(1,N*N/4+(Nf-1)*(N-1));
dy=zeros(1,N*N/4+(Nf-1)*(N-1));
for n=1:N/2  %���������Ƶ�ʵ���Ԫ��λ��
    dx(1+(n-1)*N/2:N/2+(n-1)*N/2)=lemdah/4*(1:2:N-1);
    dy(1+(n-1)*N/2:N/2+(n-1)*N/2)=lemdah/4*(2*n-1)*ones(1,N/2);
end
for m=N/2+1:N/2+Nf-1
    dx(N*N/4+1+(m-N/2-1)*(N-1):N*N/4+N/2-1+(m-N/2-1)*(N-1))=(lemdah/2*N/2+sum(lemda(2:m-N/2)/2)+lemda(m-N/2+1)/4)*ones(1,N/2-1);
    dy(N*N/4+1+(m-N/2-1)*(N-1):N*N/4+N/2-1+(m-N/2-1)*(N-1))=lemda(m-N/2+1)/4*(1:2:N-3);
    dx(N*N/4+1+(m-N/2-1)*(N-1)+N/2-1:N*N/4+N/2-1+(m-N/2-1)*(N-1)+N/2)=lemda(m-N/2+1)/4*(1:2:N-1);
    dy(N*N/4+1+(m-N/2-1)*(N-1)+N/2-1:N*N/4+N/2-1+(m-N/2-1)*(N-1)+N/2)=(lemdah/2*N/2+sum(lemda(2:m-N/2)/2)+lemda(m-N/2+1)/4)*ones(1,N/2);
end

%����ͼ�ļ���
I=ones(1,N*N/4+(Nf-1)*(N-1));
k=2*pi./lemda;
% theta0=pi/4;
% fai0=pi/2;
% % fai=linspace(0,2*pi,500);
% u=sin(meshgrid(theta)).*cos((meshgrid(fai))')-sin(theta0)*cos(fai0);
% v=sin(meshgrid(theta)).*sin((meshgrid(fai))')-sin(theta0)*sin(fai0);
[r,l]=size(u);
S=zeros(r,l);
for n=1:N*N/4+(Nf-1)*(N-1)
    S=S+4*I(n)*cos(k(num)*dx(n)*u).*cos(k(num)*dy(n)*v);
end
S=abs(S);
%Slog=20*log10(abs(S)/max(max(abs(S))));
