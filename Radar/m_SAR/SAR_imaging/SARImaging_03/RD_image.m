%%%%********   Echo Generator Simulation   *******%%%%%%%%
%    仿真生成机载SAR点目标，工作在正侧视状态

clear all;
clc;
close all
start_time=cputime;

%%  系统参数
fc     =  9.65e9;      % 波段
c      =  3e8;
lamda  =  c/fc;
PRF    =  2000;
B      =  150e6;      
Tp     =  1e-6;        %脉宽为1微秒
Fs     =  300e6;       %采样频率
K      =  B/Tp;
v      =  500;         %发射机速度　m/s


%%     回波相关参数
%%%% 距离向参数
ResR          =  c/B/2;       %距离向分辨率
range_width   =  400;     %距离向场景宽度
N             =  2*fix(Tp*Fs/2);                                    %单个脉冲包含的采样点数
drange        =  c/Fs;                                              %距离向采样间隔
R_g           =  5000;        %发射机轨迹在地面的投影距离场景最近距离
H             =  10000;         %发射机高度
R_near        =  (R_g^2+H^2)^0.5;                     %斜距平面内，场景距离发射平台最近距离
R_far         =  ((R_g+range_width)^2+H^2)^0.5;        %斜距平面内，场景距离发射平台最远距离
R_mid         =  ((R_g+range_width/2)^2+H^2)^0.5;      %斜距平面内，场景距离发射平台中心参考距离
delta_RangeR  =  2*(R_far-R_near);

%%%% 方位向参数
azimuth_width  =  200;     %方位向场景宽度
ResA           =  ResR;      %取方位向分辨率与距离向相当
theta_T        =  lamda/ResA;                         %发射机天线方位向波束宽度              
Width_TranBeam =  2*R_mid*tan(theta_T/2);               %发射波束宽度
Width_Azimuth  =  Width_TranBeam+azimuth_width;                 %场景宽度
T_overlap      =  Width_Azimuth/v;                        %波束覆盖的重叠时间
T0             =  1/PRF;             
t              =  -T_overlap /2:T0:T_overlap /2;                     %方位向时间采样序列

%*************回波数据区域*****************%
NumSam_Azimuth =   length(t);
NumSam_Range   =   2*fix(1.2*(delta_RangeR/drange/2+N/2));

Target         =   [0 0 0];%;0,0,0;
[Num_Target,Inf_Tar]=size(Target);

%%   Echo Generate Simulation   

tr         =     (2*R_mid+((0:NumSam_Range-1)-fix(NumSam_Range/2))*drange)/c;    %距离向快时间
Data_Echo  =     zeros(NumSam_Azimuth,NumSam_Range);

Hwaitbar=waitbar(0,'回波生成...');
for m=1:NumSam_Azimuth
    temp =  zeros(1,NumSam_Range);
    YT   =  v*t(m);                           %发射机波束中心位置
    YTF  =  YT+Width_TranBeam/2;                  %发射机波束前沿
    YTB  =  YT-Width_TranBeam/2;                  %发射机波束后沿
    
    for n=1:1:Num_Target
        XP=Target(n,1)+R_g+range_width/2;YP=Target(n,2);ZP=Target(n,3);
        if(YP<YTF)&&(YP>YTB)
            SR=sqrt(XP^2+(H-ZP)^2+(YP-YT)^2);
            temp=temp+exp(1i*pi*K*(tr-2*SR/c).^2).*exp(-1i*4*pi*SR/lamda).*(abs(tr-2*SR/c)<Tp/2);
        end
    end
   
    Data_Echo(m,:)=temp;
    waitbar(m/NumSam_Azimuth);  
end
close(Hwaitbar);
% cost_time=cputime-start_time;
% msgbox(['回波产生耗时 ',num2str(cost_time),'s'],'运算耗时','modal');

figure;imagesc(real(Data_Echo));colormap('gray');

%% 距离压缩
%***********发射信号复制后，进行FFT,然后取共轭***************%
N_ref = 2*fix(Tp*Fs/2);          % 300个点
t_ref=([0:N_ref-1]-fix(N_ref/2))*drange/c;                 % 
ht=exp(-1j*pi*K*t_ref.^2);                                 %参考信号时间
HF=fft(ht,NumSam_Range);

%%% 矩阵相乘完成距离压缩
% HF_matrix = ones(NumSam_Azimuth,1)*HF;
% Rawsignal_shift=fftshift(fft(Data_Echo,[],2).*HF_matrix,2);

%%% for 循环完成距离压缩
Rawsignal_shift=zeros(NumSam_Azimuth,NumSam_Range);
Hwaitbar=waitbar(0,'距离压缩...');
for na=1:NumSam_Azimuth

    Rawsignal_shift(na,:)=fftshift(fft(Data_Echo(na,:),[],2).*HF,2);
    waitbar(na/NumSam_Azimuth);
    
end
close(Hwaitbar);                                           %关闭回波文件和进度条

Rawsignal_ifft=ifft(Rawsignal_shift,[],2);      %%%距离向IFFＴ，变换到二维时域    
figure;imagesc(abs(Rawsignal_ifft));        %%%显示二维时域图 

%% 距离弯曲校正
 fa   =   (([0:NumSam_Azimuth-1]-fix(NumSam_Azimuth/2))/NumSam_Azimuth*PRF);  % 方位向频率
fr   =   ([0:NumSam_Range-1]-fix(NumSam_Range/2))/NumSam_Range*Fs;           % 距离向频率
faM  =   2*v/lamda;

Rawsignal_shift=fftshift(fft(Rawsignal_shift,[],1),1);      % 方位向FFT，变换到二维频域
figure;imagesc(abs(Rawsignal_shift))       %显示二维频谱图
%---------------------------------------------------------------
%%% 矩阵相乘完成距离弯曲校正
% H_RCMC=exp(j*pi*R_mid/c*(fa.').^2*fr*lamda^2/(2*v^2));  
% Rawsignal_shift=Rawsignal_shift.*H_RCMC;

%% for循环完成距离弯曲校正
Hwaitbar=waitbar(0,'距离弯曲校正...');
for na=1:NumSam_Azimuth
    H_RCMC=exp(1i*pi*R_mid/c*(fa(na)^2).*fr*lamda^2/(2*v^2));
%     H_RCMC=exp(j*2*pi*R_mid/c*(fa(na)/faM)^2.*fr);
    Rawsignal_shift(na,:)=Rawsignal_shift(na,:).*H_RCMC;
    waitbar(na/NumSam_Azimuth);    
end
close(Hwaitbar);                                               %关闭进度条

Rawsignal_shift=ifftshift(ifft(Rawsignal_shift,[],2),2);    %变回距离多谱勒域                               
% Rawsignal_shift=ifft(Rawsignal_shift,[],2);        %变回距离多谱勒域
% 
Rawsignal_shift1=ifft(Rawsignal_shift,[],1);   %变回二维时域
figure;imagesc(abs(Rawsignal_shift1));        %%%显示二维时域图    

%% 方位压缩
%***********发射信号复制后，进行FFT,然后取共轭***************%
% K1=-2*v^2/lamda/R_mid;
% ht1=exp(-j*pi*K1*t.^2);                                                      %参考信号时间
% HF=fftshift(fft(ht1,NumSam_Azimuth));                                                       %参考信号频谱
HF_azimuth=exp(1i*2*pi*R_mid*sqrt(faM^2-fa.^2)/v);

%%% 矩阵相乘完成方位压缩
% azimuth_matrix = ones(NumSam_Range,1)*fa;
% HF_azimuth_martix=exp(j*2*pi*R_mid*(faM^2-azimuth_matrix.^2).^(0.5)/v);
% Rawsignal_shift=ifft(Rawsignal_shift.*(HF_azimuth_martix.'));              %方位向压缩

% %%% for循环完成方位压缩
Hwaitbar=waitbar(0,'方位压缩...');
for na=1:NumSam_Range
    Rawsignal_shift(:,na)=ifft(Rawsignal_shift(:,na).*(HF_azimuth.'));              %方位向压缩
    waitbar(na/NumSam_Range);
end
close(Hwaitbar);                                           %关闭回波文件和进度条

max_image=max(max(abs(Rawsignal_shift)));
DB_Image=20*log10(abs(Rawsignal_shift)/max_image);
index=find(DB_Image<-40);DB_Image(index)=-40;
figure;imagesc(DB_Image);
figure;contour(DB_Image);

%% 参考中心点目标
[max_row,max_col]=find(max_image == abs(Rawsignal_shift));
Sa=abs(Rawsignal_shift(:,max_col)');
Saa=interpft(Sa,length(Sa)*8);
DB_Saa=20*log10(abs(Saa)/max(abs(Saa)));
figure;plot(DB_Saa);grid on
% figure;plot(Y_eight_times,DB_Saa);grid on
xlabel('方位向');ylabel('幅度(dB)');
Sr=abs(Rawsignal_shift(max_row,:));
Srr=interpft(Sr,length(Sr)*8);
DB_Srr=20*log10(abs(Srr)/max(abs(Srr)));
figure;plot(DB_Srr);grid on
% figure;plot(X_eight_times,DB_Srr);grid on
xlabel('距离向');ylabel('幅度(dB)');



%%  计算分辨率
% max_Saa=max(Saa);
% Index_A=mean(find(Saa==max_Saa));
% TL=[Index_A-200:Index_A];
% TR=[Index_A:Index_A+200];
% AzimL=interp1(Saa(TL),TL,0.707*max_Saa);  
% AzimR=interp1(Saa(TR),TR,0.707*max_Saa);  
% Res_A=(AzimR-AzimL)*dazimuth/8/0.886                      %方位向分辨率

max_Srr=max(Srr);
Index_R=mean(find(Srr==max_Srr));
TL=[Index_R-200:Index_R];
TR=[Index_R:Index_R+200];
RangeL=interp1(Srr(TL),TL,0.707*max_Srr);  
RangeR=interp1(Srr(TR),TR,0.707*max_Srr);  
Res_R=(RangeR-RangeL)*drange/8/2/0.886                      %距离向分辨率

cost_time=cputime-start_time;
msgbox(['成像耗时 ',num2str(cost_time),'s'],'运算耗时','modal');




