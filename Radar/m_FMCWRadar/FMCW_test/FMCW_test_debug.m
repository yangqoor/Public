clc,close all,clear all;
%% parameters
f0      = 24.125e9; %% center freq, unit: Hz
fm      = 100;      %% unit: Hz
tm      = 1/fm;     %% unit: s
N       = 1024;     %% points of FFT trans
B       = 100e6;    %% mod bandwidth, unit: Hz
C       = 3e8;      %% speed of light, unit: m/s
d_2p    = 0.014;    %% distance between two echo antennas, unit: m
fs      = 256e3;    %% AD sample rate, unit: Hz
t       = 0:1/fs:1; %% range of time domin( 1 second )

%% window function type, length of window is the same as FFT
win     = chebwin(N);

%% user define
ang_simu        = 2;                    %% angle base on normal line, unit: бу
ang_hd          = ang_simu/360*2*pi;    %% angle base on normal line, unit: rad
diff_refr       = sin(ang_hd)*d_2p;     %% distance_diff of two echos, unit: m 
ang_hd_lamda    = diff_refr*f0/C*2*pi;  %% phase_diff of two echos, unit; rad

r           = 90;                       %% distance base on normal point, unit: m              
tao1        = 2*r/C + diff_refr/C;      %% delay of echo1, unit: s
tao2        = 2*r/C;                    %% delay of echo2, unit: s

%% signals, after mix
s1_mix_i = cos(2*pi*(f0 - B*0.5)*tao1 + 2*pi*B*tao1.*t/tm);
s1_mix_q = sin(2*pi*(f0 - B*0.5)*tao1 + 2*pi*B*tao1.*t/tm);
s2_mix_i = cos(2*pi*(f0 - B*0.5)*tao2 + 2*pi*B*tao2.*t/tm);
s2_mix_q = sin(2*pi*(f0 - B*0.5)*tao2 + 2*pi*B*tao2.*t/tm);

%% DSP 
for i = 1:250   %% in 1s, if points of FFT are 1024, fs = 256e3, i_max = fs/N = 250
    
    %%%% each fft needs 1024 points of digital signal
    
    xout_1i = s1_mix_i((i-1)*N+1:N*i);
    xout_1q = s1_mix_q((i-1)*N+1:N*i);
    xout_2i = s2_mix_i((i-1)*N+1:N*i);
    xout_2q = s2_mix_q((i-1)*N+1:N*i);
    
    %%%% I channel & Q channel combine to complex
    
    cout_1 = complex(xout_1i,xout_1q);
    cout_2 = complex(xout_2i,xout_2q);
    
    %%%% add win %%%%
    
    wout_1 = cout_1.*win';
    wout_2 = cout_2.*win';
    
    %%%% two diff_signal fft trans %%%%
    
    fout_1 = fft(wout_1);
    fout_2 = fft(wout_2);
    
    %%%% distance (choose channel no.1)%%%%
    
    position = find(abs(fout_1) == max(abs(fout_1)));
    freq     = position/N*fs;
    L_target(i) = C*tm*freq/(2*B);
    
    %%%% phase    (need 2 channels)    %%%%
    
    diff_ang = angle(wout_1(1)) - angle(wout_2(1));
    diff = diff_ang/(2*pi)*(C/f0);
    sin_sita = diff/d_2p;
    angle_result(i) = asin(sin_sita);
    A_target(i) = angle_result(i)*360/(2*pi);
    
    %%%%%%% counter %%%%%%%%
    if(mod(i,10) == 0)
        i
    end
    
end
%% polar can give the relationship between angle and distance
figure;polar(angle_result,L_target,'*r');