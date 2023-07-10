clear all
B=.0125*pi
alpha_s=20;
alpha=0;
D=.9222;
N=(48*D/.3)+1
N=ceil(N)
%N=41
f=2500;
fs=10000;
wc=2*pi*f/fs;



for n=1:1:N
    w(n)=0.54-0.46*cos(2*pi*(n-1)/N);
end
for n=1:1:((N-1)/2)
h(n)=(sin(0.3628*pi*n)-sin(.2177*pi*n))/(pi*n);
end
plot(h)
n=-34
b=(-sin(0.5646*pi*n)-sin(.520*pi*n))/(pi*n);
for i=1:(N-1)/2 
    H(i)=h((N-1)/2 +1-i);
    H(i+(N-1)/2 +1)=h(i);
end
H((N-1)/2 +1)=(0.5646-0.52);
figure(2)
plot(H);
fvtool(H);
H= H.*w;
%p=freqz(H,[11500:1:14000],48000);
%plot(p)
fvtool(H);
%wntool(H);


%%%%%%%%%%%%%%%%%%generate some data%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [g,Fs,bits]=wavread('meep1.wav');
[g,Fs]=audioread('meep1.wav');

lg=length(g);
figure(5)
 plot(20*log10(abs(fft(g,1024))));
fvtool(g)
G=filter(H,1,g);
% wavwrite(G, Fs, 'bandpassd2.wav')
audiowrite('bandpassd2.wav',G,Fs);
fvtool(G)