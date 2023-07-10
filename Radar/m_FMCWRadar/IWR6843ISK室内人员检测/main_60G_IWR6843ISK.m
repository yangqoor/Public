%% ���ߣ���Ƥ������
%% ʱ�䣺2022��04��
%% ���ںţ���Ƥ��������

clear all;
close all;
clc;

%% ��������
ADC_samples=96;  % ÿ��chirp ADC��������
Nfft1=96;        % 1D FFT Num
Nchirp=96;       % ÿ֡chirp��
Nframe=256;      % ֡��
NTx=3;           % ����������
NRx=4;           % ����������
C=3e8;           % ����
sampleRate=2.95e6 ;  % ADC������
startFreq =60.75e9;  % �״﷢���ź���ʼƵ��
Nfft2=Nchirp;        % MIMO���൱��ÿ������loop�Ĵ���
FocusFrameNum=Nframe;%�ۿ�֡��

%�������� 
lambda=C/startFreq;             % �����źŲ���
d=lambda/2;                     % ���߼��
BeamWidth=1.22*lambda/(NRx*d);  % �������

%�������
Tchirp_ramp=60e-6;              % chirp ɨƵʱ�� 
Tchirp=(Tchirp_ramp+30e-6)*3;   % ѭ��chirp��ʱ��  TDM-MIMOģʽ
Tframe_set=55e-3;               % ֡���� 55ms
B_set=3.282e9;                  % ɨƵ����

B= B_set*ADC_samples/Tchirp_ramp/sampleRate;           % �����ź���Ч���� 
freqSlope=54.725e12;%B_set/Tchirp_ramp;                % ��Ƶб��

win1=repmat(hamming(ADC_samples),1,Nfft2*NTx*NRx);     %for 1D FFT ����
win2=repmat(hamming(Nchirp).',ADC_samples,1);          %for 2D FFT ����

FileName = 'E:\Data\RadarImaging\IWR6843ISK������Ա���\adc_data_wuren.bin'; %�ļ���
adc_data = readDCA1000(FileName,ADC_samples,NRx);                                          %��ȡ�ļ�

%% ����
[X,Y] = meshgrid(C*(0:ADC_samples-1)*sampleRate/2/freqSlope/ADC_samples, ...   %������� ת��Ϊ��ʵĿ��ľ�����ٶ�
                (-Nchirp/2:Nchirp/2 - 1)*lambda/Tchirp/Nchirp/2);   
            
%% �����㷨�Ĳ���
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
%��������
Track_Thres=[0.1 1 0.1];   %r_Th  x_Th  v_Th
MmwDemo_Tracking_s_count =0;%����Ŀ�������

%֡ѭ����������
for FrameIndx=1:FocusFrameNum
    datain =adc_data(:,(( FrameIndx-1 )*Nfft1*Nfft2 + 1 ):( Nfft1*Nfft2*FrameIndx ));
    datain=datain.';
    SigReshape=reshape(datain,ADC_samples,Nfft2*NTx*NRx);
%     figure();
%     plot(abs(SigReshape(1,1:256)))
%     title({[FileName];['ͨ��1ʱ�� Frame: ',num2str(FrameIndx)]});
    %% 2DFFT
    [Sig_fft2D]=RangeDopplerProcessing(SigReshape,ADC_samples,Nfft2,NTx,NRx,win1,win2); %win�Ĳ��� ���¼���
%     figure(1);
%     pause(0.1)
%     mesh(db(abs(Sig_fft2D(:,:,1))));
%     title(num2str(FrameIndx));
%     xlabel('�ٶ�');
%     ylabel('����');
%     zlabel('����');
%     view(2);

    %CFARǰ �շ����߶Լ����ɻ���
    detMatrix = zeros(Nchirp,Nfft1);
    for i = 1 : NTx * NRx
        detMatrix = detMatrix + reshape(abs(Sig_fft2D(:,:,i)),96,96);
    end   
%     figure();
%     mesh((detMatrix));
 
    %% ȥ����ֹĿ�� ��ʽ̫�򵥡�����
    detMatrix(:,48:50,:)=0;  %��ֹĿ������ 
%     figure();
%     mesh(abs(detMatrix));

% ������ά�Ƚ���CFAR
% ������ά�Ƚ���CFAR
% %����1D CFAR ��ƽ����Ԫ���龯��
% %ȱ�㣺��Ŀ�����ڡ��Ӳ���Ե����Ƿ��
% %�ŵ㣺��ʧ����С
% %�ο���Ԫ��12
dopplerDimCfarThresholdMap = zeros(size(detMatrix));  %����һ����ά������dopplerάcfar��Ľ��
dopplerDimCfarResultMap = zeros(size(detMatrix));

% %������Ԫ��2
% %�龯���ʣ�0.012,��ô�õ��ġ�
% %����ֵ��5;
Tv=12;Pv=8;PFAv=5;
Tr=8;Pr=4; PFAr=8;

for i = 1:ADC_samples
    dopplerDim = reshape(detMatrix(i,:),1,Nchirp);  %���һ������
    [cfar1D_Arr,threshold] = ca_cfar(Tv,Pv,PFAv,dopplerDim);  %����1D cfar
    dopplerDimCfarResultMap(:,i) = cfar1D_Arr; 
    dopplerDimCfarThresholdMap(:,i) = threshold;
end

% figure();
% mesh(X,Y,(dopplerDimCfarResultMap));
% xlabel('����(m)');ylabel('�ٶ�(m/s)');zlabel('�źŷ�ֵdB');
% title('dopplerά��CFAR�о����'); 

%%
                                                    %����dopplerά�ȷ���Ѱ����dopplerάcfar�о���Ϊ1�Ľ��
saveMat = zeros(size(detMatrix));
for range = 1:ADC_samples
    indexArr = find(dopplerDimCfarResultMap(:,range)==1);
    objDopplerArr = [indexArr;zeros(Nchirp - length(indexArr),1)];   %���䳤��
    saveMat(:,range) = objDopplerArr;               %����doppler�±�
end

                                                    % �����������doppler����
objDopplerIndex = unique(saveMat);                  % unqiue�ǲ��ظ��ķ��������е���
                                                    % ����֮ǰdopplerά��cfar�����Ӧ���±�saveMat������Ӧ���ٶȽ���rangeά�ȵ�CFAR
rangeDimCfarThresholdMap = zeros(size(detMatrix));  %����һ����ά������rangeάcfar��Ľ��
rangeDimCfarResultMap = zeros(size(detMatrix));
outSNRDimCfarThresholdMap= zeros(size(detMatrix));
i = 1;
while(i<=length(objDopplerIndex))
    if(objDopplerIndex(i)==0)                                            % ��Ϊ����������0,��ֹ����jȡ��0
        i = i + 1;
        continue;
    else                                                                 %�����ٶ��±����range CFAR
        j = objDopplerIndex(i);                                          % ����������ڵ���
        rangeDim = reshape(detMatrix(:, j),1,ADC_samples);               %���һ������
        [cfar2D_Arr,threshold,outSNR] = ca_cfar2d(Tr,Pr,PFAr,rangeDim);  %����2D cfar
        rangeDimCfarResultMap(j,:) = cfar2D_Arr; 
        rangeDimCfarThresholdMap(j,:) = threshold;
        outSNRDimCfarThresholdMap(j,:) =outSNR;
        i = i + 1;  
%         plot(20*log10(rangeDim));hold on;
%         plot(20*log10(threshold));
%         title(['����ά������dopplerIndex=',num2str(j)]);
%         xlabel('����(m)');ylabel('�źŷ�ֵdB');
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

%%ˮƽ�ǶȲ���
[objDprIdx,objRagIdx] = peakFocus(rangeDimCfarResultMap,detMatrix);%������ٶȵ�ID��
objDprIdx(objDprIdx==0)=[]; %ȥ�������0
objRagIdx(objRagIdx==0)=[];
outSNRDimCfarThresholdMap(find(outSNRDimCfarThresholdMap==0))=[];
objSpeed = ( objDprIdx - Nchirp/2 - 1)*lambda/Tchirp/Nchirp/2;
Sig_fft2D1 = zeros(96,96,12);

%% ��������λ���������벻һ���ԣ�
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
%     title(['ˮƽ�Ƕȼ���������ǰ֡��',num2str(FrameIndx)]);
%     ylabel('���루m��');
%     xlabel('�Ƕȣ��㣩');
%     pause(0.1);
else
end

%% ��ֱ�Ƕȼ���(�߶�) �߶�ֵ���Ǻ�ȷ��
H = 1.4;%�״ﰲװ�߶�

Sig_fft2DE =Sig_fft2D(:,:,8:9);
if(~isempty(objDprIdx))
    Eangle =processingChain_angleFFTE(objDprIdx,objRagIdx,Sig_fft2DE,lambda,d);  
    Eangle =( Eangle+90)'./57.8;
    h = objRange.*sin(Eangle);
    snr = outSNRDimCfarThresholdMap'; %��������
    X = objRange.*cos(angle);
    Y = objRange.*sin(angle);
    RVA = [ Y,X,h ,objSpeed,snr];

%     figure(1);
%     plot( h,objRange,'ro')
%     axis([-10 10 0 8]);
%     title(['��ֱ�Ƕȼ���������ǰ֡��',num2str(FrameIndx)]);
%     ylabel('���루m��');
%     xlabel('Ŀ��߶ȣ�m��')
%     pause(); 
% if(~isempty(objDprIdx))
%      figure(1);
%      plot3(angle,objRange,h,'o');
%      view(2);
%      grid on;
%      rlim = 8;
%      axis([-90/rlim 90/rlim 0 1 -0.5 0.5]*rlim);
%      title(['3D����,֡����',num2str(FrameIndx)]);
%      ylabel('���루m��');
%      xlabel('�Ƕ�(��)');
%      zlabel('�߶ȣ�m��');
%      pause(); 
%     %     
% else
% end

%% ����DBSCAN �����ˮƽ�Ƕ�����ά�ȵ���Ϣ
%�������
eps = 1;%����뾶
minPointsInCluster = 6;
xFactor = 1;   %�����ƾ����󣬱�С��������С ��Բ
yFactor = 1;   %�����ƽǶȱ�󣬱�С��������С ��Բ 
sumClu =DBSCANclustering_eps_test_3D(eps,RVA,xFactor,yFactor,minPointsInCluster,FrameIndx);  %2D����
 
%%  �����㷨
MmwDemo_Tracking_s(sumClu,F,Q,measurementNoiseVariance,activeThreshold,forgetThreshold,...%��չ�Ŀ������˲�
                             iirForgetFactor,...
                             Track_Thres);
else
    
end                         
%% ����ͼ�λ���
if  ~isempty(activeTrackerList)
    for i=1:length(activeTrackerList)
        tid=activeTrackerList(i); 
        if Tracker(tid).state==1
            MmwDemo_Tracking_s_count  =MmwDemo_Tracking_s_count+1;
            xx(i)=Tracker(tid).S_hat(1,:);
            yy(i)=Tracker(tid).S_hat(2,:);         
            if(MmwDemo_Tracking_s_count==1)%����һ��Ŀ��ʱ����Ϊ1
                 sumTid(i) =1;
            else
                 sumTid(i)=tid;
            end
            hold on;
            plot(yy,xx,'bd','MarkerSize',25)
            text(yy(i)+0.3,xx(i),['ID :',num2str(sumTid(i)),]);  % ID��
%                 text(yy(j),xx(j)+0.1,num2str(Tracker(tid).xSize)); % ˮƽ����
%                 text(yy(j),xx(j)+0.1,num2str(Tracker(tid).ySize)); % ��ֱ����
            text(yy(i)+0.3,xx(i)+0.3,['�ٶ�:',num2str(Tracker(tid).doppler(1)),'  m/s']); %�ٶ�
        end 
    end
end
title([' ���ٽ����֡���� ',num2str(FrameIndx)])
%% Ŀ���ڿ��Ӿ�������ʧ��������λ����Ϣ
%�趨�״�̽�������Χ ���� 8m, ��� 6��

% �����������ɶ������з���

%% 
hold off
xx =[];  %û�д��ڵ�Ŀ�� ���
yy =[];
MmwDemo_Tracking_s_count =0;
pause(0.1);
end


                                            
