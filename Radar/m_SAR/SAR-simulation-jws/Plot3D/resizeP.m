%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [csarImage3D,xRangeT_m,yRangeT_m,zRangeT_m] = resizeP(csarImage3D,xRangeT_m,yRangeT_m,zRangeT_m,p)

indX = xRangeT_m >= (p.xT(1)) & xRangeT_m <= (p.xT(end));
indY = yRangeT_m >= (p.yT(1)) & yRangeT_m <= (p.yT(end));
indZ = zRangeT_m >= (p.zT(1)) & zRangeT_m <= (p.zT(end));
csarImage3D = csarImage3D(indX,indY,indZ);
clear indX indY indZ
csarImage3D = imresize3(abs(csarImage3D),[p.xLim,p.yLim,p.zLim]);
xRangeT_m = p.xT;
yRangeT_m = p.yT;
zRangeT_m = p.zT;