function F = getEstimateSpec(C,Gw,Fw,beta,noiseLevel)
% exp1.m调用，得到新的图像或PSF频谱估计值
F = zeros(size(C));
Cabs = abs(C); Gwabs = abs(Gw);

cond0 = (Cabs < noiseLevel);
cond1 = (Gwabs >= Cabs) & (~cond0);
cond2 = (Gwabs < Cabs) & (~cond0);

F(cond0) = Fw(cond0);
F(cond1) = (1-beta)*Fw(cond1)+beta*C(cond1)./Gw(cond1);
F(cond2) = 1./((1-beta)./Fw(cond2)+beta*Gw(cond2)./C(cond2));
