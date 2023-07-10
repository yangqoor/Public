function [z,dis,gam]=Tikh_inv_smooth(A,u,alf);
%

[m,n]=size(A);
%   Ma=alf*DFF(diff(z))+norm(A*z-u);
%      X = FMINSEARCH(FUN,X0,OPTIONS,P1,P2,...)
options=optimset('Display','off','Diagnostics','off','MaxIter',50000);%off
warning off
z=fminunc('Smooth_func',ones(n,1),options,alf,A,u);
dis=norm(A*z-u);gam=DFF(z(1))+sum(DFF(diff(z)));
