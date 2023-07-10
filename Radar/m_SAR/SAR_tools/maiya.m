nmb = 4;                               %Ŀ�����4��   
rrec =200;                               %����Ŀ����Զ����
b = 100e6;                               %��Ƶ�źŴ���
smb_range = [10,30,40,100];                %����Ŀ��ľ���     ��С�ֱ����Ϊs=c/2b=1.5m
smb_rcs = [1 1 1 2];                      %����Ŀ��ĺ�����
taup = 5e-6;                         %�źų�������
f0 = 5e9;                              % ��ƵƵ��
c = 3e8;                                % �źŴ������ٶȣ�������
fs = 2*b;                                % ������Ƶ��
sampling_interval = 1/fs;                
n = fix(taup/sampling_interval);          %�ܹ�������ȡ����
nfft =n;                                   % ��������
freqlimit = 0.5*fs;                       
freq = linspace(-freqlimit,freqlimit,n);  % Ƶ�ʲ������ = fs/n = 1/taup;
t = linspace(-taup/2,taup/2,n);            %���ڵ�ʱ����
x(:,1:n) = 0.;                             % xΪ����
y(1:n) = 0.;     
replica(1:n) = 0.;
replica = exp(1i * pi * (b/taup) .* t.^2);  %�������Ե�Ƶ�ź�
for j = 1:1:nmb                            %���󷽷��������źŵ���
    range = smb_range(j) ;
    x(j,:) = smb_rcs(j) .*exp(-1i*2*pi*f0*2*range/c).* exp(1i * pi * (b/taup) .* (t + 2*range/c).^2) ; %�����ź�
    y = x(j,:)  + y;                       %�źŵ���
end
rfft = fft(replica,nfft);
yfft = fft(y,nfft);
out= abs(ifft((rfft .* conj(yfft)))) ./ (nfft);
s = taup * c /2; Npoints = ceil(rrec * nfft /s);
dist =linspace(0, rrec, Npoints);          
%ͼƬ��ʾ��
figure 
subplot(311)
plot(t,real(replica));axis tight;
xlabel('Range in meters');ylabel('Amplitude in dB');
title('���Ե�Ƶ�ź�');
subplot(312)
plot(t,real(y));axis tight;
xlabel('Range in meters');ylabel('Amplitude in dB');
title('ѹ��ǰ�״�ز�');
subplot(313);
plot(dist, out(1:Npoints));
xlabel ('Target relative position in meters');
ylabel ('ѹ�����״�ز�');
grid on; 