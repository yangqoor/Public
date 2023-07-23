function [x,y]=pryamg(bs,s)

%   Самодельное описание геометрии

%        Gives geometry data for the circleg PDE model
%   NE=CIRCLEG gives the number of boundary segment
%
%   D=CIRCLEG(BS) gives a matrix with one column for each boundary segment
%   specified in BS.
%
%   [X,Y]=CIRCLEG(BS,S) gives coordinates of boundary points. BS specifies the
%   boundary segments and S the corresponding parameter values. BS may be
%   a scalar.

nbs=4;

if nargin==0,
  x=nbs; % number of boundary segments
  return
end

d=[
  0 0 0 0 % start parameter value
  1 1 1 1 % end parameter value
  1 1 1 1 % left hand region
  0 0 0 0 % right hand region
];

bs1=bs(:)';

if find(bs1<1 | bs1>nbs),
  error('Non existent boundary segment number')
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
x(ii)=1-2*s(ii);%1*cos((pi/2)*s(ii)-pi);
y(ii)=0;%1*sin((pi/2)*s(ii)-pi);

% boundary segment 2
ii=find(bs==2);
x(ii)=-1;%1*cos((pi/2)*s(ii)-(pi/2));
y(ii)=-0.8*s(ii);%1*sin((pi/2)*s(ii)-(pi/2));

% boundary segment 3
ii=find(bs==3);
x(ii)=-1+2*s(ii);%1*cos((pi/2)*s(ii));
y(ii)=-0.8;%1*sin((pi/2)*s(ii));

% boundary segment 4
ii=find(bs==4);
x(ii)=1;%1*cos((pi/2)*s(ii)-(3*pi/2));
y(ii)=-0.8*(1-s(ii));%1*sin((pi/2)*s(ii)-(3*pi/2));
end

