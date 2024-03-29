%--------------------------------------------------------------------------
%   脉压信号自动计算脉压因子
%   20180623
%   刘夏
%--------------------------------------------------------------------------
%   输入
%   temple_sig  模板信号
%   bw_range    信号带宽
%   fs          生成信号的采样速率
%   Nfft        做脉压因子的点数
%   window_fun  窗函数，可以不写，默认用chebwin，因为chebwin噪底平坦
%--------------------------------------------------------------------------
%   example
%   waveform = phased.FMCWWaveform('SweepTime',T,'SweepBandwidth',bw,...
%              'SampleRate',fs,'SweepInterval','Symmetric');
%   sig = step(waveform);
%   rt.pcf(sig,[-5e6 5e6],fs,Nfft);
%   或者
%   rt.pcf(sig,[-5e6 5e6],fs,Nfft,@(x)chebwin(x,100))
%--------------------------------------------------------------------------
function pcf = pc_factor(temple_sig,bw_range,fs,Nfft,window_fun)
if isreal(temple_sig)~=0
    disp('sig必须为复信号');
    pcf = nan;
    return
end
if nargin <=4
    window_fun = @(x)chebwin(x,100);                                        %不传递参数采用默认切比雪夫窗
end
bw_low = min(bw_range);                                                     %信号起始带宽
bw_max = max(bw_range);                                                     %信号结束带宽
bw = bw_max-bw_low;                                                         %信号带宽范围
N = round(bw/fs*Nfft);                                                      %占用fft点数的范围区间
window_f = [window_fun(N);zeros(Nfft-N,1)];                                 %生成频域加窗序列
shift_point = round(bw_low/fs*Nfft);                                        %计算窗函数移动点数
window_f = circshift(window_f,shift_point);                                 %新的频域窗
pcf = window_f./fft(temple_sig,Nfft);                                       %实数除以复数刚好是共轭










