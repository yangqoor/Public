function [X,Y]=getEllipse(Mu,Sigma,S,pntNum)
% 置信区间 | 95%:5.991  99%:9.21  90%:4.605
% (X-Mu)*inv(Sigma)*(X-Mu)=S

invSig=inv(Sigma);

[V,D]=eig(invSig);
aa=sqrt(S/D(1));
bb=sqrt(S/D(4));

t=linspace(0,2*pi,pntNum);
XY=V*[aa*cos(t);bb*sin(t)];
X=(XY(1,:)+Mu(1))';
Y=(XY(2,:)+Mu(2))';
end