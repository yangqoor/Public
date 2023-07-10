function p = projection_maxmin (h, hmin, hmax)
p = min(h,hmax) ;
p = max(p, hmin) ;
end