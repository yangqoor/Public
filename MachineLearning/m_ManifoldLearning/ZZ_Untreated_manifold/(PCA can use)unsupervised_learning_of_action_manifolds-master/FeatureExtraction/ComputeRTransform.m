% New function to compute the radon transform at angles 45 degree apart
function R_vec = ComputeRTransform(img,num_levels,img_mask,varargin)
% Frames - an array containing frames of a video sequence
[rows,cols] = size(img);

%finding the radon transform of the Image
R = radon(img,0:5:179); % projections will be in columns
r = trapz(R.*R);

%dividing by the maximum
if(sum(r) ~= 0) % to avoid divide by zero condition
    R_vec = r/ sum(r);
else
    size_r = size(r);
    R_vec = zeros(size_r(1),size_r(2));
end

num_levels = num_levels - 1;

if(num_levels == 0)
    return;
end
len_limit = 5;

nVarags = length(varargin);
if(nVarags ~= 0)
    flagEqualDiv = varargin{1};
else
    flagEqualDiv = false;
end
if(~flagEqualDiv)
    [y,x,value] = find(bw_mask == 1);
    X = [x y];
    cent = median2D(X);
    cent_x = cent(1);
    cent_y = cent(2);
else
    cent_x = floor(cols/2);
    cent_y = floor(rows/2);
end

% this happens when the mask is square ( no zeros )
if( isnan(cent_x))
    cent_x = floor(cols/2);
end

if(isnan(cent_y))
    cent_y = floor(rows/2);
end

% To check for minimum row and col length
row_limit = false;
col_limit = false;
if(rows <= len_limit)
    row_limit = true;
end

if(cols <= len_limit)
    col_limit = true;
end

% Upper Left Block
if(row_limit)
    cent_y = rows;
end
if(col_limit)
    cent_x = cols;
end
sub_img = img(1:cent_y,1:cent_x);
sub_img_mask = img_mask(1:cent_y,1:cent_x);
R_vec_UL = ComputeRTransform(sub_img,num_levels,sub_img_mask,flagEqualDiv);

% Upper Right Block
if(row_limit)
    cent_y = rows;
end
if(col_limit)
    cent_x = 0;
end
sub_img = img(1:cent_y,cent_x+1:cols);
sub_img_mask = img_mask(1:cent_y,cent_x+1:cols);
R_vec_UR = ComputeRTransform(sub_img,num_levels,sub_img_mask,flagEqualDiv);

% Lower Left Block
if(row_limit)
    cent_y = 0;
end
if(col_limit)
    cent_x = cols;
end
sub_img = img(1+cent_y:rows,1:cent_x);
sub_img_mask = img_mask(1+cent_y:rows,1:cent_x);
R_vec_LL = ComputeRTransform(sub_img,num_levels,sub_img_mask,flagEqualDiv);

% Lower Right Block
if(row_limit)
    cent_y = 0;
end
if(col_limit)
    cent_x = 0;
end
sub_img = img(1+cent_y:rows,1+cent_x:cols);
sub_img_mask = img_mask(1+cent_y:rows,1+cent_x:cols);
R_vec_LR = ComputeRTransform(sub_img,num_levels,sub_img_mask,flagEqualDiv);

R_vec = [R_vec R_vec_UL R_vec_UR R_vec_LL R_vec_LR];


end