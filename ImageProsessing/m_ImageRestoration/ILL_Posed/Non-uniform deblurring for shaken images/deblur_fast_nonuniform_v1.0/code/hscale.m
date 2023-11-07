function S = hscale(ss)
% 	HSCALE   Scaling matrix for homogeneous coordinates
% 		[S] = HSCALE(SS)
% 
% 	For an input vector ss with n elements, S is a n+1 x n+1 matrix which applies those scaling factors in homogeneous coordinates.
% 	
% 	Created by Oliver Whyte on 2009-10-22.

S = eye(length(ss)+1);
S(1:end-1,1:end-1) = diag(ss);

end %  function