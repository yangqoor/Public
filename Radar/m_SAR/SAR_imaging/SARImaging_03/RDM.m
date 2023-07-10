%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name: RDM距离多普勒.m
% Author: Elias.J@CSDN
% CSDN: https://blog.csdn.net/qq_41248471
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initial operation
close all;
clc;
tarR = [15 25];    %target range
tarV = [-3 10];     %target velocity
c = 3*10^8;
f0 = 24.25*10^9;
T = 0.0002;   %chirp Sweep Time
B = 400*10^6;
L = 128;            %slow-time dimension,num of chirps
N = 128;           %fast-time dimension,num of samples
Npad = 1;          %padding in order to improve measure precision
Lpad = 1;         %padding in order to improve measure precision
%% generate receive signal
S1 = zeros(L,N);
for l = 1:L
    for n = 1:N
        S1(l,n) = 500*exp(1i*2*pi*((2*B*(tarR(1)+tarV(1)*T*l)/(c*T)+(2*f0*tarV(1))/c)*T/N*n+((2*f0)*(tarR(1)+tarV(1)*T*l))/c));
    end
end
S1 = awgn(S1,20);

S2 = zeros(L,N);
for l = 1:L
    for n = 1:N
        S2(l,n) = 500*exp(1i*2*pi*((2*B*(tarR(2)+tarV(2)*T*l)/(c*T)+(2*f0*tarV(2))/c)*T/N*n+((2*f0)*(tarR(2)+tarV(2)*T*l))/c));
    end
end
S2 = awgn(S2,20);
sigReceive = S1+S2;
%% range fft processing
hanning1 = hanning(N,'periodic');
% hanning1 = ones(N,1);
sigRWin = zeros(L,N);
for ii = 1:L
    sigRWin(ii,:) = hanning1'.*sigReceive(ii,:);
end
sigRfft = zeros(L,N*Npad);
for ii = 1:L
    sigRfft(ii,:) = fft(sigRWin(ii,:),N*Npad);
end
%% doppler fft processing
hanning2 = hanning(L,'periodic');
% hanning2 = ones(N,1);
sigDWin = zeros(L,N*Npad);
for ii = 1:N*Npad
    sigDWin(:,ii) = hanning2.*sigRfft(:,ii);
end
sigDfft = zeros(L*Lpad,N*Npad);
for ii = 1:N*Npad
    sigDfft(:,ii) = fftshift(fft(sigDWin(:,ii),L*Lpad));
end
%% Visualization
Rres = c/(2*B*Npad);
Vres = c/(2*24.25*10^9*T*L*Lpad);
figure,image(Rres*[1:N*Npad],[1:L],10*log10(abs(sigRfft))),title('Range - FFT')
xlabel('Range/m'),ylabel('Frame');
figure,mesh(abs(sigRfft)),title('Range-FFT');
figure,image(Rres*[1:N*Npad],Vres*([1:L*Lpad] - L*Lpad/2),10*log10(abs(sigDfft)));
xlabel('距离/m'),ylabel('速度/mps');
figure,mesh(Rres*[1:N*Npad],Vres*([1:L*Lpad] - L*Lpad/2),10*log10(abs(sigDfft)));
xlim([0 45]);
ylim([-18 18]);
xlabel('距离/m'),ylabel('速度/mps'),zlabel('幅值/dB');

%% Window Test

hanning1 = ones(N,1);
sigRWin = zeros(L,N);
for ii = 1:L
    sigRWin(ii,:) = hanning1'.*sigReceive(ii,:);
end
sigRfft = zeros(L,N*Npad);
for ii = 1:L
    sigRfft(ii,:) = fft(sigRWin(ii,:),N*Npad);
end

hanning2 = ones(N,1);
sigDWin = zeros(L,N*Npad);
for ii = 1:N*Npad
    sigDWin(:,ii) = hanning2.*sigRfft(:,ii);
end
sigDfft = zeros(L*Lpad,N*Npad);
for ii = 1:N*Npad
    sigDfft(:,ii) = fftshift(fft(sigDWin(:,ii),L*Lpad));
end

figure(1),
subplot(221),image(Rres*[1:N*Npad],Vres*([1:L*Lpad] - L*Lpad/2),10*log10(abs(sigDfft)));
xlabel('距离/m'),ylabel('速度/mps');
title('加矩形窗');
figure(2),
subplot(221),mesh(Rres*[1:N*Npad],Vres*([1:L*Lpad] - L*Lpad/2),10*log10(abs(sigDfft)));
xlim([0 45]);
ylim([-18 18]);
xlabel('距离/m'),ylabel('速度/mps'),zlabel('幅值/dB');
title('加矩形窗');


hanning1 = hanning(N,'periodic');
sigRWin = zeros(L,N);
for ii = 1:L
    sigRWin(ii,:) = hanning1'.*sigReceive(ii,:);
end
sigRfft = zeros(L,N*Npad);
for ii = 1:L
    sigRfft(ii,:) = fft(sigRWin(ii,:),N*Npad);
end

hanning2 = hanning(L,'periodic');
sigDWin = zeros(L,N*Npad);
for ii = 1:N*Npad
    sigDWin(:,ii) = hanning2.*sigRfft(:,ii);
end
sigDfft = zeros(L*Lpad,N*Npad);
for ii = 1:N*Npad
    sigDfft(:,ii) = fftshift(fft(sigDWin(:,ii),L*Lpad));
end

figure(1),
subplot(222),image(Rres*[1:N*Npad],Vres*([1:L*Lpad] - L*Lpad/2),10*log10(abs(sigDfft)));
xlabel('距离/m'),ylabel('速度/mps');
title('加汉宁窗');
figure(2),
subplot(222),mesh(Rres*[1:N*Npad],Vres*([1:L*Lpad] - L*Lpad/2),10*log10(abs(sigDfft)));
xlim([0 45]);
ylim([-18 18]);
xlabel('距离/m'),ylabel('速度/mps'),zlabel('幅值/dB');
title('加汉宁窗');

hanning1 = hamming(N,'periodic');
sigRWin = zeros(L,N);
for ii = 1:L
    sigRWin(ii,:) = hanning1'.*sigReceive(ii,:);
end
sigRfft = zeros(L,N*Npad);
for ii = 1:L
    sigRfft(ii,:) = fft(sigRWin(ii,:),N*Npad);
end

hanning2 = hamming(L,'periodic');
sigDWin = zeros(L,N*Npad);
for ii = 1:N*Npad
    sigDWin(:,ii) = hanning2.*sigRfft(:,ii);
end
sigDfft = zeros(L*Lpad,N*Npad);
for ii = 1:N*Npad
    sigDfft(:,ii) = fftshift(fft(sigDWin(:,ii),L*Lpad));
end

figure(1),
subplot(223),image(Rres*[1:N*Npad],Vres*([1:L*Lpad] - L*Lpad/2),10*log10(abs(sigDfft)));
xlabel('距离/m'),ylabel('速度/mps');
title('加汉明窗');
figure(2),
subplot(223),mesh(Rres*[1:N*Npad],Vres*([1:L*Lpad] - L*Lpad/2),10*log10(abs(sigDfft)));
xlim([0 45]);
ylim([-18 18]);
xlabel('距离/m'),ylabel('速度/mps'),zlabel('幅值/dB');
title('加汉明窗');

hanning1 = blackman(N,'periodic');
sigRWin = zeros(L,N);
for ii = 1:L
    sigRWin(ii,:) = hanning1'.*sigReceive(ii,:);
end
sigRfft = zeros(L,N*Npad);
for ii = 1:L
    sigRfft(ii,:) = fft(sigRWin(ii,:),N*Npad);
end

hanning2 = blackman(L,'periodic');
sigDWin = zeros(L,N*Npad);
for ii = 1:N*Npad
    sigDWin(:,ii) = hanning2.*sigRfft(:,ii);
end
sigDfft = zeros(L*Lpad,N*Npad);
for ii = 1:N*Npad
    sigDfft(:,ii) = fftshift(fft(sigDWin(:,ii),L*Lpad));
end

figure(1),
subplot(224),image(Rres*[1:N*Npad],Vres*([1:L*Lpad] - L*Lpad/2),10*log10(abs(sigDfft)));
xlabel('距离/m'),ylabel('速度/mps');
title('加布莱克曼窗');
figure(2),
subplot(224),mesh(Rres*[1:N*Npad],Vres*([1:L*Lpad] - L*Lpad/2),10*log10(abs(sigDfft)));
xlim([0 45]);
ylim([-18 18]);
xlabel('距离/m'),ylabel('速度/mps'),zlabel('幅值/dB');
title('加布莱克曼窗');
%% 2D CA-CFAR
Pfa = 10^(-6);
Rres_rdm = c/(2*B);
Vres_rdm = c/(2*24.25*10^9*T*L);
Range_Dim = Rres_rdm*[1:N];
Velocity_Dim = Vres_rdm*([1:L] - L/2);
Range_Dopple_Map = abs(sigDfft);

handleWindow_r = 9;
handleWindow_c = 9;
handleWindow = zeros(handleWindow_r,handleWindow_c);
proCell_r = 5;
proCell_c = 5;
proCell = zeros(proCell_r,proCell_c);
[r c] = size(Range_Dopple_Map);
CFAR_Map_r = r - (handleWindow_r-1);
CFAR_Map_c = c - (handleWindow_c-1);
CFAR_Map = zeros(CFAR_Map_r,CFAR_Map_c);
referCellNum = handleWindow_r*handleWindow_c - proCell_r*proCell_c;
alpha = referCellNum*(Pfa^(-1/referCellNum) - 1);
for i = 1:CFAR_Map_r
    for j = 1:CFAR_Map_c
        handleWindow = Range_Dopple_Map(i:i+handleWindow_r-1,j:j+handleWindow_c-1);
        proCell = handleWindow(1+(handleWindow_r - proCell_r)/2:handleWindow_r - (handleWindow_r - proCell_r)/2,1+(handleWindow_c - proCell_c)/2:handleWindow_c - (handleWindow_c - proCell_c)/2);
        Beta = (sum(sum(handleWindow)) - sum(sum(proCell)))/(referCellNum);
        CFAR_Map(i,j) = alpha*Beta;
    end
end

CFAR_MapRange_Dim = Range_Dim(1 + handleWindow_r - proCell_r:N - (handleWindow_r - proCell_r));
CFAR_MapVelocity_Dim = Velocity_Dim(1 + handleWindow_c - proCell_c:N - (handleWindow_c - proCell_c));
figure,subplot(121);
mesh(Range_Dim,Velocity_Dim,10*log10(Range_Dopple_Map));
xlabel('距离/m'),ylabel('速度/mps'),zlabel('幅值/dB');
title('2D-FFT')
subplot(122);
mesh(CFAR_MapRange_Dim,CFAR_MapVelocity_Dim,10*log10(CFAR_Map));
xlabel('距离/m'),ylabel('速度/mps'),zlabel('幅值/dB');
title('2D-CFAR检测判决门限')

figure,subplot(121);
image(Range_Dim,Velocity_Dim,10*log10(Range_Dopple_Map));
xlabel('距离/m'),ylabel('速度/mps');
title('距离多普勒图');
subplot(122);
image(CFAR_MapRange_Dim,CFAR_MapVelocity_Dim,10*log10(CFAR_Map));
xlabel('距离/m'),ylabel('速度/mps');
title('2D-CFAR检测判决门限')

CRange_Dopple_Map = Range_Dopple_Map(1 + handleWindow_r - proCell_r:N - (handleWindow_r - proCell_r),1 + handleWindow_c - proCell_c:N - (handleWindow_c - proCell_c));
[comR comC] = find(CRange_Dopple_Map < CFAR_Map);
for i = 1:length(comR)
    CRange_Dopple_Map(comR(i),comC(i)) = 0;
end

figure,mesh(CFAR_MapRange_Dim,CFAR_MapVelocity_Dim,CRange_Dopple_Map);
xlabel('距离/m'),ylabel('速度/mps'),zlabel('幅值');
figure,image(CFAR_MapRange_Dim,CFAR_MapVelocity_Dim,CRange_Dopple_Map);
xlabel('距离/m'),ylabel('速度/mps');
