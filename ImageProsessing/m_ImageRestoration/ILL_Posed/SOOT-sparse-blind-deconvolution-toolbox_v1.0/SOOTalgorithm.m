function [x, h, Time, norm1_x,norm2_x,norm1_h,norm2_h] = ...
    SOOTalgorithm(x0, h0, xtrue, htrue, y, sigma,beta,eta, ...
                   nu, epsx, hmin, hmax,epsh, NbIt,NbItx,NbIth)
                        
% BC-VMFB algorithm
% blind deconvolution
% G(x,h) = F(x,h) + R1(x) + R2(h)
% with F(x,h) = norm( Hx-y )^2 + lambda * SOOT(x)
%      R1(x) = contraintes : ||x||_Inf <= epsx
%      R2(h) = contraintes : sum(h) = 0 ; norm(h) <= epsh ; hmin <= h <= hmax ;

% -------------------------------
gamma = 1.9 ;
x = x0 ;
h = h0 ;
L = length(h) ; ceilL = ceil(L/2);
N = length(x) ;
v1 = zeros(L,1); v2 = zeros(L,1);
% -------------------------------
Cg2 = 9/(N*8*eta^2);
vx = zeros(size(x)) ;
% -------------------------------

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
H =@(x) Hconv(h,x,L,ceilL) ;
Hadj =@(y) Hconv_adj(h,y,L,ceilL) ;
% -------------------------------
Crit = Criterion_x(x, H, y, sigma,beta,eta,nu) ;
[gradx,l1] = gradient_x(x, H, Hadj, y, sigma,beta,eta,nu) ;
[norm1_x(1),norm2_x(1)] = signal_noise(x,xtrue) ;
[norm1_h(1),norm2_h(1)] = signal_noise(h,htrue) ;
Norm_Xold = 0 ; 
Time(1) = 0 ;
% -----------------------------
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~') 
disp('INITIALIZATION:')
disp('----------------------------')
disp(['alpha = ',num2str(sigma),', beta = ',num2str(beta),', eta = ',num2str(eta)])
disp(['regularization parmaeter = ',num2str(nu)])
disp('----------------------------')
disp(['Crit = ',num2str(Crit)])
disp('----------------------------')
disp(['x : l1  = ',num2str(norm1_x(1)),', l2  = ',num2str(norm2_x(1))])
disp(['h : l1  = ',num2str(norm1_h(1)),', l2  = ',num2str(norm2_h(1))])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')  
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% *********************************************************************** %
% *********************************************************************** %
% ITERATIONS ************************************************************ %
% *********************************************************************** %
% *********************************************************************** %


for iter = 1:NbIt
% -------------------------------------------------------------------------
% Stopping criterion ------------------------------------------------------
if(iter>2)
CondS_norm = Norm_Xold/sqrt(N) ;
if(CondS_norm < 1e-6)
    break
end
end
% -------------------------------------------------------------------------
tic
% -------------------------------------------------------------------------
% Minimisation sur x ------------------------------------------------------
% -------------------------------------------------------------------------
Hnorm2 = normHtHconv(h,N,L,ceilL) ;
Xold = x ;
for iter_x = 1:NbItx
% -------------------------------
Axinv = Majorante_x(x,sigma,l1,beta, Cg2, Hnorm2,nu) ;
[x,vx] = Minimisation_x(x,gradx,gamma,Axinv, epsx,vx) ;
% -------------------------------
[gradx,l1] = gradient_x(x, H, Hadj, y, sigma,beta,eta,nu) ;
% -------------------------------
end    
% -------------------------------------------------------------------------
% Minimisation sur h ------------------------------------------------------
% -------------------------------------------------------------------------
X = @(h) Xconv(h,x,N,L,ceilL) ;
Xadj = @(y) Xconv_adj(x,y,L,ceilL) ;
Ah = normXtXconv(x,L,ceilL) ;
% -------------------------------
for iter_h = 1:NbIth
% -------------------------------
[h,v1,v2] = Minimisation_h(h,y,v1,v2, Ah,X,Xadj, hmin,hmax, epsh,gamma) ;
% -------------------------------
end

% -------------------------------------------------------------------------
% updates -----------------------------------------------------------------
H =@(x) Hconv(h,x,L,ceilL) ;
Hadj =@(y) Hconv_adj(h,y,L,ceilL);
% -------------------------------
[gradx,l1] = gradient_x(x, H, Hadj, y, sigma,beta,eta,nu) ;
% -------------------------------
Time(iter+1) = toc ;
[norm1_x(iter+1),norm2_x(iter+1)] = signal_noise(x,xtrue) ;
[norm1_h(iter+1),norm2_h(iter+1)] = signal_noise(h,htrue) ;
Norm_Xold = norm(x-Xold) ;

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
end

Crit = Criterion_x(x, H, y, sigma,beta,eta,nu) ;
Display_datas(iter, Crit, ...
    norm1_x(end),norm2_x(end),norm1_h(end),norm2_h(end),sum(Time)) ;

end


% *********************************************************************** %
% *********************************************************************** %
% FONCTIONS ************************************************************* %
% *********************************************************************** %
% *********************************************************************** %


function [norm1,norm2] = signal_noise(x, xtrue)
N = length(xtrue) ;
norm1 = sum(abs(x-xtrue)) / N ;
norm2 = sqrt( (sum((x-xtrue).^2)) / N ) ;
end
% ----------------------------------------------------------------------- %
function Display_datas(iter, Crit, ...
    l1x,l2x,l1h,l2h,time)
disp(' ')
disp('----------------------------------')
disp(['Iteration = ',num2str(iter)])
disp(['Crit = ',num2str(Crit)])
disp(['Time = ',num2str(time)])
disp('----------------------------')
disp(['x : l1  = ',num2str(l1x),' l2  = ',num2str(l2x)])
disp('----------------------------')
disp(['h : l1  = ',num2str(l1h),' l2  = ',num2str(l2h)])
disp('----------------------------------')
end
% *********************************************************************** %
% *********************************************************************** %
function crit = Criterion_x(x, H, y, sigma,beta,eta,nu)

l1 = sum(sqrt(x.^2 + sigma^2) -sigma);
l2 =  sqrt(sum(x.^2 +eta^2));
Hx_y = H(x) - y;
fid = (1/2)* sum((Hx_y).^2) ;
l1l2 = nu*log( (l1+beta)./l2 ) ;
crit = fid + l1l2 ;

end
% *********************************************************************** %
% *********************************************************************** %
function [grad,l1] = gradient_x(x, H, Hadj, y, sigma,beta,eta,nu)

l1 = sum(sqrt(x.^2 + sigma^2) -sigma);
l2 =  sqrt(sum(x.^2 +eta^2));
Hx_y = H(x) - y;

gradfid = Hadj( Hx_y) ;
gradl1l2 = nu * ( x./(sqrt(x.^2+sigma^2)*(l1+beta))- x/(l2^2) ) ;
grad = gradfid + gradl1l2 ;
end
% *********************************************************************** %
% *********************************************************************** %
function Ainv = Majorante_x(x,sigma,l1,beta, Cg2, epsH,nu)
Al1l2 = nu*( 1./(sqrt(x.^2+sigma^2)*(l1+beta)) + Cg2) ; 
Afid = epsH ;
A = Al1l2 + Afid; 
Ainv = A.^(-1);
end
% *********************************************************************** %
% *********************************************************************** %
function [x,v] = Minimisation_x(x,grad,gamma,Ainv, epsx,v)
xbar = x - gamma * Ainv .* grad ;
% projection of xbar
x = projection_maxmin( xbar, epsx(1), epsx(2)) ;
end

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
function [h,v1,v2] = Minimisation_h(h,y,v1,v2, Ah,X,Xadj, hmin,hmax, epsh,gamma)

grad = Xadj(X(h)-y) ;
hbar = h - (gamma/Ah).*grad;
% projection of hbar
NbIt = 10000 ; 
[h, v1,v2] = DualFB(h,v1,v2,hbar,hmin,hmax,epsh,NbIt) ;
end
% ----------------------------------------------------------------------- %
function [h, v1,v2] = DualFB(h,v1,v2,hbar,hmin,hmax,epsh,NbIt_h_in) 
rho = 1 ;
delta = min(1,rho)*0.1 ;
gamma_ = max(delta, 2*rho-delta) ;

for i = 1: NbIt_h_in  
	h = hbar - (v1 + v2)./2; 
	u1 = v1 + gamma_ * h ;
	u2 = v2 + gamma_ * h ;
	v1 =  u1 - gamma_ .* projection_maxmin( gamma_^(-1)*u1, hmin, hmax) ;    
	v2 =  u2 - gamma_ * projection_l2(gamma_^(-1)*u2,epsh);  
 	if ((norm(h) <= eps) && ((max(h)<=hmax) && (min(h)>=hmin)))
        break;
	end    
end

end
% *********************************************************************** %
% *********************************************************************** %

