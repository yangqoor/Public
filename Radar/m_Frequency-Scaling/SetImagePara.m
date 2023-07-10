%%
% �ú������������״���������
% ��SignalParaFlag=1ʱ���������źŲ����ṹ�壻
% SignalParaFlag=0ʱ���޲���
%%
function [RangePara,AzimuthPara,RadarPara,TargetPara]=...
    SetImagePara(SignalPara,ImageParaFlag)
if ImageParaFlag  
    c=SignalPara.c;
    Tp= SignalPara.Tp;
    
    Vr = 7349;%150;               % �״���Ч�ٶ�
    phi  = 0/180*pi;	  % ����б�ӽ�
    
    Rc = 640e3;%20e3;            % ������б��
    DeltaRange=100;%������Ŀ����
    DeltaAzimuth=200;%��λ��Ŀ����
    TargetPos=[Rc,0;Rc,DeltaAzimuth/2;Rc,DeltaAzimuth; ...
        Rc+DeltaRange/2,0; Rc+DeltaRange/2 DeltaAzimuth/2; Rc+DeltaRange/2 DeltaAzimuth; ...
        Rc+DeltaRange,0; Rc+DeltaRange DeltaAzimuth/2; Rc+DeltaRange DeltaAzimuth];
    TargetNum=size(TargetPos,1);%Ŀ����Ŀ
    
    
    Rref = Rc;         %�ο�б��
    res_r = 0.886 * c/2/SignalPara.Br;%������ֱ���
    RangeFactor=1.5;%1.2;%����������
    fr=RangeFactor*SignalPara.Br;%���������Ƶ��
%     Nr=2^nextpow2((2*(DeltaRange)/c+Tp)*fr);%�������ĵ�������ȡ��2���ݴΣ��������fft
%     Nr=round((2*(DeltaRange)/c+Tp)*fr);%�������ĵ�������ȡ��2���ݴΣ��������fft
%       Nr=fix(Tp*fr)*2; 
    Nr=7500;%256
      
     tr = 2*Rc/c+(-Nr/2:Nr/2-1)/fr;
    
%     B_dop=80;%�����մ���
      Da=9.8;
      B_dop=0.886*2*Vr*cos(phi)/Da;
%       Da = 0.886*2*Vr*cos(phi)/B_dop;                                  %��λ�����߳ߴ�
      res_a = Da/2;                            %��λ��ֱ���
%   
    beta_bw = 0.886*SignalPara.lamda/Da;              % �״�3dB����
%     AzimuthFactor=2.5;%����������
%     PRF=AzimuthFactor*B_dop;%��λ����Ƶ��
%     Pri=1/PRF;%�������
      Ka = 2*Vr.^2*(cos(phi)).^3/SignalPara.lamda/Rc;%��λ���Ƶ��ʽ4.38
    Ts = B_dop/abs(Ka);%Ŀ������ʱ�䣬�����մ���=Ŀ������ʱ��*��λ���Ƶ��
      Ls =beta_bw*Rc;%Vr*Ts; %�ϳɿ׾�����
%     Na=2^nextpow2((DeltaAzimuth+2*Ls)/Vr*PRF);
    
    PRF=1747;
    Pri=1/PRF;
    AzimuthFactor=PRF/B_dop;
    Na=4096;%1024;
    ta = (-Na/2 : Na/2-1)/PRF; %��λ��ʱ��
    
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