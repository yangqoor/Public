function P=Legendre_v(v,u,phi)
    if u==1/2
         P=sqrt(2/pi/sin(phi+eps))*cos(v*phi);
     elseif u==-1/2
         if v==0
            P=sqrt(2/pi/sin(phi+eps));
         else
            P=sqrt(2/pi/sin(phi+eps))*sin(v*phi)/v;
        end
    else
        fprintf('error');
    end