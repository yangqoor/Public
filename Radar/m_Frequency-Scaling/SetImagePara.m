%%
% 该函数用来设置雷达成像参数，
% 当SignalParaFlag=1时函数返回信号参数结构体；
% SignalParaFlag=0时，无参数
%%
function [RangePara,AzimuthPara,RadarPara,TargetPara]=...
    SetImagePara(SignalPara,ImageParaFlag)
if ImageParaFlag  
    c=SignalPara.c;
    Tp= SignalPara.Tp;
    
    Vr = 7349;%150;               % 雷达有效速度
    phi  = 0/180*pi;	  % 波束斜视角
    
    Rc = 640e3;%20e3;            % 景中心斜距
    DeltaRange=100;%距离向目标间隔
    DeltaAzimuth=200;%方位向目标间隔
    TargetPos=[Rc,0;Rc,DeltaAzimuth/2;Rc,DeltaAzimuth; ...
        Rc+DeltaRange/2,0; Rc+DeltaRange/2 DeltaAzimuth/2; Rc+DeltaRange/2 DeltaAzimuth; ...
        Rc+DeltaRange,0; Rc+DeltaRange DeltaAzimuth/2; Rc+DeltaRange DeltaAzimuth];
    TargetNum=size(TargetPos,1);%目标数目
    
    
    Rref = Rc;         %参考斜距
    res_r = 0.886 * c/2/SignalPara.Br;%距离向分辨率
    RangeFactor=1.5;%1.2;%过采样因子
    fr=RangeFactor*SignalPara.Br;%距离向采样频率
%     Nr=2^nextpow2((2*(DeltaRange)/c+Tp)*fr);%采样窗的点数向上取到2的幂次，方便计算fft
%     Nr=round((2*(DeltaRange)/c+Tp)*fr);%采样窗的点数向上取到2的幂次，方便计算fft
%       Nr=fix(Tp*fr)*2; 
    Nr=7500;%256
      
     tr = 2*Rc/c+(-Nr/2:Nr/2-1)/fr;
    
%     B_dop=80;%多普勒带宽
      Da=9.8;
      B_dop=0.886*2*Vr*cos(phi)/Da;
%       Da = 0.886*2*Vr*cos(phi)/B_dop;                                  %方位向天线尺寸
      res_a = Da/2;                            %方位向分辨率
%   
    beta_bw = 0.886*SignalPara.lamda/Da;              % 雷达3dB波束
%     AzimuthFactor=2.5;%过采样因子
%     PRF=AzimuthFactor*B_dop;%方位采样频率
%     Pri=1/PRF;%采样间隔
      Ka = 2*Vr.^2*(cos(phi)).^3/SignalPara.lamda/Rc;%方位向调频率式4.38
    Ts = B_dop/abs(Ka);%目标照射时间，多普勒带宽=目标照射时间*方位向调频率
      Ls =beta_bw*Rc;%Vr*Ts; %合成孔径长度
%     Na=2^nextpow2((DeltaAzimuth+2*Ls)/Vr*PRF);
    
    PRF=1747;
    Pri=1/PRF;
    AzimuthFactor=PRF/B_dop;
    Na=4096;%1024;
    ta = (-Na/2 : Na/2-1)/PRF; %方位向时间
    
    RangePara=struct('Rc',Rc,'Rref',Rref,'res_r',res_r,'RangeFactor',RangeFactor,'fr',fr,'Nr',Nr,'tr',tr,'state',ImageParaFlag);
    AzimuthPara=struct('Da',Da,'res_a',res_a,'beta_bw',beta_bw,'B_dop',B_dop,'AzimuthFactor',AzimuthFactor,'PRF',PRF,'Pri',Pri,'Ka',Ka,'Ts',Ts,'Ls',Ls,'Na',Na,'ta',ta,'state',ImageParaFlag);
    RadarPara=struct('Vr',Vr,'phi',phi,'state',ImageParaFlag);
    TargetPara=struct('TargetPos',TargetPos,'TargetNum',TargetNum,'state',ImageParaFlag);
      
else
    RangePara=struct('state',ImageParaFlag);
    AzimuthPara=struct('state',ImageParaFlag);
    RadarPara=struct('state',ImageParaFlag);
    TargetPara=struct('state',ImageParaFlag);
end
end