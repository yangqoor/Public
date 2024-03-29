%--------------------------------------------------------------------------
%   rt toolbox
%   author:qwe14789cn@gmail.com
%   https://github.com/qwe14789cn/radar_tools
%--------------------------------------------------------------------------
%   rt.ad_analyzer(sig,bw_range,fs,sep_N,AD_len,flag)
%--------------------------------------------------------------------------
%   Description:
%   Analysis the input signal about the Spectrum and phase angle
%--------------------------------------------------------------------------
%   input:
%           sig         输入信号
%           bw_range    分析带宽
%           fs          采样速率
%           sep_N       信号隔离点数
%           AD_len      AD位数
%           flag        饱和 非饱和标记位 默认为0 非饱和  1 饱和
%	output：
%           ENOB        有效位
%--------------------------------------------------------------------------
%   Examples:
%   rt.ad_analyzer(sig,[8.5e6 11.5e6],fs,70,14)
%   rt.ad_analyzer(sig,[8.5e6 11.5e6],fs,70,14,1)
%--------------------------------------------------------------------------
function ad_analyzer(sig,bw_range,fs,sep_N,AD_len,flag)
if nargin <=5
    flag = 1;
end
disp('------------------------------------------------------------')
disp('注意：AD测试须满足以下公式不会发生频谱泄露')
disp('M/N=Fin/Fs')
disp('M为时域的周期数，N为采点数，Fs为采样频率，Fin为信号频率')
disp('------------------------------------------------------------')
disp('1.如果输入信号信噪比 饱和 = 1.76+6.02*AD位数');
disp('请将最后一项设置为1')
disp('rt.ad_analyzer(sig,[0 fs/2],fs,sep_N,AD_len,1)')
disp('------------------------------------------------------------')
disp('2.如果输入信号信噪比 不饱和 <= 1.76+6.02*AD位数');
disp('请将最后一项设置为0 或者不设置')
disp('rt.ad_analyzer(sig,[0 fs/2],fs,sep_N,AD_len)')
disp('------------------------------------------------------------')
disp('3.如果输入信号信噪比是在一定带宽计算得到');
disp('请将最后一项设置为1,并设定带宽范围')
disp('rt.ad_analyzer(sig,[8e6 12e6],fs,sep_N,AD_len,1)')
disp('------------------------------------------------------------')
disp('数据分析');
disp('------------------------------------------------------------')
Nfft = 2^nextpow2(length(sig));                                             %自动计算fft点数
x = 0:fs/Nfft:fs/2 - fs/Nfft;                                               %频率横坐标
f = fft(sig,Nfft);
f = f(1:Nfft/2);
a = abs(f);
p = a.^2;
db = pow2db(p);
db = db - max(db(:));
%--------------------------------------------------------------------------
%   拿到最高频率点
%--------------------------------------------------------------------------
loc = find(p==max(p));
p_max = p(loc);
N_range = [ceil(min(bw_range)/fs*Nfft+0.1):(loc-sep_N) ...
           (loc+sep_N):floor(max(bw_range)/fs*Nfft)];                       %分析点数范围
SNR = pow2db(p_max./sum(p(N_range)));
if flag ==0
    ENOB = (SNR - 1.76 - 20*log10(max(sig(:))./2^(AD_len-1)))/6.02;
end
if flag ==1
    ENOB = (SNR - 1.76)/6.02;
end

fprintf('分析频率范围 %1.2fMhz ~ %1.2fMhz\n',bw_range/1e6);
fprintf('信号左右隔离点数 %d\n',sep_N);
fprintf('信噪比SNR = %1.2f dB,',SNR);
if flag ==0
    fprintf('非饱和状态补偿ENOB = %1.2f\n',ENOB);
elseif flag==1
    fprintf('饱和状态计算ENOB = %1.2f\n',ENOB);
end
fprintf('AD位数为 %d 位,理论动态范围应为 %1.2f dB\n',[AD_len 2*pow2db(2^AD_len)]);


%--------------------------------------------------------------------------
%   频率分布
%--------------------------------------------------------------------------
%   坐标修正
%--------------------------------------------------------------------------
if fs/1e6 > 1 && fs/1e9 < 1
    x = x/1e6;
    type = 1;
end
if fs/1e3 > 1 && fs/1e6 < 1
    x = x/1e3;
    type = 2;
end
plot(x,db,x(N_range),db(N_range));legend('信号频谱','分析区间');
if type==1
    xlabel('频率 MHz')
end
if type==2
    xlabel('频率 KHz')
end
ylabel('dB')
