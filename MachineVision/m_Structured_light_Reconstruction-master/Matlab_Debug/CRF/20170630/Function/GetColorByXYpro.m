function color = GetColorByXYpro(x_p, y_p, pattern)
    [max_y, max_x] = size(pattern);
    if (x_p < 1) || (x_p > max_x - 1) || (y_p < 1) || (y_p > max_y - 1)
        color = 0;
        return
    end
    
    x1 = x_p - floor(x_p);
    x2 = 1 - x1;
    y1 = y_p - floor(y_p);
	y2 = 1 - y1;
%     p_x1 = 1 - x1;
%     p_x2 = 1 - x2;
%     p_y1 = 1 - y1;
%     p_y2 = 1 - y2;
%     color_y1 = p_x1 * pattern(floor(y_p), floor(x_p)) ...
%         + p_x2 * pattern(floor(y_p), floor(x_p) + 1);
%     color_y2 = p_x1 * pattern(floor(y_p) + 1, floor(x_p)) ...
%         + p_x2 * pattern(floor(y_p) + 1, floor(x_p) + 1);
%     color = color_y1 * p_y1 + color_y2 * p_y2;
    
    color = pattern(floor(y_p), floor(x_p));
    
end

