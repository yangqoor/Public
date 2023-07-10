clear all
Wst=2*pi*1500;
Wp=2*pi*3000;
Ws=2*pi*15000;

% %��һ�� ���Ӧ������Ƶ��
Ts=2*pi/Ws;
wp=Wp*Ts;
wst=Wst*Ts;

%�ڶ��������������ͨ�˲��������ֽ�ֹƵ��wc
wc=(wp+wst)/2;

%���������������˥����ȷ�������������ݹ��ɴ��Ŀ��dw����N
det=50;%����ѡ������hamming
dw=wp-wst;
N=ceil(6.6*pi/dw);

% N=N+1;%��Ҫ�����˲������͵���N����ż

tao=(N-1)/2;

%���Ĳ���д�������˲����ĳ弤��Ӧhd��д��������wn�����ô�������ȡFIR�˲�����h
hd=zeros(1,N);
for n=0:N-1;
    if n~=tao
        hd(n+1)=1/(pi*(n-tao))*(sin((n-tao)*pi)-sin((n-tao)*wc));
    else
        hd(n+1)=1-wc/pi;
    end
end
wn=0.54-0.46*cos(2*pi*(0:(N-1))./(N-1));%������wn
 h=hd.*wn;
% h=fir1(N-1,wc/pi,'high',hamming(N));
figure
freqz(h,1);%����������ʾ�����׺���λ��
figure
[hx,w]=freqz(h,1);
plot(w/2/pi/Ts,abs(hx));%ֱ��������ʾ������


