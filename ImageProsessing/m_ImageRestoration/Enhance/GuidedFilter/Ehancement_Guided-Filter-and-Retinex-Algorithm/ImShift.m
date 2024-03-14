function shifted = ImShift(v,xShift,yShift)
% 2D Shift of the Input Image
shifted = zeros(size(v));
if (xShift<=0 && yShift<=0)
    shifted(-xShift+1:end,-yShift+1:end) = v(1:end+xShift,1:end+yShift);
elseif (xShift<=0 && yShift>0)
    shifted(-xShift+1:end,1:end-yShift) = v(1:end+xShift,yShift+1:end);
elseif (xShift>0 && yShift<=0)
    shifted(1:end-xShift,-yShift+1:end) = v(xShift+1:end,1:end+yShift);
else
    shifted(1:end-xShift,1:end-yShift) = v(xShift+1:end,yShift+1:end);
end
end