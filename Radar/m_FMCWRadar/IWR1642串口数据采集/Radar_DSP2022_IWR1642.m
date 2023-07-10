%% ���ߣ���Ƥ������
%% ���ںţ���Ƥ��������
%% 2022��4��
%%
clc;
close all;
clear all;

%% �״����
Tx_Number = 2;               %��������
Rx_Number = 4;               %��������
Range_Number = 128;          %���������ÿ������128���㣩
Doppler_Number = 128;        %������ͨ����(�ܹ�128���ظ�������)
global Params;
Params.NChirp = Doppler_Number;               %1֡���ݵ�chirp����
Params.NChan =  Rx_Number;                    %RxAn��,ADCͨ����
Params.NSample = Range_Number;                %ÿ��chirp ADC������
Params.Fs = 2.5e6;                           %����Ƶ��
Params.c = 3.0e8;                     %����
Params.startFreq = 77e9;              %��ʼƵ�� 
Params.freqSlope = 60e12;             %chirp��б��
Params.bandwidth = 3.072e9;           %��ʵ����
Params.lambda=Params.c/Params.startFreq;    %�״��źŲ���
Params.Tc = 144e-6;                         %chirp����
global FFT2_mag;

%% �������
[X,Y] = meshgrid(Params.c*(0:Params.NSample-1)*Params.Fs/2/Params.freqSlope/Params.NSample, ...
    (-Params.NChirp/2:Params.NChirp/2 - 1)*Params.lambda/Params.Tc/Params.NChirp/2);   
%%
loadCfg = 0;   %�ɼ����� 1,�ط�����0
if(loadCfg)
        delete(instrfind);           % ɾ������
        [controlSerialPort,dataSerialPort] = serial_port();   %% �Զ�ʶ�𴮿�
        configurationFileName_stop ='iwr1642.cfg';             
        cliCfg = readCfg(configurationFileName_stop);          % �����ļ���ȡ

        hdataSerialPort = configureDataSport(dataSerialPort,Tx_Number*Rx_Number*Doppler_Number*Range_Number*2*2);%���� COM����
        mmwDemoCliPrompt = char('mmwDemo:/>');
        hControlSerialPort = configureControlPort(controlSerialPort);%���� COM����
 
        %Send CLI configuration to IWR16xx
        fprintf('Sending configuration from %s file to IWR16xx ...\n', configurationFileName_stop);
        for k=1:length(cliCfg)
            fprintf(hControlSerialPort, cliCfg{k});
            fprintf('%s\n', cliCfg{k});
            echo = fgetl(hControlSerialPort); % Get an echo of a command
            done = fgetl(hControlSerialPort); % Get "Done" 
            prompt = fread(hControlSerialPort, size(mmwDemoCliPrompt,2)); % Get the prompt back 
        end
       
        prompt_1= fread(hdataSerialPort, Tx_Number*Rx_Number*Doppler_Number*Range_Number*2*2); % Get the prompt back 
       %% ���ڴ˱�������
        adc_data =  dec2hex(prompt_1,2);
%         save adc_data,adc_data.mat;
        Data_dec=(adc_data);           %��16����ת��Ϊ10����
        fclose(hControlSerialPort);
        delete(hControlSerialPort);
        fclose(hdataSerialPort);
        delete(hdataSerialPort);    
else
        adc_data =load('angle_4.mat');
        Data_dec=(adc_data.prompt_1);           %��16����ת��Ϊ10����
end

%% ���ݶ�ȡ����֡����
Data_zuhe=zeros(1,Tx_Number*Rx_Number*Doppler_Number*Range_Number*2); %��������洢���ݵĿվ���

for i=1:1:Tx_Number*Rx_Number*Doppler_Number*Range_Number*2
    
    Data_zuhe(i) = Data_dec((i-1)*2+1)+Data_dec((i-1)*2+2)*256;%�����ֽ����һ�������ڶ����ֽڳ���256�൱������8λ��
    if(Data_zuhe(i)>32767)
        Data_zuhe(i) = Data_zuhe(i) - 65536;  %���Ʒ���
    end
    
end

%% �ַ�����
ADC_Data=zeros(Tx_Number,Doppler_Number,Rx_Number,Range_Number*2); %��������洢���ݵĿվ���

for t=1:1:Tx_Number
    for i=1:1:Doppler_Number
        for j=1:1:Rx_Number
            for k=1:1:Range_Number*2 %ʵ���鲿
                ADC_Data(t,i,j,k) = Data_zuhe(1,(((t-1)*Doppler_Number+(i-1))*Rx_Number+(j-1))*Range_Number*2+k);%ʱ����������˳��Ϊ TX1 TX2
            end
        end
    end
end

%% ��ӡȫ����ʵ������
Re_Data_All=zeros(1,Range_Number*Doppler_Number*Tx_Number*Rx_Number); %��������洢���ݵĿվ���
Im_Data_All=zeros(1,Range_Number*Doppler_Number*Tx_Number*Rx_Number); %��������洢���ݵĿվ���

% �鲿ʵ���ֽ�
for i=1:1:Tx_Number*Rx_Number*Doppler_Number*Range_Number
    Im_Data_All(1,i) = Data_zuhe(1,(i-1)*2+1);
    Re_Data_All(1,i) = Data_zuhe(1,(i-1)*2+2);
end

%%  ԭʼ�ź�ʵ�����鲿ͼ�λ��� 
figure()
subplot(2,1,1);
plot(Im_Data_All(1,1:3000));  title('�鲿����');
xlabel('��������');
ylabel('����');
subplot(2,1,2);
plot(Re_Data_All(1,1:3000),'r');title('ʵ������');
xlabel('��������');
ylabel('����');

%% ��ӡ������ʵ������ ���ݽṹΪ��2T4R��TX2���16����������
Re_Data=zeros(Doppler_Number,Range_Number); %��������洢���ݵĿվ���
Im_Data=zeros(Doppler_Number,Range_Number); %��������洢���ݵĿվ���

for chirp=1:Doppler_Number %�鿴����chirp������ 
% figure();
for j=1:1:Tx_Number
    for k=1:1:Rx_Number
        for i=1:1:Range_Number
            Re_Data(chirp,i) = ADC_Data(j,chirp,k,(i-1)*2+2);
            Im_Data(chirp,i) = ADC_Data(j,chirp,k,(i-1)*2+1);
        end
    end 
end
end

%% �鲿+ʵ����������õ����ź� 
ReIm_Data = complex(Re_Data,Im_Data); %����ֻ���������ߵ����һ�����ݡ�ԭ�����ݴ�СӦ����16*256*8=32768������ֻ��16*256*1=4096��
ReIm_Data_All =complex(Re_Data_All,Im_Data_All);

ReIm_Data_all1 = zeros(Range_Number,Doppler_Number,Rx_Number);
ReIm_Data_all2 = zeros(Range_Number,Doppler_Number,Rx_Number);

%% ������������ 4ͨ��->8ͨ��
for nn=1:Rx_Number
    for mm=1:Range_Number       
            ReIm_Data_all1(mm,:,nn) = ReIm_Data_All((nn-1)*Range_Number+ ((mm-1)*4*Range_Number+1):((mm-1)*4*Range_Number+Range_Number)+(nn-1)*Range_Number  );          
            ReIm_Data_all2(mm,:,nn) = ReIm_Data_All((nn-1)*Range_Number+131072/2+((mm-1)*4*Range_Number+1):131072/2+((mm-1)*4*Range_Number+Range_Number) +(nn-1)*Range_Number );
    end
end

ReIm_Data_All = cat(3,ReIm_Data_all1(:,:,1:Rx_Number), ReIm_Data_all2(:,:,1:Rx_Number));

%% 1D FFT
fft1d= zeros(Doppler_Number,Range_Number,Tx_Number*Rx_Number);
for qq =1:Tx_Number*Rx_Number
    for chirp_fft=1:Doppler_Number 
        fft1d(chirp_fft,:,qq) = fft((ReIm_Data_All(chirp_fft,:,qq)));
    end
end

FFT1_mag=abs(fft1d(:,:,1));
figure();
mesh(FFT1_mag);
xlabel('��������');ylabel('������');zlabel('����');
title('����άFFT���');

%%  mti ��Ŀ����ʾ
% fft1d_data = zeros(Range_Number,Doppler_Number,Tx_Number*Rx_Number);
% for cc =1:Tx_Number*Rx_Number
%     for ii =1:Doppler_Number-1
%         fft1d_data (ii,:,cc) = fft1d(ii+1,:,cc)-fft1d(ii,:,cc);
%     end
% end

%% ��̬�Ӳ��˳� ������ֵ����
fft1d_jingtai =zeros(Doppler_Number,Range_Number,Tx_Number*Rx_Number);
for n=1:Tx_Number*Rx_Number
    avg = sum(fft1d(:,:,n))/Doppler_Number;
    for chirp=1:Range_Number
        fft1d_jingtai(chirp,:,n) = fft1d(chirp,:,n)-avg;
    end
end
fft1d =fft1d_jingtai;

%% 2D FFT 
fft2d= zeros(Doppler_Number,Range_Number,Tx_Number*Rx_Number);
for kk=1:Tx_Number*Rx_Number
    for chirp_fft=1:Range_Number 
        fft2d(:,chirp_fft,kk) =fftshift( fft((fft1d(:,chirp_fft,kk))));  
    end
end

%% ֱ����������
fft2d(:,1,:)=0;

FFT2_mag=(abs(fft2d(:,:,1)));
figure();
mesh(X,Y,FFT2_mag);
xlabel('����ά(m)');ylabel('�ٶ�ά(m/s)');zlabel('����');
title('������ֵ������2D-FFT���');

%% �ٶ�ά CFAR
% %����1D CFAR ��ƽ����Ԫ���龯��
% %ȱ�㣺��Ŀ�����ڡ��Ӳ���Ե����Ƿ��
% %�ŵ㣺��ʧ����С
% %�ο���Ԫ��12
% %������Ԫ��2
% %�龯���ʣ�
% %����ֵ��

Tv=6;Pv=4;PFAv = 0.001; 
Tr=6;Pr=4;PFAr = 0.003;

dopplerDimCfarThresholdMap = zeros(size(FFT2_mag));  %����һ����ά������dopplerάcfar��Ľ��
dopplerDimCfarResultMap    = zeros(size(FFT2_mag));

for i=1:Range_Number
   dopplerDim =  reshape(FFT2_mag(:,i),1,Doppler_Number);       %���һ������
   [cfar1D_Arr,threshold] = ac_cfar1D(Tv,Pv,PFAv,dopplerDim);   %����1D cfar
   dopplerDimCfarResultMap(:,i) = cfar1D_Arr.'; 
   dopplerDimCfarThresholdMap(:,i) = threshold.';
end

%% ����ά CFAR
%����dopplerά�ȷ���Ѱ����dopplerάcfar�о���Ϊ1�Ľ��
saveMat = zeros(size(FFT2_mag));
for range = 1:Range_Number
    indexArr = find(dopplerDimCfarResultMap(:,range)==1);
    objDopplerArr = [indexArr;zeros(Doppler_Number - length(indexArr),1)];   %���䳤��
    saveMat(:,range) = objDopplerArr; %����doppler�±�
end
% �����������doppler����
objDopplerIndex = unique(saveMat);  % unqiue�ǲ��ظ��ķ��������е���

% ����֮ǰdopplerά��cfar�����Ӧ���±�saveMat������Ӧ���ٶȽ���rangeά�ȵ�CFAR
rangeDimCfarThresholdMap = zeros(size(FFT2_mag));  %����һ����ά������rangeάcfar��Ľ��
rangeDimCfarResultMap = zeros(size(FFT2_mag));
i = 1;
while(i<=length(objDopplerIndex))
    if(objDopplerIndex(i)==0)   % ��Ϊ����������0,��ֹ����jȡ��0
        i = i + 1;
        continue;
    else    %�����ٶ��±����range CFAR
        j = objDopplerIndex(i);     % ����������ڵ���
        rangeDim = reshape(FFT2_mag(j, :),1,Range_Number);  %���һ������
        % tip ���PFA���԰�,������õĵ�һЩ,�ڽ��з�֧�ۼ���ʱ��,���ܵĽ����û�м�⵽����
        % ��Ϊ�ڽ���rangeCFAR��ʱ��,�Ѹ��������ֵ���˵���,�������ڽ��з�ֵ�ۼ���ʱ��,�о������Ӧ�����ֵһֱ��С��
        
        [cfar1D_Avv,threshold] = ac_cfar1D(Tr,Pr,PFAr,rangeDim);  %����1D cfar
        rangeDimCfarResultMap(j,:) = cfar1D_Avv; 
        rangeDimCfarThresholdMap(j,:) = threshold;
        i = i + 1;   
    end
end

mesh(X,Y,(rangeDimCfarResultMap));
% view(2);
xlabel('����(m)');ylabel('�ٶ�(m/s)');zlabel('�źŷ�ֵ');
title('rangeCFAR֮���о����(��ֵ�ۼ�ǰ)');
xlim([0     Params.c*(Params.NSample-1)*Params.Fs/2/Params.freqSlope/Params.NSample]);
ylim([(-Params.NChirp/2)*Params.lambda/Params.Tc/Params.NChirp/2    (Params.NChirp/2 - 1)*Params.lambda/Params.Tc/Params.NChirp/2]);
   

%% ��Ŀ����� �Ƕ�ά FFT
[objDprIdx,objRagIdx] = peakFocus(rangeDimCfarResultMap);% ��ֵ���� ������ٶȵ�ID��

objDprIdx(objDprIdx==0)=[]; %ȥ�������0
objRagIdx(objRagIdx==0)=[];

%% ����Ŀ����롢�ٶȣ����
objSpeed = ( objDprIdx - Params.NChirp/2 - 1)*Params.lambda/Params.Tc/Params.NChirp/2;
objRange = single(Params.c*(objRagIdx-1)*Params.Fs/2/Params.freqSlope/Params.NSample);

%�����Ŀ������нǶ�FFT
if(~isempty(objDprIdx))
    angle =processingChain_angleFFT(objDprIdx,objRagIdx,fft2d);
   
    figure();
    plot(angle,objRange,'o')
    grid on;
    rlim = 8;
    axis([-90/rlim 90/rlim 0 1]*rlim);
    ylabel('���루m��');
    xlabel('�Ƕȣ��㣩') 
end

%% ���ܺ���
function [cfar1D_Arr,threshold] = ac_cfar1D(NTrain,NGuard,PFA,inputArr)
    cfar1D_Arr = zeros(size(inputArr));
    threshold = zeros(size(inputArr));

    totalNTrain = 2*(NTrain);
    a = totalNTrain*((PFA^(-1/totalNTrain))-1);
    %��ƽ��ֵ
    for i = NTrain+NGuard+1:length(inputArr)-NTrain-NGuard
        avg = mean([inputArr((i-NTrain-NGuard):(i-NGuard-1))   inputArr((i+NGuard+1):(i+NTrain+NGuard))]);
        threshold(1,i) = a.*avg;
        %����threshold�Ƚ�
        if(inputArr(i) < threshold(i))
            cfar1D_Arr(i) = 0;
        else
            cfar1D_Arr(i) = 1;
        end
    end
    
end

%% ���ܺ��� 
function [cfar1D_Arr,threshold] = ac_cfar2D(NTrain,NGuard,PFA,inputArr)
    cfar1D_Arr = zeros(size(inputArr));
    threshold = zeros(size(inputArr));

    totalNTrain = 2*(NTrain);
    a = totalNTrain*((PFA^(-1/totalNTrain))-1);
    %��ƽ��ֵ
    for i = NTrain+NGuard+1:length(inputArr)-NTrain-NGuard
        avg = mean([inputArr((i-NTrain-NGuard):(i-NGuard-1))   inputArr((i+NGuard+1):(i+NTrain+NGuard))]);
        threshold(1,i) = a.*avg;
        %����threshold�Ƚ�
        if(inputArr(i) < threshold(i))
            cfar1D_Arr(i) = 0;
        else
            cfar1D_Arr(i) = inputArr(i);
        end
    end
    
end
 % ����: inputCfarResMat - ���з�ֵ�۽��Ķ�ά����,������rangeάCFAR�о���õ��Ľ������
% ���: row - �����������(��Ӧ�ٶ�)
% column - �����������(��Ӧ����)
function [row,column] = peakFocus(inputCfarResMat)
    global FFT2_mag;
    j = 1;
    row = zeros([1 256]);
    column = zeros([1 256]);
    [d,r] = find(inputCfarResMat==1);   %Ѱ�ҽ���rangeάcfar����о�Ϊ1������
    for i = 1 : length(d)
        peakRow = d(i);
        peakColumn = r(i);
        peak = FFT2_mag(peakRow,peakColumn);  %����֤�ķ�ֵ
        % �ڸ�����3*3�����е������бȽ�,����м���������ֵ,���ж�Ϊ1  tip:����֪��������̫���ĺ���� �ѩҩn�ѩ�
        % �Ѹ�����8+1����ȡ����
        % ����֮ǰ���е�2��cfar,��Ϊ��TrainCell��GuardCell�����Բ���������Ե
        tempArr =[FFT2_mag(peakRow-1,peakColumn-1) , FFT2_mag(peakRow-1,peakColumn) ,  FFT2_mag(peakRow-1,peakColumn+1), ...
                  FFT2_mag(peakRow,peakColumn-1)   ,                     peak                             , FFT2_mag(peakRow,peakColumn+1), ...
                  FFT2_mag(peakRow+1,peakColumn-1) , FFT2_mag(peakRow+1,peakColumn) ,  FFT2_mag(peakRow+1,peakColumn+1)] ;    
        truePeak = max(tempArr);     % Ѱ�����ֵ
        if(truePeak == peak)         %����м�������ֵ�ͱ��浱ǰ������
            row(j) = peakRow;
            column(j) = peakColumn;
            j = j+1;
        end
    end
end

 function [sphandle] = configureDataSport(comPortString, bufferSize)
  
%     comPortString = ['COM' num2str(comPortNum)];
    sphandle = serial(comPortString,'BaudRate',921600);
%     set(sphandle,'Timeout',15);
    set(sphandle,'Terminator', '');
    set(sphandle,'InputBufferSize', bufferSize);
    set(sphandle,'Timeout',10);
    set(sphandle,'ErrorFcn',@dispError);
    fopen(sphandle);
 end
    
    function [sphandle] = configureControlPort(comPortString)
    %if ~isempty(instrfind('Type','serial'))
    %    disp('Serial port(s) already open. Re-initializing...');
    %    delete(instrfind('Type','serial'));  % delete open serial ports.
    %end
    %comPortString = ['COM' num2str(comPortNum)];
    sphandle = serial(comPortString,'BaudRate',115200);
    set(sphandle,'Parity','none')    
    set(sphandle,'Terminator','LF')        
    fopen(sphandle);
    end
    
    function config = readCfg(filename)  %��ȡ�����ļ�
    config = cell(1,100);
    fid = fopen(filename, 'r');
    if fid == -1
        fprintf('File %s not found!\n', filename);
        return;
    else
        fprintf('Opening configuration file %s ...\n', filename);
    end
    tline = fgetl(fid);
    k=1;
    while ischar(tline)
        config{k} = tline;
        tline = fgetl(fid);
        k = k + 1;
    end
    config = config(1:k-1);
    fclose(fid);
    end
    
    function [angle] = processingChain_angleFFT(objDprIndex,objRagIndex,fft2d)

    angleFFTNum = 512;
    NObject = length(objDprIndex);  %����������Ŀ,�㼣
  
    %��ʼ��һ����ά������FFT���
    angleFFTOut = single(zeros(NObject,angleFFTNum));
    for i=1:NObject
        
        %%
        frameData(1,:) = fft2d(objDprIndex(i),objRagIndex(i),:);       
        frameFFTData = fftshift(fft(frameData, angleFFTNum));      %����NChan���angler-FFT
                                                                   %fftshift�ƶ���Ƶ�㵽Ƶ���м�  ���Ǻܶ�
                                                                   %��+�� �� -��
        angleFFTOut(i,:) = frameFFTData(1,:);   %��FFT�Ľ������angleFFTOut
        plot(abs(angleFFTOut(i,:)));
        
        maxIndex= find(abs(angleFFTOut(i,:))==max(abs(angleFFTOut(i,:))));
        angle (i)= asin((maxIndex - angleFFTNum/2 - 1)*2/angleFFTNum) * 180/pi;
    end  
    end

    % ��Ƥ������
function [userport, dataport] = serial_port()

port =IdentifySerialComs();

user_flag = 1;
data_flag = 1;

for i = 1:length(port)
    if(user_flag)
        userportID = find(strcmp('XDS110 Class Application/User UART',  port(i,1)));        
        if(userportID)
            user_flag = 0;
            userport = port(i,2);
        end 
        
    end
    
    if(data_flag)     
        dataportID = find(strcmp('XDS110 Class Auxiliary Data Port',  port(i,1)));
        if(dataportID)
               data_flag = 0;
               dataport = port(i,2);
        end
    end  
end

userport = ['COM',num2str(cell2mat(userport))];
dataport = ['COM',num2str(cell2mat(dataport))];

end

function devices = IdentifySerialComs()

devices = [];

Skey = 'HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM';

[~, list] = dos(['REG QUERY ' Skey]);
if ischar(list) && strcmp('ERROR',list(1:5))  %% strcmp �����ַ�����ͬ����1
    disp('Error: EnumSerialComs - No SERIALCOMM registry entry')
    return;
end

list = strread(list,'%s','delimiter',' '); %#ok<FPARK> requires strread()
coms = 0;

for i = 1:numel(list)  %%numel ����Ԫ�ظ���
    if strcmp(list{i}(1:3),'COM')
        if ~iscell(coms)
            coms = list(i);
        else
            coms{end+1} = list{i}; %#ok<AGROW> Loop size is always small
        end
    end
end

out = 0;
outK = 0;

for j=1:2
    switch j
        case 1
            key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB\';
        case 2
            key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\FTDIBUS\';
    end
    [~, vals] = dos(['REG QUERY ' key ' /s /f "FriendlyName" /t "REG_SZ"']);
    if ischar(vals) && strcmp('ERROR',vals(1:5))
        disp('Error: EnumSerialComs - No Enumerated USB registry entry')
        return;
    end
    vals = textscan(vals,'%s','delimiter','\t');
    vals = cat(1,vals{:});
    for i = 1:numel(vals)
        if strcmp(vals{i}(1:min(12,end)),'FriendlyName')
            if ~iscell(out)
                out = vals(i);
            else
                out{end+1} = vals{i}; %#ok<AGROW> Loop size is always small
            end
            if ~iscell(outK)
                outK = vals(i-1);
            else
                outK{end+1} = vals{i-1}; %#ok<AGROW> Loop size is always small
            end
        end
    end
end

i_dev=1;Sservices=[];
for i = 1:numel(coms)
    match = strfind(out,[coms{i},')']);
    ind = 0;
    for j = 1:numel(match)
        if ~isempty(match{j})
            ind = j;
            [~, sers] = dos(['REG QUERY "' outK{ind} '" /f "Service" /t "REG_SZ"']);
            sers = textscan(sers,'%s','delimiter','\t');
            sers = cat(1,sers{:});
            if (numel(sers)>1)
                sers=strread(sers{2},'%s','delimiter',' ');
                Sservices{i_dev} = sers{3};
                i_dev=i_dev+1;
            end
        end
    end
end
Sservices=unique(Sservices);

i_dev=1;
for ss=1:numel(Sservices)
    key = ['HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\' Sservices{ss} '\Enum'];
    [~, vals] = dos(['REG QUERY ' key ' /f "Count"']);
    if ischar(vals) && strcmp('ERROR',vals(1:5))
        %         disp('Error: EnumSerialComs - No Enumerated services USB registry entry')
        %         return
    end
    vals = textscan(vals,'%s','delimiter','\t');
    vals = cat(1,vals{:});

    if (numel(vals)>1)
        vals=strread(vals{2},'%s','delimiter',' ');
        Count=hex2dec(vals{3}(3:end));
        if Count>0
            [~, vals] = dos(['REG QUERY ' key]);
            vals = textscan(vals,'%s','delimiter','\t');
            vals = cat(1,vals{:});
            out=0;
            j=0;
            for i = 1:numel(vals)
                Enums=strread(vals{i},'%s','delimiter',' ');
                try nums=hex2dec(Enums{1});
                catch
                    nums=-1;
                end
                if(nums==j)
                    out=['HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\' Enums{3}];
                    [~, listC] = dos(['REG QUERY "' out '" /s /f "PortName" /t "REG_SZ"']);
                    listC = textscan(listC,'%s','delimiter','\t');
                    listC = cat(1,listC{:});
                    if (numel(listC)>1)
                        listC=strread(listC{2},'%s','delimiter',' ');
                        for i = 1:numel(coms)
                            if strcmp(listC{3},coms{i})
                                [~, NameF] = dos(['REG QUERY "' out '" /s /f "FriendlyName" /t "REG_SZ"']);
                                NameF = textscan(NameF,'%s','delimiter','\t');
                                NameF = cat(1,NameF{:});
                                com = str2double(coms{i}(4:end));
                                if com > 9
                                    length = 8;
                                else
                                    length = 7;
                                end
                                devices{i_dev,1} = NameF{2}(27:end-length); %#ok<AGROW>
                                devices{i_dev,2} = com; %#ok<AGROW> Loop size is always small
                                i_dev=i_dev+1;
                            end
                        end
                    end
                    j=j+1;
                end
            end
        end
    end
end

end
