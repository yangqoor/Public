function [G, a, b, c] = gateCreateLim(Volume, A, Hs, maxError)
% obj.pGatingConstantVolume, obj.gC_inv, obj.H_s_apriori_hat, obj.pGatingMaxLimits

% Simplified Gate Construction (no need for SVD)
% We build a gate based on a constant volume
% In addition, we impose a limiter: under no circumstances the gate will
% allow to reach points beyond maxRangeError



% Compute unit volume
% a = 1/sqrt(A(1,1));
% b = 1/sqrt(A(2,2));
% c = 1/sqrt(A(3,3));
a = 1/ (A(1,1));
b = 1/ (A(2,2));
c = 1/ (A(3,3));
v = 4*pi/3*a*b*c;

% Compute expansion factor
gConst = (Volume/v)^(2/3);

gUnitary = (1/v)^(2/3);

gmaxRange = 100;
gmaxAngle = 100;
gmaxVel = 100;

L=cholesky(A);
if(maxError(1))
    % Limit is imposed on the range dimension
    % Find projection to range line [1,0,0]
    w=L\[1,0,0]';   % inv(L)*[1;0;0]
    s = 2*sqrt(sum(w.^2));%参考文献附录上有解释 为椭球在R轴上的投影
    % Construct a range limiter
    gmaxRange = (maxError(1)/s)^2;
%    if(gmaxRange < gUnitary)
%        disp(['WARNING: Range limit reached, ',num2str(gmaxRange,3), ' < ', num2str(gConst,3)]);
%    end    
end
if(maxError(2))
% Limit is imposed on the angle dimension
% Find projection to angle line [0,1,0]
    w=L\[0,1,0]';
    s = 2*sqrt(sum(w.^2));
if 0
    gmaxAngle = (maxError(2)/s)^2;
else  
    sm = Hs(1)*2*tan(s/2);
    gmaxAngle = (maxError(2)/sm)^2;
end
%    if(gmaxAngle < gUnitary)
%        disp(['WARNING: Angle limit reached, ', num2str(gmaxAngle,3) ' < ', num2str(gUnitary,3)]);
%    end    
end
if(maxError(3))
% Limit is imposed on the velocity dimension
% Find projection to angle line [0,0,1]
    w=L\[0,0,1]';
    s = 2*sqrt(sum(w.^2));
    gmaxVel = (maxError(3)/s)^2;
%    if(gmaxVel < gUnitary)
%        disp(['WARNING: Velocity limit reached, ', num2str(gmaxVel,3) ' < ', num2str(gUnitary,3)]);
%    end
end

gmaxLim = min([gmaxRange,gmaxAngle,gmaxVel]);
G = min(gConst,gmaxLim);
% G = mean([gConst,gmaxLim]);
%G = gConst;

end