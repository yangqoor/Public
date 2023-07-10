function image=myFSA(echo,Rs,fc,gama,delta_x,fs)
c=3e8;
j=sqrt(-1);
[Na,Nr]=size(echo);
kc=4*pi*fc/c;%�������Ĳ���
b=8*pi*gama/c^2;
DeltaX=delta_x;%��λ����
kx=2*pi*[-Na/2:Na/2-1]/DeltaX/Na;%��λ����
Ax=sqrt(1-kx.^2/kc^2);

Ys=[-Nr/2:Nr/2-1]/Nr*fs*(-c/2/gama);

Rb=Ys+Rs;
t_r=[-Nr/2/fs:1/fs:(Nr/2-1)/fs];%������ʱ��
krDelta=4*pi*gama*(t_r)/c;

echokxkr=zeros(Na,Nr);%��ά���������
echokxr=zeros(Na,Nr);%��λ���������
%% FS
echokxkr=fftshift(fft(fftshift(echo)));
HFS=exp(j*(1-Ax.')*(krDelta.^2)./2./b);
H=exp(-j*kc*Rs);
echokxkr=echokxkr.*HFS.*H;
figure;imagesc(abs(echokxkr));title('�����ɣ���ά������');

%% ������IFFT�������Բο�����2������ȥRVP����

echokxr=fftshift(ifft(fftshift(echokxkr.'))).';
 figure;imagesc(abs(echokxr));title('�����ɣ���λ������������');
HRVP=exp(-j*b/2*(1./Ax.')*(Ys.^2));
echokxr=echokxr.*HRVP;
figure;imagesc(abs(echokxr));title('RVPУ����ɣ���λ������������');

%% ������FFT�������Բο�����3������IFS,SRC,RMC�������
echokxkr=fftshift(fft(fftshift(echokxr.'))).';
figure;imagesc(abs(echokxkr));

HIFS=exp(j*((Ax.').^2-Ax.')*krDelta.^2/2/b);
echokxkr=echokxkr.*HIFS;
echokxr=fftshift(ifft(fftshift(echokxkr.'))).';
figure;imagesc(abs(echokxr));title('������ɣ���λ������������');

HRMC=exp(-j*(Ax.'.*Rs-Rs)*krDelta);
echokxkr=echokxkr.*HRMC;
echokxr=fftshift(ifft(fftshift(echokxkr.'))).';
figure;imagesc(abs(echokxr));title('RCMC��ɣ���λ������������');

HSRC=exp(-j/2/(kc^3).*(kx.^2./Ax).'*(Rs.*krDelta.^2)).* ...
    exp(j/2/(kc^4).*(kx.^2./Ax.^2).'*(Rs.*krDelta.^3));
echokxkr=echokxkr.*HSRC;
figure;imagesc(abs(echokxkr));title('���꣬RCM��SRC��ɣ���ά������');

%% ������IFFT,�õ�����ѹ���Ľ���������Բο�����4�����з�λƥ��
echokxr=fftshift(ifft(fftshift(echokxkr.'))).';
figure;imagesc(abs(echokxr));title('���꣬RCMC��SRC��ɣ���λ������������');

HAS=exp(j*kc.*Ax.'*Rb);
echokxr=echokxr.*HAS;
image=fftshift(ifft(fftshift(echokxr)));
figure,imagesc(abs(image));
title('��λѹ����ɣ�ʱ�������');


end