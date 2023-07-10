clear;close all;clc;
%% 定义参数
j=sqrt(-1);
R_nc = 20e3;                % 景中心斜距
Vr = 250;                   % 雷达有效速度
Tr = 2.5e-6;                % 发射脉冲时宽
Kr = 20e12;                 % 距离调频率
f0 = 5.3e9;                 % 雷达工作频率
BW_dop = 443;               % 多普勒带宽
Fr = 60e6;                  % 距离采样率
Fa = 600;                   % 方位采样率
Naz = 4096;                 % 距离线数（即数据矩阵，行数）——这里修改为1024。
Nrg = 320;                  % 距离线采样点数（即数据矩阵，列数）
sita_r_c = (0*pi)/180;	    % 波束斜视角，0 度，这里转换为弧度
c = 3e8;                    % 光速
R0 = R_nc*cos(sita_r_c);	% 与R_nc相对应的最近斜距，记为R0
Nr = Tr*Fr;                 % 线性调频信号采样点数
BW_range = Kr*Tr;           % 距离向带宽
lamda = c/f0;               % 波长
fnc = 2*Vr*sin(sita_r_c)/lamda;             % 多普勒中心频率，根据公式（4.33）计算。
La_real = 0.886*2*Vr*cos(sita_r_c)/BW_dop;  % 方位向天线长度，根据公式（4.36）
beta_bw = 0.886*lamda/La_real;              % 雷达3dB波束     
La = 0.886*R_nc*lamda/La_real;              % 合成孔径长度
a_sr = Fr / BW_range;       % 距离向过采样因子
a_sa = Fa / BW_dop;         % 方位向过采样因子
%% 点目标位置
delta_R0 = 0;       % 将目标1的波束中心穿越时刻，定义为方位向时间零点。
delta_R1 = 120; 	% 目标1和目标2的方位向距离差，120m
delta_R2 = 50;      % 目标2和目标3的距离向距离差，50m
targetNum=3;
% 目标1
x1 = R0;                            % 目标1的距离向距离
y1 = delta_R0 + x1*tan(sita_r_c);	% 目标1的方位向距离
% 目标2
x2 = x1;                            % 目标2和目标1的距离向距离相同
y2 = y1 + delta_R1;                 % 目标2的方位向距离
% 目标3
x3 = x2 + delta_R2;                 % 目标3和目标2有距离向的距离差，为delta_R2
y3 = y2 + delta_R2*tan(sita_r_c);  	% 目标3的方位向距离
x_range = [x1,x2,x3];
y_azimuth = [y1,y2,y3];
% 计算三个目标各自的波束中心穿越时刻
nc_1 = (y1-x1*tan(sita_r_c))/Vr;    % 目标1的波束中心穿越时刻。
nc_2 = (y2-x2*tan(sita_r_c))/Vr;    % 目标2的波束中心穿越时刻。
nc_3 = (y3-x3*tan(sita_r_c))/Vr;    % 目标3的波束中心穿越时刻。
nc_target = [nc_1,nc_2,nc_3];       % 定义该数组，便于处理。
%%  距离（方位）向时间，频率相关定义
tr = 2*x1/c + ( -Nrg/2 : (Nrg/2-1) )/Fr;                % Range
ta = ( -Naz/2: Naz/2-1 )/Fa;                            % Azimuth
% matrix
tr_mtx = ones(Naz,1)*tr;    % 距离时间轴矩阵，大小：Naz*Nrg
ta_mtx = ta.'*ones(1,Nrg);  % 方位时间轴矩阵，大小：Naz*Nrg
%% echo
echo = zeros(Naz,Nrg);    % 用来存放生成的回波数据
Amp = abs(randn(targetNum));                     % 目标回波幅度，都设置为1.
for k = 1:3                % 生成k个目标的原始回波数据
    R_n = sqrt( (x_range(k).*ones(Naz,Nrg)).^2 + (Vr.*ta_mtx-y_azimuth(k).*ones(Naz,Nrg)).^2 );% 目标k的瞬时斜距
    w_range = ((abs(tr_mtx-2.*R_n./c)) <= ((Tr/2).*ones(Naz,Nrg)));     % 距离向包络，即距离窗
    w_azimuth = (abs(ta - nc_target(k)) <= (La/2)/Vr).'*ones(1,Nrg);    % 方位向包络
    echo =echo+ w_range.*w_azimuth.*exp(-(1j*4*pi*f0).*R_n./c).*exp((1j*pi*Kr).*(tr_mtx-2.*R_n./c).^2);  
end
figure;imagesc(abs(echo));title('幅度');
xlabel('距离时域（采样点）');ylabel('方位时域（采样点）');
%% 距离压缩
S0_rc = fft(echo,Nrg,2);                    % 进行距离向傅里叶变换，零频在两端。
fr0=ifftshift((-Nrg/2:Nrg/2-1)/Nrg*Fr);     % 频率轴                                        %奈奎斯特特采样率
Hf_rc_1=exp(j*pi*(ones(Naz,1)*fr0).^2/Kr);  % 匹配滤波器          
S_rc_1=S0_rc.*Hf_rc_1;                      % 时域卷积
s_rc = ifft(S_rc_1,[],2);                   % 变回时域
figure;imagesc(abs(s_rc));title('距离压缩后时域幅度');
%% 变换到距离多普勒域，进行距离徙动校正
s_rc = s_rc.*exp(-1j*2*pi*fnc.*(ta.'*ones(1,Nrg)));    % 数据搬移
S_rd = fft(s_rc,Naz,1);                                % 距离多普勒域
fa = fnc + fftshift(-Naz/2:Naz/2-1)/Naz*Fa;            % 频率轴
R0_RCMC = (c/2).*tr*cos(sita_r_c);                     % 随距离线变化的R0，记为R0_RCMC，用来计算RCM和Ka。
delta_Rrd_fn = lamda^2.*((fa.').^2)*(R0_RCMC)/(8*Vr^2);% 公式6.11
R_solution = c/(2*Fr);                                 % 一个距离采样单元
delta_Rrd_fn_num = delta_Rrd_fn./R_solution;           % RCM对应的距离采样单元数
L = 8;                                                 % sinc插值核长度
S_rd_rcmc = zeros(Naz,Nrg);                            % 用来存放RCMC后的值
wait = waitbar(0,'距离徙动较正');
for p = 1 : Naz
    for q = L : Nrg-L*2                                % 没有考虑边缘的插值问题     
        numRCMC = delta_Rrd_fn_num(p,q);
        pos = round(q + numRCMC);                      % ceil，向上取整。     
        h = sinc_interpolate(pos,L);
        rcmc_S_rd= S_rd(p,pos-L/2+1:pos+L/2).';            
        S_rd_rcmc(p,q) =  h*rcmc_S_rd ;                % 加权求和
    end
   text2=sprintf('sinc核插值中（RCMC）:%d',ceil(p*100/ Naz));
   waitbar(p/Naz,wait,[text2 '%']);
end
delete(wait);
%% 距离多普勒域RCMC前后
figure;
subplot(1,2,1);imagesc(abs(S_rd));
xlabel('距离时域（采样点）');ylabel('方位频域（采样点）');title('距离多普勒域');  
subplot(1,2,2);imagesc(abs(S_rd_rcmc));
xlabel('距离时域（采样点）');ylabel('方位频域（采样点）');title('RCMC后距离多普勒域');      
%% 方位压缩
fa_azimuth_MF = fa;                                 % 方位频率轴，采用和RCMC中所用的频率轴相同。
Ka = 2*Vr^2*(cos(sita_r_c))^3./(lamda.* R0_RCMC);  	% 方位向调频率，是随最近斜距R0变化的。
Haz = exp( -1j*pi.*(((fa).').^2./Ka) );          	% 方位向匹配滤波器
S_rd_c = S_rd_rcmc.*Haz;                            % 乘以匹配滤波器
s_ac = ifft(S_rd_c,[],1);       	                % 完成方位压缩，变到图像域。结束。
%% 成像结果
figure;imagesc(abs(s_ac));title('点目标成像');  
xlabel('距离时域（采样点）');ylabel('方位时域（采样点）');

%% 插值系数生成函数
function h=sinc_interpolate(offset,L)
% offset是实际的距离徙动量，eg：11.7.
% sinc中心应该在11.7位置 ，参见合成孔径雷达成像算法与实现第二章的sinc插值部分
% 然后在offset左右两边各选择 L/2各点
% L为插值长度，是偶数
if mod(L,2)~=0
   fprintf('插值长度应为偶数！\n'); 
end
pos=floor(offset);                %将距离徙动量向下取整
x=pos-(L/2-1):pos+L/2;            %选择左右的插值点
x=x-offset;                       %将函数移到offset中心
h=sinc(x)./sum(sinc(x));          %归一化系数值
end

