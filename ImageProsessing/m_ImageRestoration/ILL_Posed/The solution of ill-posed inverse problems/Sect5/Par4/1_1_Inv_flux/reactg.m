function [x,y]=reactg(bs,s)
%REACTG	Gives geometry data for the reactg PDE model.
%
%   NE=REACTG gives the number of boundary segments
%
%   D=REACTG(BS) gives a matrix with one column for each boundary segment
%   specified in BS.
%   Row 1 contains the start parameter value.
%   Row 2 contains the end parameter value.
%   Row 3 contains the number of the left-hand regions.
%   Row 4 contains the number of the right-hand regions.
%
%   [X,Y]=REACTG(BS,S) gives coordinates of boundary points. BS specifies the
%   boundary segments and S the corresponding parameter values. BS may be
%   a scalar.

nbs=7;

if nargin==0,
  x=nbs; % number of boundary segments
  return
end

d=[
  0  0 0 0 0 0  0 % start parameter value
  1  1 1 1 1 1  1 % end parameter value
  2  0 2 3 1 1  0 % left hand region
  0  2 0 0 0 0  1 % right hand region
];

bs1=bs(:)';

if find(bs1<1 | bs1>nbs),
  error('Non-existent boundary segment number')
end

if nargin==1,
  x=d(:,bs1);
  return
end

x=zeros(size(s));
y=zeros(size(s));
[m,n]=size(bs);
if m==1 & n==1,
  bs=bs*ones(size(s)); % expand bs
elseif m~=size(s,1) | n~=size(s,2),
  error('bs must be scalar or of same size as s');
end

if ~isempty(s),

% boundary segment 1
ii=find(bs==1);
if length(ii)
x(ii)=(1-(1))*(s(ii)-0)/(1)+(1);
y(ii)=(1-(0))*(s(ii)-0)/(1)+(0);
end

% boundary segment 2
%ii=find(bs==2);
%if length(ii)
%x(ii)=(1-(0.80000000000000004))*(s(ii)-d(1,2))/(d(2,2)-d(1,2))+(0.80000000000000004);
%y(ii)=(0-(0))*(s(ii)-d(1,2))/(d(2,2)-d(1,2))+(0);
%end

% boundary segment 3
ii=find(bs==2);
if length(ii)
x(ii)=(1-(0.80000000000000004))*(s(ii)-d(1,3))/(d(2,3)-d(1,3))+(0.80000000000000004);
y(ii)=(1-(1))*(s(ii)-d(1,3))/(d(2,3)-d(1,3))+(1);
end

% boundary segment 4
ii=find(bs==3);
if length(ii)
x(ii)=(0.80000000000000004-(0.80000000000000004))*(s(ii)-d(1,4))/(d(2,4)-d(1,4))+(0.80000000000000004);
y(ii)=(0.59999999999999998-(1))*(s(ii)-d(1,4))/(d(2,4)-d(1,4))+(1);
end

% boundary segment 5
ii=find(bs==4);
if length(ii)
x(ii)=(0.80000000000000004-(0.80000000000000004))*(s(ii)-d(1,5))/(d(2,5)-d(1,5))+(0.80000000000000004);
y(ii)=(0-(0.59999999999999998))*(s(ii)-d(1,5))/(d(2,5)-d(1,5))+(0.59999999999999998);
end

% boundary segment 6
ii=find(bs==5);
if length(ii)
x(ii)=(0-(0))*(s(ii)-d(1,6))/(d(2,6)-d(1,6))+(0);
y(ii)=(-1-(-0.80000000000000038))*(s(ii)-d(1,6))/(d(2,6)-d(1,6))+(-0.80000000000000038);
end

% boundary segment 7
ii=find(bs==6);
if length(ii)
t=[1 0
0 1];
nth=100;
th=linspace(-1.5707963267948966,0,nth);
rr=t*[cos(th);sin(th)];
theta=pdearcl(th,rr,s(ii),d(1,6),d(2,6));
rr=t*[cos(theta);sin(theta)];
x(ii)=rr(1,:)+(0);
y(ii)=rr(2,:)+(0);
end

% boundary segment 8
%ii=find(bs==8);
%if length(ii)
%t=[1 0
%0 1];
%nth=100;
%th=linspace(0,0.64350110879328426,nth);
%rr=t*[cos(th);sin(th)];
%theta=pdearcl(th,rr,s(ii),d(1,8),d(2,8));
%rr=t*[cos(theta);sin(theta)];
%x(ii)=rr(1,:)+(0);
%y(ii)=rr(2,:)+(0);
%end

% boundary segment 9
ii=find(bs==7);
if length(ii)
t=[0.80000000000000004 0
0 0.80000000000000004];
nth=100;
th=linspace(-1.5707963267948966,0,nth);
rr=t*[cos(th);sin(th)];
theta=pdearcl(th,rr,s(ii),d(1,7),d(2,7));
rr=t*[cos(theta);sin(theta)];
x(ii)=rr(1,:)+(0);
y(ii)=rr(2,:)+(0);
end

end
