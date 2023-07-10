%%%%********   Echo Generator Simulation   *******%%%%%%%%
%    �������ɻ���SAR��Ŀ�꣬������������״̬

clear all;
clc;
close all
start_time=cputime;

%%  ϵͳ����
fc     =  9.65e9;      % ����
c      =  3e8;
lamda  =  c/fc;
PRF    =  2000;
B      =  150e6;      
Tp     =  1e-6;        %����Ϊ1΢��
Fs     =  300e6;       %����Ƶ��
K      =  B/Tp;
v      =  500;         %������ٶȡ�m/s


%%     �ز���ز���
%%%% ���������
ResR          =  c/B/2;       %������ֱ���
range_width   =  400;     %�����򳡾����
N             =  2*fix(Tp*Fs/2);                                    %������������Ĳ�������
drange        =  c/Fs;                                              %������������
R_g           =  5000;        %������켣�ڵ����ͶӰ���볡���������
H             =  10000;         %������߶�
R_near        =  (R_g^2+H^2)^0.5;                     %б��ƽ���ڣ��������뷢��ƽ̨�������
R_far         =  ((R_g+range_width)^2+H^2)^0.5;        %б��ƽ���ڣ��������뷢��ƽ̨��Զ����
R_mid         =  ((R_g+range_width/2)^2+H^2)^0.5;      %б��ƽ���ڣ��������뷢��ƽ̨���Ĳο�����
delta_RangeR  =  2*(R_far-R_near);

%%%% ��λ�����
azimuth_width  =  200;     %��λ�򳡾����
ResA           =  ResR;      %ȡ��λ��ֱ�����������൱
theta_T        =  lamda/ResA;                         %��������߷�λ�������              
Width_TranBeam =  2*R_mid*tan(theta_T/2);               %���䲨�����
Width_Azimuth  =  Width_TranBeam+azimuth_width;                 %�������
T_overlap      =  Width_Azimuth/v;                        %�������ǵ��ص�ʱ��
T0             =  1/PRF;             
t              =  -T_overlap /2:T0:T_overlap /2;                     %��λ��ʱ���������

%*************�ز���������*****************%
NumSam_Azimuth =   length(t);
NumSam_Range   =   2*fix(1.2*(delta_RangeR/drange/2+N/2));

Target         =   [0 0 0];%;0,0,0;
[Num_Target,Inf_Tar]=size(Target);

%%   Echo Generate Simulation   

tr         =     (2*R_mid+((0:NumSam_Range-1)-fix(NumSam_Range/2))*drange)/c;    %�������ʱ��
Data_Echo  =     zeros(NumSam_Azimuth,NumSam_Range);

Hwaitbar=waitbar(0,'�ز�����...');
for m=1:NumSam_Azimuth
    temp =  zeros(1,NumSam_Range);
    YT   =  v*t(m);                           %�������������λ��
    YTF  =  YT+Width_TranBeam/2;                  %���������ǰ��
    YTB  =  YT-Width_TranBeam/2;                  %�������������
    
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
% msgbox(['�ز�������ʱ ',num2str(cost_time),'s'],'�����ʱ','modal');

figure;imagesc(real(Data_Echo));colormap('gray');

%% ����ѹ��
%***********�����źŸ��ƺ󣬽���FFT,Ȼ��ȡ����***************%
N_ref = 2*fix(Tp*Fs/2);          % 300����
t_ref=([0:N_ref-1]-fix(N_ref/2))*drange/c;                 % 
ht=exp(-1j*pi*K*t_ref.^2);                                 %�ο��ź�ʱ��
HF=fft(ht,NumSam_Range);

%%% ���������ɾ���ѹ��
% HF_matrix = ones(NumSam_Azimuth,1)*HF;
% Rawsignal_shift=fftshift(fft(Data_Echo,[],2).*HF_matrix,2);

%%% for ѭ����ɾ���ѹ��
Rawsignal_shift=zeros(NumSam_Azimuth,NumSam_Range);
Hwaitbar=waitbar(0,'����ѹ��...');
for na=1:NumSam_Azimuth

    Rawsignal_shift(na,:)=fftshift(fft(Data_Echo(na,:),[],2).*HF,2);
    waitbar(na/NumSam_Azimuth);
    
end
close(Hwaitbar);                                           %�رջز��ļ��ͽ�����

Rawsignal_ifft=ifft(Rawsignal_shift,[],2);      %%%������IFF�ԣ��任����άʱ��    
figure;imagesc(abs(Rawsignal_ifft));        %%%��ʾ��άʱ��ͼ 

%% ��������У��
 fa   =   (([0:NumSam_Azimuth-1]-fix(NumSam_Azimuth/2))/NumSam_Azimuth*PRF);  % ��λ��Ƶ��
fr   =   ([0:NumSam_Range-1]-fix(NumSam_Range/2))/NumSam_Range*Fs;           % ������Ƶ��
faM  =   2*v/lamda;

Rawsignal_shift=fftshift(fft(Rawsignal_shift,[],1),1);      % ��λ��FFT���任����άƵ��
figure;imagesc(abs(Rawsignal_shift))       %��ʾ��άƵ��ͼ
%---------------------------------------------------------------
%%% ���������ɾ�������У��
% H_RCMC=exp(j*pi*R_mid/c*(fa.').^2*fr*lamda^2/(2*v^2));  
% Rawsignal_shift=Rawsignal_shift.*H_RCMC;

%% forѭ����ɾ�������У��
Hwaitbar=waitbar(0,'��������У��...');
for na=1:NumSam_Azimuth
    H_RCMC=exp(1i*pi*R_mid/c*(fa(na)^2).*fr*lamda^2/(2*v^2));
%     H_RCMC=exp(j*2*pi*R_mid/c*(fa(na)/faM)^2.*fr);
    Rawsignal_shift(na,:)=Rawsignal_shift(na,:).*H_RCMC;
    waitbar(na/NumSam_Azimuth);    
end
close(Hwaitbar);                                               %�رս�����

Rawsignal_shift=ifftshift(ifft(Rawsignal_shift,[],2),2);    %��ؾ����������                               
% Rawsignal_shift=ifft(Rawsignal_shift,[],2);        %��ؾ����������
% 
Rawsignal_shift1=ifft(Rawsignal_shift,[],1);   %��ض�άʱ��
figure;imagesc(abs(Rawsignal_shift1));        %%%��ʾ��άʱ��ͼ    

%% ��λѹ��
%***********�����źŸ��ƺ󣬽���FFT,Ȼ��ȡ����***************%
% K1=-2*v^2/lamda/R_mid;
% ht1=exp(-j*pi*K1*t.^2);                                                      %�ο��ź�ʱ��
% HF=fftshift(fft(ht1,NumSam_Azimuth));                                                       %�ο��ź�Ƶ��
HF_azimuth=exp(1i*2*pi*R_mid*sqrt(faM^2-fa.^2)/v);

%%% ���������ɷ�λѹ��
% azimuth_matrix = ones(NumSam_Range,1)*fa;
% HF_azimuth_martix=exp(j*2*pi*R_mid*(faM^2-azimuth_matrix.^2).^(0.5)/v);
% Rawsignal_shift=ifft(Rawsignal_shift.*(HF_azimuth_martix.'));              %��λ��ѹ��

% %%% forѭ����ɷ�λѹ��
Hwaitbar=waitbar(0,'��λѹ��...');
for na=1:NumSam_Range
    Rawsignal_shift(:,na)=ifft(Rawsignal_shift(:,na).*(HF_azimuth.'));              %��λ��ѹ��
    waitbar(na/NumSam_Range);
end
close(Hwaitbar);                                           %�رջز��ļ��ͽ�����

max_image=max(max(abs(Rawsignal_shift)));
DB_Image=20*log10(abs(Rawsignal_shift)/max_image);
index=find(DB_Image<-40);DB_Image(index)=-40;
figure;imagesc(DB_Image);
figure;contour(DB_Image);

%% �ο����ĵ�Ŀ��
[max_row,max_col]=find(max_image == abs(Rawsignal_shift));
Sa=abs(Rawsignal_shift(:,max_col)');
Saa=interpft(Sa,length(Sa)*8);
DB_Saa=20*log10(abs(Saa)/max(abs(Saa)));
figure;plot(DB_Saa);grid on
% figure;plot(Y_eight_times,DB_Saa);grid on
xlabel('��λ��');ylabel('����(dB)');
Sr=abs(Rawsignal_shift(max_row,:));
Srr=interpft(Sr,length(Sr)*8);
DB_Srr=20*log10(abs(Srr)/max(abs(Srr)));
figure;plot(DB_Srr);grid on
% figure;plot(X_eight_times,DB_Srr);grid on
xlabel('������');ylabel('����(dB)');



%%  ����ֱ���
% max_Saa=max(Saa);
% Index_A=mean(find(Saa==max_Saa));
% TL=[Index_A-200:Index_A];
% TR=[Index_A:Index_A+200];
% AzimL=interp1(Saa(TL),TL,0.707*max_Saa);  
% AzimR=interp1(Saa(TR),TR,0.707*max_Saa);  
% Res_A=(AzimR-AzimL)*dazimuth/8/0.886                      %��λ��ֱ���

max_Srr=max(Srr);
Index_R=mean(find(Srr==max_Srr));
TL=[Index_R-200:Index_R];
TR=[Index_R:Index_R+200];
RangeL=interp1(Srr(TL),TL,0.707*max_Srr);  
RangeR=interp1(Srr(TR),TR,0.707*max_Srr);  
Res_R=(RangeR-RangeL)*drange/8/2/0.886                      %������ֱ���

cost_time=cputime-start_time;
msgbox(['�����ʱ ',num2str(cost_time),'s'],'�����ʱ','modal');




