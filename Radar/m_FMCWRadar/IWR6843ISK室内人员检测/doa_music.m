
function [angel] = doa_music(X)
global S_MUSIC1;
derad = pi/180;        %角度->弧度
D = 8;                 % 阵元个数        
M = 1;                 % 信源数目
snr = 40;              % 信噪比
K = 96;                % 快拍数
dd = 0.004;            % 阵元间距 
d=0:dd:(D-1)*dd;
Distance =0.5;

% 计算协方差矩阵
Rxx=X*X'/K;

% 特征值分解
[V,EVA]=eig(Rxx);   %特征值分解，D为特征值矩阵

EVA1=diag(EVA);
[EVA1,I]=sort(EVA1,'descend');   %将特征值按照由大到小的顺序排列
V=V(:,I);     %对应地，将特征向量调整

P_N=zeros(D,D);  %噪声相关矩阵

for i=M+1:D
    P_N=P_N+V(:,i)*V(:,i)';
end        
 
%% 谱峰搜索
length=180/Distance+1;
S_MUSIC=zeros(1,length);
k=1;


d_lamda=1/2;

for i=-90:Distance:90
    theta1=deg2rad(i);
    A_theta=exp(-1i*2*pi*sin(theta1)*d_lamda*(0:1:D-1));
    S_MUSIC(k)=1/(A_theta*P_N*A_theta');
    k=k+1;
end


%对S_MUSIC做归一化处理
S_max=max(abs(S_MUSIC));
S_MUSIC=(S_MUSIC/S_max);
% S_MUSIC1 = S_MUSIC1+ S_MUSIC;

% S_MUSIC1_max =max(S_MUSIC1);
% S_MUSIC1 = S_MUSIC1/S_MUSIC1_max;

% figure(2)
% plot(-90:Distance:90,S_MUSIC1)
% axis([-90,90,-85,5])
% % title({['谱峰搜索'];['信号源入射角(deg)：',num2str(angle)];['快拍数：',num2str(N),'    信噪比：',num2str(SNR),'dB   谱峰搜索分辨率：',num2str(Distance),'deg']})
% xlabel('方位角/degree')
% ylabel('功率谱/dB')
% grid on
% 
% findpeaks(abs(S_MUSIC1));

agnel_index = -90:Distance:90;
[value,index]=max(S_MUSIC);
angel  =agnel_index( index);

%%


end
