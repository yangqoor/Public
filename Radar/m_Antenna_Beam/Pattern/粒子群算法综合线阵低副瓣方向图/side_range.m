%----------------主程序——------------
clc;
clear;
eps;
c=3e8;                     % 光速
fc=1.3e9;                  % 工作频率（hz）
numda=c/fc;                % 波长 wave length
N=16;                      % 阵列数
d=0.5*numda;               % 阵元间距
L=N*d;                     % 天线长
k=(2*pi)/numda;            % 波数
fs=10;                      % 采样频率
theta=-90:1/fs:90;    % 方位角度范围（采样范围）(rad)
Ns=length(theta);          % 采样点数
B=90;    %主波束宽度为90度
theta_d=0;                % 主波束方向
%---------------------适应值函数------------------------
%------即目标函数--------
fd=[10^(-1.5)*ones(1,800) ones(1,200) 10^(-1.5)*ones(1,801)];
fd=20*log10(fd);
plot(theta,fd,':');hold on;
xlim([-90 90]);
%---------------------粒子群算法------------------------
pop_size = 30;          %   pop_size 种群大小
part_size = N/2;            %   part_size 粒子大小，即阵元的馈电幅值的数目，阵元馈电对称，粒子数目只取一半。
a_max=1;a_min=0.3;  %幅度的范围
c1=1.49445;c2=1.49445;           %学习因子
v_max=1.0;           %最大速度
% w=1;               %惯性权重因子，为可变值，采用不同的权重因子可提高收敛速度。
NN=300;%迭代次数
    %---------------------初始寻优------------------------
    pop_a_ini=rand(pop_size,N/2);
    p_a_b=zeros(pop_size,N/2,NN+1); %粒子局部最优解，即每个粒子在寻优过程中的历史最优值。
    p_a_g=zeros(N/2,NN+1);%粒子全局最优解，所有粒子的最优值。
        %-------初始化粒子-------
        for i=1:pop_size
             f_ini_array(i,:)=present_array(Ns,d,theta,pop_a_ini(i,:));
             erro_ini(i)=array_erro(f_ini_array(i,:),fd);
        end
    [C,I] = min(erro_ini);
    p_a_g(:,1)=pop_a_ini(I,:);%将初始迭代的全局最优值进行存储
    p_a_b(:,:,1)=pop_a_ini;%将所有粒子的过程最优值均赋为初始值
    v_a=v_max*(rand(pop_size,NN+1)-0.5*ones(pop_size,NN+1));%粒子幅度的速度初始化
    pop_a_present=zeros(pop_size,N/2,NN+1);
    pop_a_present(:,:,1)=pop_a_ini;
    f_present=zeros(pop_size,Ns,NN+1);%每个粒子在每次迭代中的方向图
    f_present(:,:,1)=f_ini_array;
    f_g_array=zeros(NN+1,Ns);%整个粒子群在每次迭代中的全局最优解的方向图
    erro_present=zeros(pop_size,NN+1);%评价函数的初始化。
    erro_present(:,1)=erro_ini;%将评价函数的初始值进行存储
    erro_b=zeros(pop_size,NN+1);%初始化粒子在迭代过程中的最优值。
    erro_b(:,1)=erro_ini;
    erro_g_b=zeros(NN+1,1); %初始化所有粒子的全局最优值最优值。
    erro_g_b(1)=C;%整个粒子群在初始时的最优误差
    
        %---------------------迭代过程------------------------
        for n=1:NN  
            for ii=1:pop_size    
                 for kk=1:N/2
                     v_a(ii,n+1)=(-0.5*n/NN+0.9)*v_a(ii,n)+c1*rand*(p_a_b(ii,kk,n)-pop_a_present(ii,kk,n))+c2*rand*(p_a_g(kk,n)-pop_a_present(ii,kk,n));%粒子速度更新。
                     
                     if abs(v_a(ii,n+1))>v_max%判断粒子速度是否越界，以及越界后的处理。
                        v_a(ii,n+1)=v_max*v_a(ii,n+1)/abs(v_a(ii,n+1));
                     end   
                     
                    pop_a_present(ii,kk,n+1)=pop_a_present(ii,kk,n)+v_a(ii,n+1);%粒子位置更新。
                    
                    if pop_a_present(ii,kk,n+1)>a_max%判断粒子大小是否越界，以及越界后的处理。
                         pop_a_present(ii,kk,n+1)=a_max;                   
                    elseif  pop_a_present(ii,kk,n+1)<a_min
                         pop_a_present(ii,kk,n+1)=a_min;
                    end        
                    
                    if pop_a_present(ii,kk,n+1)==pop_a_present(ii,kk,n) %为了避免粒子相邻两次更新后其所含的某两个馈结果相同，对相同的两个馈电大小进行调整。这一句可不要。
                         pop_a_present(ii,kk,n+1)=pop_a_present(ii,kk,n+1)-0.01;
                    end
                 end
             
             f_present(ii,:,n+1)=present_array(Ns,d,theta,pop_a_present(ii,:,n+1)); %调用方向图函数对每一次迭代的方向图函数的每一方位角的取值进行计算。
             erro_present(ii,n+1)=array_erro(f_present(ii,:,n+1),fd);%对每一个粒子每一次迭代后的评价函数进行计算。
            
                %---------------------每个粒子自更新后，自身局域最优解的更新------------------------
                 if erro_present(ii,n+1)<=erro_b(ii,n)
                    erro_b(ii,n+1)=erro_present(ii,n+1);
                    p_a_b(ii,:,n+1)=pop_a_present(ii,:,n+1);
                 else
                    erro_b(ii,n+1)=erro_b(ii,n);
                    p_a_b(ii,:,n+1)= p_a_b(ii,:,n);
                 end 
                 
            end
            
                %---------------------每个粒子更新后，全局最优解的更新------------------------
                [C,I]=min(erro_b(:,n+1));
                erro_g_b(n+1)=C;
                p_a_g(:,n+1)=p_a_b(I,:,n+1);%最后一次的最优值，即为最优结果。
                
        end
    %---------------------迭代完毕------------------------
f_best_array=present_array(Ns,d,theta,p_a_g(:,NN+1)');
plot(theta,f_best_array);grid on;
ylim([-60 0]);
figure
t=1:16;
amplitude=amplitude_curve(p_a_g(:,NN+1));
plot(t,amplitude,'r*');
xlim([1 16]);
ylim([0.1 1.1]);
   