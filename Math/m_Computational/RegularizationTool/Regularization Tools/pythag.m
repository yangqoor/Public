function x = pythag(y,z) 
%PYTHAG Computes sqrt( y^2 + z^2 ). 
% 
% x = pythag(y,z) 
% 
% Returns sqrt(y^2 + z^2) but is careful to scale to avoid overflow. 
 
% Christian H. Bischof, Argonne National Laboratory, 03/31/89. 
 
rmax = max(abs([y;z])); 
if (rmax==0) 
  x = 0; 
else 
  x = rmax*sqrt((y/rmax)^2 + (z/rmax)^2); 
end 
