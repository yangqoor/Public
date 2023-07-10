% Function for computing pyramidal histogram of oriented flow
function H = HOOF(img_mag,img_dir,num_levels,bw_mask,B,varargin)

ind = find(bw_mask ~= 0);
if(length(ind) ~= 0)
    v_magnit = img_mag(ind);
    v_angles = img_dir(ind);
else
    v_magnit = img_mag(:);
    v_angles = img_dir(:);
end
[rows,cols] = size(img_mag);        
K=max(size(v_angles));
len_limit = 5;
%assembling the histogram with B bins (range of 360/B degrees per bin)        
bin=0;        
H2=zeros(B,1);
if(numel(v_angles) == 0)
    %disp('Problem 2');
    s_mesg = 'Problem 2';
else
    for ang_lim=-pi+2*pi/B:2*pi/B:pi
        bin=bin+1;        
        for k=1:K              
            if v_angles(k)<ang_lim        
                v_angles(k)=100;            
                H2(bin)=H2(bin)+v_magnit(k);             
            end        
        end
    end
end
%H2=H2/(norm(H2)+0.01);
H = H2';

num_levels = num_levels - 1;

if(num_levels == 0)
    return;
end

B = B/2;
% % Enclose the region of interest as much as possible.
% stats = regionprops(bw_mask,'BoundingBox');
% img_mag = imcrop(img_mag,stats(size(stats,1),1).BoundingBox);
% img_dir = imcrop(img_dir,stats(size(stats,1),1).BoundingBox);
% bw_mask = imcrop(bw_mask,stats(size(stats,1),1).BoundingBox);

[rows,cols] = size(img_mag);

% Find Centroid % VOID - USE median2D(X) to find centroid
% d = bwdist(~bw_mask);
% stats = regionprops(bw_mask,d,'WeightedCentroid');
% cent_x = floor(stats(1).WeightedCentroid(1));
% cent_y = floor(stats(1).WeightedCentroid(2));
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
sub_img_mag = img_mag(1:cent_y,1:cent_x);
sub_img_dir = img_dir(1:cent_y,1:cent_x);
sub_bw_mask = bw_mask(1:cent_y,1:cent_x);
H_UL = HOOF(sub_img_mag,sub_img_dir,num_levels,sub_bw_mask,B,flagEqualDiv);

% Upper Right Block
if(row_limit)
    cent_y = rows;
end
if(col_limit)
    cent_x = 0;
end
sub_img_mag = img_mag(1:cent_y,cent_x+1:cols);
sub_img_dir = img_dir(1:cent_y,cent_x+1:cols);
sub_bw_mask = bw_mask(1:cent_y,cent_x+1:cols);
H_UR = HOOF(sub_img_mag,sub_img_dir,num_levels,sub_bw_mask,B,flagEqualDiv);

% Lower Left Block
if(row_limit)
    cent_y = 0;
end
if(col_limit)
    cent_x = cols;
end
sub_img_mag = img_mag(1+cent_y:rows,1:cent_x);
sub_img_dir = img_dir(1+cent_y:rows,1:cent_x);
sub_bw_mask = bw_mask(1+cent_y:rows,1:cent_x);
H_LL = HOOF(sub_img_mag,sub_img_dir,num_levels,sub_bw_mask,B,flagEqualDiv);

% Lower Right Block
if(row_limit)
    cent_y = 0;
end
if(col_limit)
    cent_x = 0;
end
sub_img_mag = img_mag(1+cent_y:rows,1+cent_x:cols);
sub_img_dir = img_dir(1+cent_y:rows,1+cent_x:cols);
sub_bw_mask = bw_mask(1+cent_y:rows,1+cent_x:cols);
H_LR = HOOF(sub_img_mag,sub_img_dir,num_levels,sub_bw_mask,B,flagEqualDiv);

H = [H H_UL H_UR H_LL H_LR];

end