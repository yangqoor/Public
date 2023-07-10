function [X,color,height]=genswissroll(N,W,fact)
%function [X,color,height]=genswissroll(N,W,fact);
% 
% Input:
% 	N  Number of points            (default: N=1000)
% 	W  Width (default: W=7)
% 	f  f*pi/2 length of swissroll  (default: f=3)
%
% copyright 2007 by Kilian Q. Weinberger

% Set default values
if(nargin<3)
  fact=3;
end;

if(nargin<1)
    N=1000;
end;
if(nargin<2)
    W=7;
end;

H=30;
L=40;

con=0;

tt = (fact*pi/2)*(1+2*rand(1,N));  height = fact*W*rand(1,N);

kl = repmat(0,1,2*N);
X = [tt.*cos(tt); height; tt.*sin(tt)];

M=min(min(abs(X)));

%scat(X,3,tt);

color=tt;
