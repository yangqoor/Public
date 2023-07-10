function p = projection_l2(x,s)
%projection de x sur la boule l2 de rayon s 
norm_x = norm(x);
if norm_x <= s
    p=x;
else
    p=(s/norm_x)*x;
end
end