%������С(��)�������е���ɢ����Ҷ�任
Na=6;%aperture length measured in terms of number of grid intervals
%6;%34;
N=8;%numger of elements in array
%4;
x=[1 1 0 0 1 0 1];
%[1 1 0 0 1 0 1];%[1 1 0 0 1 zeros(1,4) 1 zeros(1,5) 1 zeros(1,6) 1 zeros(1,9) 1 0 1];

%������x��FFT
X1=fft(x,Na+1);%Na+1��fft
X2=fft(x,(Na+1)*10);%(Na+1)*10��fft
X1=abs(X1);
X2=abs(X2);
X1=fftshift(X1);
X2=fftshift(X2);

figure(1);
plot(X1,'k');
hold on;
plot(X1,'k.');
grid on;
figure(2);
plot(X2,'k');
grid on;