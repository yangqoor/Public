%ϸ��FFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear 
clc
close all hidden
format long
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fni=input('ϸ��FFT����--���������ļ�����','s');
fid=fopen(fni,'r');
sf=fscanf(fid,'%f',1);    %����Ƶ��
fi=fscanf(fid,'%f',1);    %��Сϸ����ֹƵ��
np=fscanf(fid,'%d',1);    %�Ŵ���
nfft=fscanf(fid,'%d',1);  %FFT����
fno=fscanf(fid,'%s',1);   %���������ļ���
x=fscanf(fid,'%f',[1,inf]);%���ж���ԭʼ�ź�����
status=fclose(fid);
%�����������ݳ���
nt=length(x);
%���ϸ����ֹƵ��
fa=fi+0.5*sf/np;
%ȡ����nt����nt��ӽ���2�������η�ΪFFT����
nf=2^nextpow2(nt);
%ȷ��ϸ����������ݳ���
na=round(0.5*nf/np+1);
%Ƶ��
%����һ����1����������
n=0:nt-1;
%������λ��ת���ӽ���Ƶ��
b=n*pi*(fi+fa)/sf;
%���Ե�λ��ת���Խ���Ƶ��
y=x.*exp(-i*b);
%Ƶ�ƺ�ĵ�ͨ�˲�(Ƶ���˲�)
%FFT�任
b=fft(y,nf);
%��Ƶ�ʴ�Ͱ�ڵ�Ԫ�ظ�ֵ
a(1:na)=b(1:na);
%��Ƶ�ʴ�ͨ�ڵ�Ԫ�ظ�ֵ
a(nf-na+1:nf)=b(nf-na+1:nf);
%FFT�任
b=ifft(a,nf);
%�ز���
c=b(1:np:nt);
%����ϸ��FFT�任
a=fft(c,nfft)*1/nfft;
%�任�����������
y2=zeros(1,nfft/2);
%���и�Ƶ�ʶε�����
y2(1:nfft/4)=a(nfft-nfft/4+1:nfft);
%������Ƶ�ʶε�����
y2(nfft/4+1:nfft/2)=a(1:nfft/4);
n=0:(nfft/2-1);
%����ϸ��FFTƵ������
f2=fi+n*2*(fa-fi)/nfft;
%������������FFT�����仯�Ƚ�
%FFT�任
y1=fft(x,nfft)*2/nfft;
f1=n*sf/nfft;
%������ϸ��FFTƵ��������ͬ��Ƶ�ʷ�Χ
ni=round(fi*nfft/sf+1);
na=round(fa*nfft/sf+1);
%��������ʱ������ͼ��
subplot(2,1,1);
t=0:1/sf:(nt-1)/sf;
nn=1:3000;
plot(t(nn),x(nn));
xlabel('ʱ�䣨s��');
ylabel('��ֵ');
grid on
%����ͬ��Ƶ�ʷ�Χ�»��Ʒ�Ƶ����ͼ
subplot(212);
nn=ni:na;
plot(f1(nn),abs(y1(nn)),':',f2,abs(y2));
xlabel('Ƶ��(Hz)');
ylabel('��ֵ');
legend('��ͨ','ϸ��');
grid on
%���ļ����ϸ���������
fid=fopen(fno,'w');
for k=1:nfft/2
    %ÿ�����3��ʵ�����ݣ�fΪƵ�ʣ�y2��ʵ���鲿
    fprintf(fid,'%f %f %f\n',f2(k),real(y2(k)),imag(y2(k)));
end
status=fclose(fid);

