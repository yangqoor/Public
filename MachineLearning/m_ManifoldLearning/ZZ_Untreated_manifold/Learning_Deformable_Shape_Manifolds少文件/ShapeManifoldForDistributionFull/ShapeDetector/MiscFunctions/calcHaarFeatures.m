% Samuel Rivera
% Date: Aug 22, 2010
% Notes: This function is a wrapper for that Haar feature stuff

function [z F] = calcHaarFeatures( I, scale, desiredNumFeatures, F)
% F = haar_featlist([ny] , [nx] , [rect_param]);
% z = haar(I , [rect_param] , [F] , [standardize] );
% z =  Haar features matrix (nF x P) in INT16 format for each positions
% (y,x) in [1+h,...,ny-h]x[1+w,...,nx-w] and (w,h) integral block size.                              
%   I : Image tensor(Ny x Nx x N) in UINT8 format 
% 
%   rect_param:          Features rectangles parameters (10 x nR), where nR is the total number of rectangles for the patterns.
%                         (default Vertical(2 x 1) [1 ; -1] and Horizontal(1 x 2) [-1 , 1] patterns) 
%                         rect_param(: , i) = [ip ; wp ; hp ; nrip ; nr ; xr ; yr ; wr ; hr ; sr], where
%                         ip     index of the current pattern. ip = [1,...,nP], where nP is the total number of patterns
%                         wp     width of the current pattern
%                         hp     height of the current pattern
%                         nrip   total number of rectangles for the current pattern ip
%                         nr     index of the current rectangle of the current pattern, nr=[1,...,nrip]
%                         xr,yr  top-left coordinates of the current rectangle of the current pattern
%                         wr,hr  width and height of the current rectangle of the current pattern
%                         sr     weights of the current rectangle of the current pattern 
% 
% 
%   standardize           Standardize Input Images 1 = yes, 0 = no (default
%   = 1)

if isempty( scale )
    scale = 2;
end

rect_param = ...
    [ 1     1     2     2     3     3     3     4     4     4;
     2     2     1     1     3     3     3     1     1     1;
     1     1     2     2     1     1     1     3     3     3;
     2     2     2     2     3     3     3     3     3     3;
     1     2     1     2     1     2     3     1     2     3;
     0     1     0     0     0     1     2     0     0     0;
     0     0     0     1     0     0     0     0     1     2;
     1     1     1     1     1     1     1     1     1     1;
     1     1     1     1     1     1     1     1     1     1;
     1    -1    -1     1     1    -1     1     1    -1     1 ];

% combine scaled haar rectangle parameters 
rect_param([2 3 6 7 8 9 ],:) = scale*rect_param([2 3 6 7 8 9 ],:); 
rect_param2 = rect_param;
rect_param3 = rect_param;
rect_param2([2 3 6 7 8 9 ],:) = 2*rect_param2([2 3 6 7 8 9 ],:); 
rect_param3([2 3 6 7 8 9 ],:) = 4*rect_param3([2 3 6 7 8 9 ],:); 
rect_param = [ rect_param rect_param2 rect_param3];

% get the haar feature parameters based on rectangles
if isempty( F )
    F = haar_featlist(size(I,1) , size(I,2), rect_param);
end

% reduce dimensionality
downSampleAmount = round( size(F,2)/desiredNumFeatures );
F = F(:, 1:downSampleAmount:end);

% get Haar features
z = haar(uint8(I) , rect_param , F , 0 );
