%2016/11/8
%Liu Yakun

clc,clear,close all;
C = 3e8;%����
lambda = 0.03;            %�����źŲ���
fc = C / lambda;          %�����ź�����Ƶ��
v = 200;%�״�ƽ̨�ٶ�
% h = 5000;
D = 5;%���߳���
theta = 15 / 180 * pi;%б�ӽ�
beta = lambda / D;%�������
yc = 41.7e3;%��������б��
xc = yc * tan(theta);%���״ﲨ�����Ĵ�Խ�������ĵ�ʱ�״�����Ϊ��0��0���㣬�������ĵ�ķ�λ������

wa = 100;%��λ����
wr = 100;%��������
xmin = xc - wa/2;%��λ��߽��
xmax = xc + wa/2;%��λ��߽��
ymin = yc - wr/2;%������߽��
ymax = yc + wr/2;%������߽��

rnear = ymin/cos(theta-beta/2);%���б��
rfar = ymax/cos(theta+beta/2);%��Զб��
rmid = (rnear + rfar) / 2;
a = 0.7;
b = 0.6;

targets = [xc + a*wa/2,yc + b*wr/2
           xc + a*wa/2,yc - b*wr/2
           xc - a*wa/2,yc + b*wr/2
           xc - a*wa/2,yc - b*wr/2
           xc         ,yc         ];


xbegin = xc - wa/2 - ymax*tan(theta+beta/2);%��ʼ���䳡���ķ�λ������
xend = xc + wa/2 - ymin*tan(theta - beta/2);%��������ʱ�ķ�λ������
xmid = (xbegin + xend) / 2;
ka = -2*v^2*cos(theta)^3/lambda/yc;%��λ���Ƶ��
% lsar = beta * yc / cos(theta);%�ϳɿ׾���
lsar = yc * (tan(theta + beta/2) - tan(theta - beta/2));%�ϳɿ׾���
tsar = lsar/v;%�ϳɿ׾�ʱ��
ba = abs(ka * tsar);%������Ƶ��
tr = 2e-6;%�������ʱ��
br = 50e6;%�������
kr = br / tr;%�������Ƶ��

% PRFmin = ba + 2*v*br*sin(theta)/C;
% PRFmax = 1/(2*tr+2*(rfar-rnear)/C);
% PRF = round(1.3 * ba);
% fs = round(1.2 * br);
alpha_slow = 1.3;%��λ���������
alpha_fast = 1.2;%�����������ϵ��
PRF = round(alpha_slow * ba);%��Ƶ
PRT = 1 / PRF;%�����ظ�����
Fs = alpha_fast * br;%�����������
Ts = 1 / Fs;%������������
Na = round((xend - xbegin)/v/PRT);%��λ���������
Na = 2^nextpow2(Na);%Ϊ��fft�����µ���
Nr = round((tr + 2*(rfar-rnear)/C)/Ts);%�������������
Nr = 2^nextpow2(Nr);%Ϊ��fft�����µ���
% PRF = Na / ((xend - xbegin)/v);
% fs = Nr / (tr + 2*(rfar-rnear)/C);
% tslow = linspace(xbegin/v,xend/v,Na);
ts = [-Na/2:Na/2 - 1]*PRT;%��λ����ʱ������
tf = [-Nr/2:Nr/2 - 1]*Ts + 2*rmid/C;%�����������
range = tf*C/2;%������




ntargets = size(targets,1);%��Ŀ�����
echo = zeros(Na,Nr);%��ʼ����Ŀ��
for i = 1:ntargets
    xi = targets(i,1);%��λ������
    yi = targets(i,2);%����������
    tci = ((xi - xc) - (yi - yc)*tan(theta)) / v;%�������Ĵ�Խʱ��
    rci = yi / cos(theta);%�������Ĵ�Խʱ��˲ʱб��
%     tsi = rci*(cos(theta)*tan(theta + beta/2) - sin(theta))/v;%������ʼ�����벨����������ʱ�̵ķ�λ��ʱ���
    tsi = yi * (tan(theta + beta/2 - tan(theta))) / v;
%     tei = rci*(sin(theta) - cos(theta)*tan(theta - beta/2))/v;%�������������벨����������ʱ�̵ķ�λ��ʱ���
    tei = yi * (tan(theta) - tan(theta - beta/2)) / v;
    ri = sqrt(yi^2 + (xi - v*ts).^2);%����ʱ���ڵ�˲ʱб��
    tau = 2 * ri / C;%��ʱ
    t = ones(Na,1)*tf - tau.'*ones(1,Nr);%t-tau����
    phase = pi*kr*t.^2 - 4*pi/lambda*(ri.'*ones(1,Nr));%��λ
    
    echo = echo + exp(1i*phase).* (abs(t)<tr/2) .* ((ts > (tci - tsi) & ts < (tci + tei))' * ones(1,Nr));
    
end
 
%%%%%%%%%%%%%%%%%%%Range Compression %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f_range = [-Nr/2:Nr/2-1]/Nr*Fs;
H_range = exp(1i*pi*f_range.^2/kr) .* kaiser(Nr,2.5)';
signal_comp = ifty(fty(echo) .* (ones(Na,1) * H_range));
