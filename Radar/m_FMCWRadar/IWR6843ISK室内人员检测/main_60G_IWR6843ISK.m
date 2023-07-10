%% 作者：调皮连续波
%% 时间：2022年04月
%% 公众号：调皮的连续波

clear all;
close all;
clc;

%% 参数设置
ADC_samples=96;  % 每个chirp ADC采样点数
Nfft1=96;        % 1D FFT Num
Nchirp=96;       % 每帧chirp数
Nframe=256;      % 帧数
NTx=3;           % 发射天线数
NRx=4;           % 接收天线数
C=3e8;           % 光速
sampleRate=2.95e6 ;  % ADC采样率
startFreq =60.75e9;  % 雷达发射信号起始频率
Nfft2=Nchirp;        % MIMO后相当于每个天线loop的次数
FocusFrameNum=Nframe;%观看帧数

%波束参数 
lambda=C/startFreq;             % 发射信号波长
d=lambda/2;                     % 天线间距
BeamWidth=1.22*lambda/(NRx*d);  % 波束宽度

%推算参数
Tchirp_ramp=60e-6;              % chirp 扫频时间 
Tchirp=(Tchirp_ramp+30e-6)*3;   % 循环chirp总时间  TDM-MIMO模式
Tframe_set=55e-3;               % 帧周期 55ms
B_set=3.282e9;                  % 扫频带宽

B= B_set*ADC_samples/Tchirp_ramp/sampleRate;           % 发射信号有效带宽 
freqSlope=54.725e12;%B_set/Tchirp_ramp;                % 调频斜率

win1=repmat(hamming(ADC_samples),1,Nfft2*NTx*NRx);     %for 1D FFT 窗长
win2=repmat(hamming(Nchirp).',ADC_samples,1);          %for 2D FFT 窗长

FileName = 'E:\Data\RadarImaging\IWR6843ISK室内人员检测\adc_data_wuren.bin'; %文件名
adc_data = readDCA1000(FileName,ADC_samples,NRx);                                          %读取文件

%% 坐标
[X,Y] = meshgrid(C*(0:ADC_samples-1)*sampleRate/2/freqSlope/ADC_samples, ...   %坐标计算 转换为真实目标的距离和速度
                (-Nchirp/2:Nchirp/2 - 1)*lambda/Tchirp/Nchirp/2);   
            
%% 跟踪算法的参数
global Tracker
global RADARDEMO_CT_MAX_NUM_CLUSTER
global RADARDEMO_CT_MAX_NUM_TRACKER
global RADARDEMO_CT_MAX_NUM_ASSOC
global RADARDEMO_CT_MAX_DIST
global RADARMEDO_CT_MAX_NUM_EXPIRE
RADARDEMO_CT_MAX_NUM_CLUSTER=800; %
RADARDEMO_CT_MAX_NUM_TRACKER=30;
RADARDEMO_CT_MAX_NUM_ASSOC=6;
RADARDEMO_CT_MAX_DIST=0.1e8;
RADARMEDO_CT_MAX_NUM_EXPIRE=16;
global activeTrackerList
global idleTrackerList
dbscan_nAccFrames=1;
dt=Tframe_set * dbscan_nAccFrames;

%RADARDEMO_clusterTracker_updateFQ
F =        [1, 0, dt, 0;...
            0, 1, 0, dt;...
            0, 0, 1, 0;...
            0, 0, 0, 1];    
c =  (dt*dt*4.0); % (dt*2)^2 *d
b =  (c*dt*2);    % (dt*2)^3 *d
a =  (c*c);       % (dt*2)^4 *d
Q = [a, 0, b, 0;
     0, a, 0, b;
     b, 0, c, 0;
     0, b, 0, c];
clear a b c 
activeTrackerList=[];
idleTrackerList=1:RADARDEMO_CT_MAX_NUM_TRACKER;
Tracker.S_apriori_hat=ones(4,1);
Tracker.S_hat=ones(4,1);
Tracker.H_s_apriori_hat=ones(3,1);
Tracker.diagonal2=4;
Tracker.state=-1;
Tracker.detect2freeCoun=3;
Tracker.detect2activeCount=1;
Tracker.detect2freeCount=3;
Tracker.active2freeCount=6;
Tracker.typeCount = 0;
measurementNoiseVariance   = 1;     %1
iirForgetFactor   = 1;              %0.2
activeThreshold   = 6;              %2
forgetThreshold   = 4;              %4
%跟踪门限
Track_Thres=[0.1 1 0.1];   %r_Th  x_Th  v_Th
MmwDemo_Tracking_s_count =0;%跟踪目标计数器

%帧循环处理数据
for FrameIndx=1:FocusFrameNum
    datain =adc_data(:,(( FrameIndx-1 )*Nfft1*Nfft2 + 1 ):( Nfft1*Nfft2*FrameIndx ));
    datain=datain.';
    SigReshape=reshape(datain,ADC_samples,Nfft2*NTx*NRx);
%     figure();
%     plot(abs(SigReshape(1,1:256)))
%     title({[FileName];['通道1时域 Frame: ',num2str(FrameIndx)]});
    %% 2DFFT
    [Sig_fft2D]=RangeDopplerProcessing(SigReshape,ADC_samples,Nfft2,NTx,NRx,win1,win2); %win的参数 重新计算
%     figure(1);
%     pause(0.1)
%     mesh(db(abs(Sig_fft2D(:,:,1))));
%     title(num2str(FrameIndx));
%     xlabel('速度');
%     ylabel('距离');
%     zlabel('幅度');
%     view(2);

    %CFAR前 收发天线对间非相干积累
    detMatrix = zeros(Nchirp,Nfft1);
    for i = 1 : NTx * NRx
        detMatrix = detMatrix + reshape(abs(Sig_fft2D(:,:,i)),96,96);
    end   
%     figure();
%     mesh((detMatrix));
 
    %% 去除静止目标 方式太简单、暴力
    detMatrix(:,48:50,:)=0;  %静止目标置零 
%     figure();
%     mesh(abs(detMatrix));

% 多普勒维度进行CFAR
% 多普勒维度进行CFAR
% %进行1D CFAR ，平均单元恒虚警率
% %缺点：多目标遮掩、杂波边缘性能欠佳
% %优点：损失率最小
% %参考单元：12
dopplerDimCfarThresholdMap = zeros(size(detMatrix));  %创建一个二维矩阵存放doppler维cfar后的结果
dopplerDimCfarResultMap = zeros(size(detMatrix));

% %保护单元：2
% %虚警概率：0.012,怎么得到的。
% %门限值：5;
Tv=12;Pv=8;PFAv=5;
Tr=8;Pr=4; PFAr=8;

for i = 1:ADC_samples
    dopplerDim = reshape(detMatrix(i,:),1,Nchirp);  %变成一行数据
    [cfar1D_Arr,threshold] = ca_cfar(Tv,Pv,PFAv,dopplerDim);  %进行1D cfar
    dopplerDimCfarResultMap(:,i) = cfar1D_Arr; 
    dopplerDimCfarThresholdMap(:,i) = threshold;
end

% figure();
% mesh(X,Y,(dopplerDimCfarResultMap));
% xlabel('距离(m)');ylabel('速度(m/s)');zlabel('信号幅值dB');
% title('doppler维度CFAR判决结果'); 

%%
                                                    %沿着doppler维度方向寻找在doppler维cfar判决后为1的结果
saveMat = zeros(size(detMatrix));
for range = 1:ADC_samples
    indexArr = find(dopplerDimCfarResultMap(:,range)==1);
    objDopplerArr = [indexArr;zeros(Nchirp - length(indexArr),1)];   %补充长度
    saveMat(:,range) = objDopplerArr;               %保存doppler下标
end

                                                    % 保存有物体的doppler坐标
objDopplerIndex = unique(saveMat);                  % unqiue是不重复的返回数组中的数
                                                    % 根据之前doppler维的cfar结果对应的下标saveMat，对相应的速度进行range维度的CFAR
rangeDimCfarThresholdMap = zeros(size(detMatrix));  %创建一个二维矩阵存放range维cfar后的结果
rangeDimCfarResultMap = zeros(size(detMatrix));
outSNRDimCfarThresholdMap= zeros(size(detMatrix));
i = 1;
while(i<=length(objDopplerIndex))
    if(objDopplerIndex(i)==0)                                            % 因为数组里面有0,防止下面j取到0
        i = i + 1;
        continue;
    else                                                                 %根据速度下标进行range CFAR
        j = objDopplerIndex(i);                                          % 获得物体所在的行
        rangeDim = reshape(detMatrix(:, j),1,ADC_samples);               %变成一行数据
        [cfar2D_Arr,threshold,outSNR] = ca_cfar2d(Tr,Pr,PFAr,rangeDim);  %进行2D cfar
        rangeDimCfarResultMap(j,:) = cfar2D_Arr; 
        rangeDimCfarThresholdMap(j,:) = threshold;
        outSNRDimCfarThresholdMap(j,:) =outSNR;
        i = i + 1;  
%         plot(20*log10(rangeDim));hold on;
%         plot(20*log10(threshold));
%         title(['距离维度门限dopplerIndex=',num2str(j)]);
%         xlabel('距离(m)');ylabel('信号幅值dB');
%         figure;
    end
end

% mesh(outSNRDimCfarThresholdMap)
% plot((rangeDim));
% hold on;
% plot(threshold);
% figure();
% mesh(X,Y,(rangeDimCfarResultMap));
% view(2);
% pause(0.1);   

%%水平角度测量
[objDprIdx,objRagIdx] = peakFocus(rangeDimCfarResultMap,detMatrix);%距离和速度的ID号
objDprIdx(objDprIdx==0)=[]; %去掉后面的0
objRagIdx(objRagIdx==0)=[];
outSNRDimCfarThresholdMap(find(outSNRDimCfarThresholdMap==0))=[];
objSpeed = ( objDprIdx - Nchirp/2 - 1)*lambda/Tchirp/Nchirp/2;
Sig_fft2D1 = zeros(96,96,12);

%% 多普勒相位补偿（代码不一定对）
for k =1:3
    for  m=1:96
         Sig_fft2D1(m,:,((k-1)*4+1):k*4) =   Sig_fft2D(m,:,((k-1)*4+1):k*4)*exp(-j*2*3.14*k*m/(3*96));
    end
end
Sig_fft2D  =Sig_fft2D1;
%%
objRange = single(C*(objRagIdx-1)*sampleRate/2/freqSlope/ADC_samples);

if(~isempty(objDprIdx))
    angle =processingChain_angleFFT(objDprIdx,objRagIdx,Sig_fft2D(:,:,1:8));
    angle = (angle+90)'./57.8;
%     RVA = [objRange,angle];
%     figure(1);
%     plot(angle,objRange,'o')
%     rlim = 8;
%     axis([-90/rlim 90/rlim 0 1]*rlim);
%     
%     title(['水平角度计算结果，当前帧：',num2str(FrameIndx)]);
%     ylabel('距离（m）');
%     xlabel('角度（°）');
%     pause(0.1);
else
end

%% 垂直角度计算(高度) 高度值不是很确定
H = 1.4;%雷达安装高度

Sig_fft2DE =Sig_fft2D(:,:,8:9);
if(~isempty(objDprIdx))
    Eangle =processingChain_angleFFTE(objDprIdx,objRagIdx,Sig_fft2DE,lambda,d);  
    Eangle =( Eangle+90)'./57.8;
    h = objRange.*sin(Eangle);
    snr = outSNRDimCfarThresholdMap'; %数据整合
    X = objRange.*cos(angle);
    Y = objRange.*sin(angle);
    RVA = [ Y,X,h ,objSpeed,snr];

%     figure(1);
%     plot( h,objRange,'ro')
%     axis([-10 10 0 8]);
%     title(['垂直角度计算结果，当前帧：',num2str(FrameIndx)]);
%     ylabel('距离（m）');
%     xlabel('目标高度（m）')
%     pause(); 
% if(~isempty(objDprIdx))
%      figure(1);
%      plot3(angle,objRange,h,'o');
%      view(2);
%      grid on;
%      rlim = 8;
%      axis([-90/rlim 90/rlim 0 1 -0.5 0.5]*rlim);
%      title(['3D点云,帧数：',num2str(FrameIndx)]);
%      ylabel('距离（m）');
%      xlabel('角度(°)');
%      zlabel('高度（m）');
%      pause(); 
%     %     
% else
% end

%% 聚类DBSCAN 距离和水平角度两个维度的信息
%聚类参数
eps = 1;%邻域半径
minPointsInCluster = 6;
xFactor = 1;   %变大控制距离变大，变小分类距离变小 椭圆
yFactor = 1;   %变大控制角度变大，变小分类距离变小 椭圆 
sumClu =DBSCANclustering_eps_test_3D(eps,RVA,xFactor,yFactor,minPointsInCluster,FrameIndx);  %2D聚类
 
%%  跟踪算法
MmwDemo_Tracking_s(sumClu,F,Q,measurementNoiseVariance,activeThreshold,forgetThreshold,...%扩展的卡尔曼滤波
                             iirForgetFactor,...
                             Track_Thres);
else
    
end                         
%% 跟踪图形绘制
if  ~isempty(activeTrackerList)
    for i=1:length(activeTrackerList)
        tid=activeTrackerList(i); 
        if Tracker(tid).state==1
            MmwDemo_Tracking_s_count  =MmwDemo_Tracking_s_count+1;
            xx(i)=Tracker(tid).S_hat(1,:);
            yy(i)=Tracker(tid).S_hat(2,:);         
            if(MmwDemo_Tracking_s_count==1)%仅有一个目标时计数为1
                 sumTid(i) =1;
            else
                 sumTid(i)=tid;
            end
            hold on;
            plot(yy,xx,'bd','MarkerSize',25)
            text(yy(i)+0.3,xx(i),['ID :',num2str(sumTid(i)),]);  % ID号
%                 text(yy(j),xx(j)+0.1,num2str(Tracker(tid).xSize)); % 水平距离
%                 text(yy(j),xx(j)+0.1,num2str(Tracker(tid).ySize)); % 垂直距离
            text(yy(i)+0.3,xx(i)+0.3,['速度:',num2str(Tracker(tid).doppler(1)),'  m/s']); %速度
        end 
    end
end
title([' 跟踪结果，帧数： ',num2str(FrameIndx)])
%% 目标在可视距离内消失，记忆其位置信息
%设定雷达探测的物理范围 长度 8m, 宽度 6米

% 后续工作可由读者自行发挥

%% 
hold off
xx =[];  %没有存在的目标 清除
yy =[];
MmwDemo_Tracking_s_count =0;
pause(0.1);
end


                                            
