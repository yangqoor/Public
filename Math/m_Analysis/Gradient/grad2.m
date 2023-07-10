% ÊýÖµ·¨
function  [dw0,dw1,dw2] = grad2(w0,w1,w2,x0,x1,epi)
% dw0
f1w0 = 1.0/(1+exp(-1*((w0+epi)*x0+w1*x1+w2)));
f2w0 = 1.0/(1+exp(-1*((w0-epi)*x0+w1*x1+w2)));
dw0 = (f1w0 - f2w0)/(2*epi);
% dw1
f1w1 = 1.0/(1+exp(-1*(w0*x0+(w1+epi)*x1+w2)));
f2w1 = 1.0/(1+exp(-1*(w0*x0+(w1-epi)*x1+w2)));
dw1 = (f1w1 - f2w1)/(2*epi);
% dw2
f1w2 = 1.0/(1+exp(-1*(w0*x0+w1*x1+(w2+epi))));
f2w2 = 1.0/(1+exp(-1*(w0*x0+w1*x1+(w2-epi))));
dw2 = (f1w2 - f2w2)/(2*epi);
end