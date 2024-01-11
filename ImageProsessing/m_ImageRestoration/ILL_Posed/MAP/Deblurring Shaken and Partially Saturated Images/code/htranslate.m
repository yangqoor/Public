function T = htranslate(tt)
% 	HTRANSLATE   Translation matrix for homogeneous coordinates
% 		[T] = HTRANSLATE(TT)
% 
% 	For an input vector tt with n elements, the ouput is the n+1 x n+1 matrix which applies that translation in homogeneous coordinates.
% 	
% 	Created by Oliver Whyte on 2009-10-22.

T = eye(length(tt)+1);
T(1:end-1,end) = tt(:);

end %  function