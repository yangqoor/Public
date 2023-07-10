function tuoyuan=creat_ellipse(ellipse,n)
p = zeros(n);

xax =  ( (0:n-1)-(n-1)/2 ) / ((n-1)/2); 
xg = repmat(xax, n, 1);   % x coordinates, the y coordinates are rot90(xg)

for k = 1:size(ellipse,1)    
   asq = ellipse(k,2)^2;       % a^2
   bsq = ellipse(k,3)^2;       % b^2
   phi = ellipse(k,6)*pi/180;  % rotation angle in radians
   x0 = ellipse(k,4);          % x offset
   y0 = ellipse(k,5);          % y offset
   A = ellipse(k,1);           % Amplitude change for this ellipse
   x=xg-x0;                    % Center the ellipse
   y=rot90(xg)-y0;  
   cosp = cos(phi); 
   sinp = sin(phi);
   idx=find(((x.*cosp + y.*sinp).^2)./asq + ((y.*cosp - x.*sinp).^2)./bsq <= 1); 
   p(idx) = p(idx) + A;
   tuoyuan=p;
end