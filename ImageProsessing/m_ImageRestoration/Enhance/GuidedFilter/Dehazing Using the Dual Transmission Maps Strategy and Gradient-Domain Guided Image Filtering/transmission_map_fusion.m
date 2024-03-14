function transmission_map = transmission_map_fusion(t1, t2, alpha)
% This function will fuse the two transmission maps
%
% Inputs:   This function will receive two inputs
%   Input1 is t1 of size MxN that is the tranmssion map calculated using the smaller
%   window size
%   Input2 is t2 of size MxN, the transmission map calculated using the larger
%   window size
%   Input 3 is alpha, a scalar, used to control the contribution of each
%   transmission map
%
% Output: The function will return only one output.
%
% Output is transmission_map of size MxN

transmission_map=(alpha*t1)+((1-alpha)*(t2));
return


