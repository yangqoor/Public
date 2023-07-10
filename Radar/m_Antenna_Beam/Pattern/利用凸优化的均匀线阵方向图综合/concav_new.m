%  均匀线阵方向图综合，使用凸优化方法，主瓣宽度内平顶，两侧有
%一定宽度的凹口，转化成凸优化问题
clc;
clear all;
close all;

%  参数设置
ima=sqrt(-1);
C_num=40;                            % 阵元数
f=5.4e9;                             %频率12GHz
lamda = 3e8/f;                        % 波长
d = 0.5*lamda;                      % 阵元间距
theta0=90;                           % 目标
main_width=0.2;                       % 单位/度
ripple = 0.3;                        % 单位/dB
deta=5;                              %过渡带宽
main_lobe_l=theta0-main_width/2;     %主瓣角度下限
main_lobe_u=theta0+main_width/2;     %主瓣角度上限
side_lobe_l=main_lobe_l-deta;        %旁瓣角度下限
side_lobe_u=main_lobe_u+deta;        %旁瓣角度上限

%优化问题
m = 3600;
theta=linspace(0,180,m)';            %角度均匀划分

A=exp( -ima*2*pi*d*cos(theta*pi/180)*[1-C_num:C_num-1]/lamda );

ind=find(main_lobe_l<=theta & theta<=main_lobe_u);
Am = A(ind,:);                       %对应主瓣区

ind=find(0<=theta & theta<=side_lobe_l | side_lobe_u<=theta & theta<=180);
As = A(ind,:);                      %对应旁瓣区

ind=find(145<=theta & theta<=150);
A_cave=A(ind,:);

cvx_begin

  variable r(2*C_num-1,1) complex  
  minimize( max( real( As*r ) ) )    %旁瓣
  %minimize(norm(r))
  subject to    
    %(10^(-ripple/20))^2<=real( Am*r )<=(10^(+ripple/20))^2;
    real(As*r)<=(10^(-40/20))^2;
    real(A_cave*r)<=(10^(-30/20))^2;
    real( A*r ) >= 0;        
    imag(r(C_num)) == 0;
    r(C_num-1:-1:1) == conj(r(C_num+1:2*C_num-1));
cvx_end

% check if problem was successfully solved
if ~strfind(cvx_status,'Solved')
    return
end

% find antenna weights by computing the spectral factorization
w = spectral_fact(r);%调用子函数spectral_fact

% divided by 2 since this is in PSD domain
min_sidelobe_level = 10*log10( cvx_optval );
fprintf(1,'The minimum sidelobe level is %3.2f dB.\n\n',...
          min_sidelobe_level);
      
 
      
%方向图形成
theta=[0:0.01:180];
w0=exp(ima*2*pi*d*cos(theta0*pi/180)*[0:C_num-1]'/lamda);
w1=w/max(abs(w));                %方向图综合的最优权
for j=1:length(theta)
    a=exp(ima*2*pi*d*cos(theta(j)*pi/180)*[0:C_num-1]'/lamda);
    gain(j)=w0'*a;               %普通静态方向图响应
    gain_opt(j)=w1'*a;             %综合方向图响应
end
max_value=max(abs(gain));

G=abs(gain)/max_value;
G=20*log10(G);                    %普通方向图

Y=abs(gain_opt)/max_value;        %优化方向图
Y=20*log10(Y);

figure(1);clf
ymin = -100; ymax = 5;
plot(theta,Y,'.-b',theta,G,'p-m',...
     [theta0 theta0],[ymin ymax],'k--');
   
grid on,hold on
xlabel('俯仰角/度'), ylabel('幅度/dB');
axis([0 180 ymin ymax]);
legend('优化的','普通的');
