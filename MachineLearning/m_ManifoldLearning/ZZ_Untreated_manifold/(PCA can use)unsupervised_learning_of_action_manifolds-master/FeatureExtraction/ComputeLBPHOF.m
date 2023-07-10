% function to compute HOF/LBP representation for the optical
% flow image
function [H,L] = ComputeLBPHOF(img_mag,img_dir,img_mask,varargin)
% img_mag - magnitude at a pixel
% img_dir - direction at a pixel
[rows,cols] = size(img_mag);
X = [0:1:cols-1]/cols;
Y = [0:1:rows-1]/rows;

% DO RANSACK
% [Vx,Vy,X,Y] = DoRansack(img_mag,img_dir);
% 
% % Convert to Sparse matrix
% R = Y * rows + 1;
% C = X * cols + 1;
% S_Vx = sparse(floor(R),floor(C),Vx,rows,cols);
% S_Vy = sparse(floor(R),floor(C),Vy,rows,cols);
% 
% % Convert to Full Matrix
% Vx = full(S_Vx);
% Vy = full(S_Vy);

% computing the bw_mask for centroid computation
% bw_mask = (img_mag > 0);
% se = strel('disk',5);
% bw_mask = imclose(bw_mask,se); 
bw_mask = img_mask;

%% UnComment the Lines below if is using RANSACK
% Convert back to magnitude and direction information
%img_mag = sqrt(Vx.^2 + Vy.^2);
%img_dir = atan2(Vy,Vx);

% Comment the line below if using RANSACK 
img_dir = img_dir * pi / 180;
nVarags = length(varargin);
if(nVarags ~= 0)
    flagEqualDiv = varargin{1};
else
    flagEqualDiv = false;
end
%%
num_bins = 20;
% Extract Global and Local HOOF throught a recursive function
H = HOOF(img_mag,img_dir,3,bw_mask,num_bins,true,flagEqualDiv);

% % normalize each level - Normalization per frame
if(sum(H(1:num_bins)) > 0)
    H(1:num_bins) = H(1:num_bins) / sum(H(1:num_bins)); % make it scale invariant
    offset = num_bins;
    num_bins = num_bins / 2;
    if(sum(H(offset + 1: offset + num_bins*4)) > 0)
        H(offset + 1: offset + num_bins*4) = H(offset + 1: offset + num_bins*4)/ sum(H(offset + 1: offset + num_bins*4));
        %% The below three lines only for the third level
        offset = offset + num_bins*4;
        num_bins = num_bins / 2;
        if(sum(H(offset + 1: offset + num_bins*16)) > 0)
            H(offset + 1: offset + num_bins*16) = H(offset + 1: offset + num_bins*16)/ sum(H(offset + 1: offset + num_bins*16));
        end
    end
end

% Create a matrix with each pixel denoting the dominant orientation of a
% sub-region of the mask
%D = DominantOrientMatrix(img_mag,img_dir,2,bw_mask);
%D = D + pi;
%D = padarray(D,[1 1],'replicate');
% Extra padding
if(size(img_dir,1) < 6 || size(img_dir,2) < 6)
    disp('Problem');
end


%%
mapping = getmapping(8,'u2');
num_bins = 36;
L = WLBFP(img_mag,img_dir,2,bw_mask,num_bins,mapping,flagEqualDiv);
%mapping.table = 0:1:255;
%mapping.num = 256;
len_L = mapping.num-1;
%len_L = mapping.num;
% Normalize per frame for each level
if(sum(L(1:len_L)) > 0)
    L(1:len_L) = L(1:len_L) / sum(L(1:len_L));
    offset = len_L;
    if(sum(L(offset + 1: offset + len_L*4)) > 0)
        L(offset + 1: offset + len_L*4) = L(offset + 1: offset + len_L*4)/ sum(L(offset + 1: offset + len_L*4));
    end
end
%offset = offset + len_L*4;
%L(offset + 1: offset + len_L*16) = L(offset + 1: offset + len_L*16)/ sum(L(offset + 1: offset + len_L*16));


end