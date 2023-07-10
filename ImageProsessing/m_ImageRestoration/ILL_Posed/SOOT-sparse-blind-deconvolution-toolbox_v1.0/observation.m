function [y,alpha,beta,eta,lambda,NbIt,NbItx,NbIth] = observation(xtrue,htrue, noise_Std, seed) 

% generate observations
randn('state',seed);
L = length(htrue); 
xblured = Hconv(htrue,xtrue,L,ceil(L/2)) ;
y = xblured + noise_Std * randn(size(xtrue));

% choose good parameters
if(noise_Std == 0.01)
alpha = 7.8146e-007 ;
beta = 1e-007 ;
eta = 0.041512 ;
lambda = 0.093187 ;
elseif(noise_Std == 0.02)
alpha = 1.0546e-007 ;
beta = 1e-007 ;
eta = 0.040084 ;
lambda = 0.25318 ;
elseif(noise_Std == 0.03)
alpha = 5.3721e-005 ;
beta = 1e-007 ;
eta = 0.046789 ;
lambda = 0.33914 ;
else
error(['No regularization parameters for noise_Std = ',num2str(noise_Std)])
end
% best choice in term of convergence rate
NbItx = 71 ;
NbIth = 1 ;
NbIt = 2000 ;
end