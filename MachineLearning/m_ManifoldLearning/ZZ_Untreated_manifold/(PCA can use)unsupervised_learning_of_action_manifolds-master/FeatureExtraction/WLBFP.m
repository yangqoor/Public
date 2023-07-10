% Function to compute the weighted local binary flow patterns - the weights are
% given by the mean of the optical flow magnitude in that neighbourhood
function L = WLBFP(img_mag,img_dir,num_levels,bw_mask,num_bins,mapping,varargin)

% computing the local mean magnitude of optical flow
f_h = 1/9 *[1 1 1; 1 1 1; 1 1 1];
img_mag = imfilter(img_mag,f_h);

% compute the quantized directions
D_dir= QuantizeDirection(img_dir,num_bins);
D_dir = padarray(D_dir,(size(f_h)-1)/2);
mapping=getmapping(8,'u2'); 
% Compute the local binary flow pattern directional image
%mapping.table = 0:1:255;
%mapping.num = 256;
L_img = lgobp(D_dir,1,8,mapping,'none'); 
%L_img = lbp(D_dir,1,8,mapping,'none');

% Getting only the magnitude on and within the silhouette region
ind = find(bw_mask ~= 0);
if(length(ind) ~= 0)
    v_img_mag = img_mag(ind);
    v_img_L = L_img(ind);
else
    v_img_mag = img_mag(:);
    v_img_L = L_img(:);
end

% applying the mapping
for k = 1:1:length(v_img_L)
    v_img_L(k) = mapping.table(v_img_L(k)+1);
end

%assembling the histogram with B bins (range of 360/B degrees per bin)        
bin=0;        
L2=zeros(mapping.num-1,1);
K = length(v_img_L);
[rows,cols] = size(img_mag);  
len_limit = 5;

for L_lim = 1:1:mapping.num-1 % excluding pattern 0 s
    bin=bin+1;        
    for k=1:K              
        if v_img_L(k) == L_lim;        
            v_img_L(k)=mapping.num+1;            
            %L2(bin)=L2(bin)+v_img_mag(k);
            L2(bin) = L2(bin) + 1;
        end        
    end
end
%L2=L2/(norm(L2)+0.01);
L = L2';

num_levels = num_levels - 1;

if(num_levels == 0)
    return;
end

%num_bins = num_bins / 2;
num_bins = num_bins * 2;

[rows,cols] = size(img_mag);
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
L_UL = WLBFP(sub_img_mag,sub_img_dir,num_levels,sub_bw_mask,num_bins,mapping,flagEqualDiv);

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
L_UR = WLBFP(sub_img_mag,sub_img_dir,num_levels,sub_bw_mask,num_bins,mapping,flagEqualDiv);

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
L_LL = WLBFP(sub_img_mag,sub_img_dir,num_levels,sub_bw_mask,num_bins,mapping,flagEqualDiv);

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
L_LR = WLBFP(sub_img_mag,sub_img_dir,num_levels,sub_bw_mask,num_bins,mapping,flagEqualDiv);

L = [L L_UL L_UR L_LL L_LR];

end