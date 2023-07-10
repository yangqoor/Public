%平顶凹口旁瓣约束
clc;
clear;

n = 20;               % number of antenna elements
lambda = 1;           % wavelength
d = 0.45*lambda;      % inter-element spacing
ima=sqrt(-1);
% passband direction from 30 to 60 degrees (30 degrees bandwidth)
% transition band is 15 degrees on both sides of the passband
theta_pass = 40;
theta_stop = 50;
theta0=90;
t_l=70;
t_u=110;
% passband max allowed ripple
ripple = 0.1; % in dB (+/- around the unit gain)
k=2*pi/lambda;
%********************************************************************
% construct optimization data
%********************************************************************
% number of frequency samples
m = 30*n;

% convert passband and stopband angles into omega frequencies
omega_zero = -2*pi*d/lambda;
omega_pass = -2*pi*d/lambda*cos(theta_pass*pi/180);
omega_stop = -2*pi*d/lambda*cos(theta_stop*pi/180);
omega_pi   = +2*pi*d/lambda;

o_l=-2*pi*d/lambda*cos(t_l*pi/180);
o_u=-2*pi*d/lambda*cos(t_u*pi/180);

o_sl=-2*pi*d/lambda*cos(60*pi/180);
o_su=-2*pi*d/lambda*cos(120*pi/180);

o_al=-2*pi*d/lambda*cos(155*pi/180);
o_au=-2*pi*d/lambda*cos(165*pi/180);


% build matrix A that relates R(omega) and r, ie, R = A*r
omega = linspace(-pi,pi,m)';
A = exp( -j*omega(:)*[1-n:n-1] );%exp(-j*k*omega)

% passband constraint matrix
Ap = A(omega >= o_l & omega <= o_u,:);

% stopband constraint matrix
As = A(omega >= omega_zero & omega <= o_sl|omega>=o_su&omega<=omega_pi,:);
As1=A(omega>=o_al & omega<=o_au,:);

%********************************************************************
% formulate and solve the magnitude design problem
%********************************************************************
cvx_begin
  variable r(2*n-1,1) complex
  % minimize stopband attenuation
  %minimize( max(real( As*r )) )
  subject to
    % passband ripple constraints
    %(10^(-ripple/20))^2 <= real( Ap*r ) <= (10^(+ripple/20))^2;%表达式
    %主瓣波动约束，平顶
    
    real( As*r ) <= (10^(-15/20))^2;%旁瓣约束
    %(10^(-39.8/20))^2<=real( As1*r ) <= (10^(-40/20))^2;%拗口约束
    % nonnegative-real constraint for all frequencies
    % a bit redundant: the passband frequencies are already constrained
    real( A*r ) >= 0;
    % auto-correlation symmetry constraints
    imag(r(n)) == 0;
    r(n-1:-1:1) == conj(r(n+1:end));
    %real( As1*r )<=kexi;
cvx_end

% check if problem was successfully solved
if ~strfind(cvx_status,'Solved')
    return
end

% find antenna weights by computing the spectral factorization
w = spectral_fact(r);

% divided by 2 since this is in PSD domain
min_sidelobe_level = 10*log10( cvx_optval );
fprintf(1,'The minimum sidelobe level is %3.2f dB.\n\n',...
          min_sidelobe_level);

%********************************************************************
% plots
%********************************************************************
% build matrix G that relates y(theta) and w, ie, y = G*w
theta = [0:180]';
G = kron( cos(pi*theta/180), [0:n-1] );
G1 = exp(2*pi*ima*d/lambda*G);
y = G1*w;

%线阵方向图
% sen_pos=[0:n-1]*d;%位置
% p=zeros(1,length(theta));
% 
% w0=exp(ima*k*sen_pos'*cos(90*pi/180));
% p=G1*w0;
% 
% for m=1:length(theta)
%     a=exp(ima*k*sen_pos'*cos(theta(m)*pi/180));
%     p(m)=w0'*a;
% end
% 
% f=abs(p)/max(abs(p));
% F=20*log10(f);
% F=max(F,-50);

y=20*log10(abs(y));
%plot(theta,20*log(abs(p)/max(abs(p))))


% plot array pattern
figure(1), clf
ymin = -50; ymax = 5;
plot([0:180], y,...     
     [theta0 theta0],[ymin ymax],'r--');
 grid on;hold on
xlabel('look angle'), ylabel('mag y(theta) in dB');
axis([0 180 ymin ymax]);






