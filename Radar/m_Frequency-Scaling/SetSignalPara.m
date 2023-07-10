%%
% 该函数用来设置雷达信号参数，
% 当SignalParaFlag=1时函数返回信号参数结构体；
% SignalParaFlag=0时，无参数
%%
function SignalPara=SetSignalPara(SignalParaFlag)
if SignalParaFlag
    c=3e8;%光速
    fc=1.26e9;%5.3e9;%频率
    lamda=c/fc;%波长
    Br=60e6;%50e6;%信号带宽
    Tp=80e-6;%2.5e-6;%信号脉冲宽度
    gama=Br/Tp;%调频率
    SignalPara=struct('c',c,'fc',fc,'lamda',lamda,'Br',Br,'Tp',Tp,'gama',gama,'state',SignalParaFlag);
else
    SignalPara=struct('state',SignalParaFlag);
end
end