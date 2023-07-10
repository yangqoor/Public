function color = GetColorByCoordinate(x, y, pattern)
    [max_y, max_x] = size(pattern);
    if (x < 1) || (x > max_x - 1) || (y < 1) || (y > max_y - 1)
        color = 0;
        return
    end
    x1 = x - floor(x);
    x2 = 1 - x1;
%     y1 = y - floor(y);
%     y2 = 1 - y1;
    p_x1 = 1 - x1;
    p_x2 = 1 - x2;
%     p_y1 = 1 - y1;
%     p_y2 = 1 - y2;
%     colors = [0; 0; 0; 0];
%     if (floor(y) > 0) && (floor(x) > 0)
%         colors(1) = pattern(floor(y), floor(x));
%     end
%     if (floor(y) + 1 <= max_y) && (floor(x) > 0)
%         colors(2) = pattern(floor(y) + 1, floor(x));
%     end
%     if (floor(y) + 1 <= max_y) && (floor(x) + 1 <= max_x)
%         colors(3) = pattern(floor(y) + 1, floor(x) + 1);
%     end
%     if (floor(y) > 0) && (floor(x) + 1 <= max_x)
%         colors(4) = pattern(floor(y), floor(x) + 1);
%     end
%
%     color = p_x1 * p_x2 * colors(1) + p_x2 * p_y1 * colors(2) ...
%         + p_x1 * p_y2 * colors(3) + p_x2 * p_y2 * colors(4);
    color = p_x1 * pattern(floor(y), floor(x)) + p_x2 * pattern(floor(y), floor(x) + 1);
end
