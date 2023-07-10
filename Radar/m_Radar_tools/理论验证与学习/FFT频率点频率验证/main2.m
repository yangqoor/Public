%--------------------------------------------------------------------------
%   初始化
%--------------------------------------------------------------------------
clear;clc;

fs = 128e6;                 %信号表达频率

T = 1e-5;                   %信号持续时间
nfft = 1280;
LP = design_filter;
angle_out = [];
count = 1;
for f = 0:1e5:60e6
    sig = rt.exp_wave(T,f,fs);
    sig = sig + 0.05.*rt.randn_complex(size(sig));

    %--------------------------------------------------------------------------
    %   用零相位滤波器模拟通道特性
    %--------------------------------------------------------------------------
    %   零相位滤波器
    %--------------------------------------------------------------------------
    % LP = designfilt('lowpassfir',...
    %                 'PassbandFrequency', 60,...
    %                 'StopbandFrequency', 64,...
    %                 'PassbandRipple', 1,...
    %                 'StopbandAttenuation', 60,...
    %                 'SampleRate', 128);
    % sig = filtfilt(LP,sig);

    %----------------------------------------------------------
    %   常规滤波器
    %----------------------------------------------------------
    sig = filter(LP,sig);

    sig_f = fft(sig,nfft,1);
    db_f = mag2db(abs(sig_f));

    %----------------------------------------------------------
    %   信号相位影响
    %----------------------------------------------------------
    figure(3);
    subplot(211)
    rt.p3(sig_f);axis([0 1280 -1000 1000 -1000 1000])
    title(['信号频率' num2str(f) ' 角度相位' num2str(rad2deg(angle(max(sig_f))))])
    
    mag(count,:) = abs(max(sig_f));
    angle_out(count,:) = rad2deg(unwrap(angle(max(sig_f))));
    count = count+1;
    
    subplot(212);
    yyaxis left;
    plot(angle_out);
    yyaxis right;
    plot(mag);ylim([0 1300])
    drawnow
end
return
figure(3);
subplot(211)
rt.p3(sig_f);axis([0 128 -100 100 -100 100])
title(['信号频率' num2str(f) ' 角度相位' num2str(rad2deg(angle(max(sig_f))))])
subplot(212);plot(angle_out);grid on