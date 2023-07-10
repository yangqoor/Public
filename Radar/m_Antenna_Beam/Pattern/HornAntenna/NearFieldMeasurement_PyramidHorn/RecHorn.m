%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 此文件为角锥喇叭理论E面、H面方向图
%
% E面方向图：做出考虑波形因子和不考虑情况下的对比图
% 扫描角度： -60到+60度
% 参考文献：魏文元，宫德明，天线原理[M]. 国防工业出版社, 1985.
% 17/1/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear
close all
%% %%%%%%%%%%%%    定义角锥喇叭结构参数      %%%%%%%%%%%%%%%%%%%%%%%
a = 23*10.^(-3);  %波导输入端宽度 m（H面）
b = 10*10.^(-3);  %波导输入端宽度 m（E面）
D1 = 238*10.^(-3);%角锥口径宽度 m（H面）
D2 = 176*10.^(-3);%角锥口径宽度 m（E面）
h = 465*10.^(-3); %角锥喇叭长度


%% %%%%%%%%%%%%%%      定义工作参数  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = 9.375*10.^9;         %工作频率 Hz
lamd = 3*10.^8/f;        %工作波长 m
k  = 2*pi/lamd;          %波常数  rad/m
R1 = h/(1-a/D1);         %H面喇叭虚顶点到口径中心距离 
R2 = h/(1-b/D2);         %E面喇叭虚顶点到口径中心距离 
theta1 = -60:0.2:60;     %观测范围
theta  = theta1.*pi/180; %角度转化为弧度

%% %%%%%%%%%%%%%%   H面方向图作图     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = 0.5*sqrt(lamd*R1/2)*exp( 1i*(pi/4)*lamd*R1*(1/D1 + 2*sin(theta)/lamd).^2 ); 
N = 0.5*sqrt(lamd*R1/2)*exp( 1i*(pi/4)*lamd*R1*(1/D1 - 2*sin(theta)/lamd).^2 );
v1 = 0.707*(sqrt(lamd*R1)*(1/D1 + 2*sin(theta)/lamd) + D1/sqrt(lamd*R1));  
v2 = 0.707*(sqrt(lamd*R1)*(1/D1 + 2*sin(theta)/lamd) - D1/sqrt(lamd*R1));
v3 = 0.707*(sqrt(lamd*R1)*(1/D1 - 2*sin(theta)/lamd) + D1/sqrt(lamd*R1));
v4 = 0.707*(sqrt(lamd*R1)*(1/D1 - 2*sin(theta)/lamd) - D1/sqrt(lamd*R1));  
%%一个符号错误就导致完全错误！认真检查

FH = (1+cos(theta)).*(M.*Fresnel(v1,v2) + N.*Fresnel(v3,v4));  %方向图函数

FH_M=abs(FH);         %取模值
FH_1=FH_M./max(FH_M); %归一化
% FH_1=FH_M./1; %归一化
FHdB=20*log10(FH_1);  %采用分贝形式
% FHdB=FH_1;

figure(1)
hold on
plot(theta1,FHdB,'b','LineWidth',1.5);
%plot(t,FHA,'--r','LineWidth',1.6);  % %需要比较实测去掉注释 并已经在变量空间加载实测值
%legend('理论H方向图','实测H方向图');
grid on
title('角锥喇叭H面方向图(理论实测比较)','FontName','华文隶书',...
      'FontWeight','Bold','FontSize',16)
xlabel('\bf角度θ   单位：度','FontSize',15);
ylabel('\bff(θ)    单位：dB','FontSize',15);

%% %%%%%%%%%%%%%%   E面方向图作图     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

G =sqrt(1-((lamd/(2*a))^2)); %波形因子
lamdg=lamd/G;

for n=1:2   %循环做出波导波长近似为空气波长 和无近似的方向图比较
    if n==2
        lamdg=lamd;
        G=1;
    end

    v5 = 0.707*(sqrt(lamdg*R2).*(2*sin(theta)/lamd) + D2/sqrt(lamdg*R2));
    v6 = 0.707*(sqrt(lamdg*R2).*(2*sin(theta)/lamd) - D2/sqrt(lamdg*R2));

    FE=(1+G*cos(theta)).*Fresnel(v5,v6); %方向图函数
    FEM=abs(FE);        %取模值
    FE1=FEM./max(FEM);  %归一化
    FEdB=20*log10(FE1); %采用分贝形式

figure(2)
    hold on
    if n==1
        plot(theta1,FEdB,'--g','LineWidth',1.5);
    else
        plot(theta1,FEdB,'b','LineWidth',1.5); 
    end
%plot(tt,FEA,'--r','LineWidth',2);  %需要比较实测去掉注释
%legend('理论E方向图','理论E方向图(G=1)','实测E方向图');
    grid on
title('角锥喇叭E面方向图（理论实测比较）','FontName','华文隶书',...
      'FontWeight','Bold','FontSize',16)
xlabel('\bf角度θ   单位：度','FontSize',15);
ylabel('\bff(θ)    单位：dB','FontSize',15);
end


