clear all
Wp=2*pi*1500;
Wst=2*pi*3000;
Ws=2*pi*15000;

% %��һ�� ���Ӧ������Ƶ��
Ts=2*pi/Ws;
wp=Wp*Ts;
wst=Wst*Ts;

%�ڶ��������������ͨ�˲����Ľ�ֹƵ��Wc
wc=(wp+wst)/2;

%���������������˥����ȷ�������������ݹ��ɴ��Ŀ��dw����N
det=50;%����ѡ������hamming
dw=wst-wp;
N=ceil(6.6*pi/dw);

% N=N+1;%��Ҫ�����˲������͵���N����ż

%���Ĳ���д�������˲����ĳ弤��Ӧhd��д��������wn�����ô�������ȡFIR�˲�����h
n=0:N-1;
hd=wc/pi*sinc(wc/pi*(n-(N-1)/2));
wn=0.54-0.46*cos(2*pi*n/(N-1));
h=hd.*wn;
% h=fir1(N-1,wc/pi,hamming(N));
figure
freqz(h,1);%����������ʾ�����׺���λ��
figure
[hx,w]=freqz(h,1);
plot(w/2/pi/Ts,abs(hx));%ֱ��������ʾ������


