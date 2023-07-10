
function [RF] = Rad(theta,phi,s,x,y,u,v,alpha,rho)

%  This function computes the Radon transform of ellipses
% centered at (x,y) with major axis u, minor axis v,
% rotated through angle alpha, with weight rho.

RF = zeros(size(s));
mu=1;
for mu = 1:max(size(x))
   a = (u(mu)*cos(phi-alpha(mu)))^2+(v(mu)*sin(phi-alpha(mu)))^2;
   test = a-(s-[x(mu) y(mu)]*theta).^2;
   ind = test>0;
   RF(ind) = RF(ind)+rho(mu)*(2*u(mu)*v(mu)*sqrt(test(ind)))/a;
end  % mu-loop

% %Assume that noise is constained to normal distribution, with sigma 0.0005,namly 1/1000;
% RF= normrnd(RF,0.0005);

% Assume that noise is constained to poisson distribution;
% temp= poissrnd(round(40000*RF));
% RF= temp/40000;

% temp= sum(RF);
% RFtemp= RF/temp;
% RF= RFtemp*500000;   % Meanwhile  figure,imshow(P,[-800 1100]) is OK;
