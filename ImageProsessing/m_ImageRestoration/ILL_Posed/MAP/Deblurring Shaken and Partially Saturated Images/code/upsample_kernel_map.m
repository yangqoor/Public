
%	Author:		Oliver Whyte <oliver.whyte@ens.fr>
%	Date:		November 2011
%	Copyright:	2011, Oliver Whyte
%	Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%	URL:		http://www.di.ens.fr/willow/research/saturation/

function kernel_up = upsample_kernel_map(k_s_full,tt_s,tt_up,scale_ratio_k)
for i=1:3
    tt_s{i} = reshape(tt_s{i},size(k_s_full));
end
% Get amount to multiply tt_up by (necessary for uniform kernels)
if nargin < 4, scale_ratio_k = 1; end
for i=1:3
	tt_up{i} = tt_up{i}*scale_ratio_k;
end

% Angles for CSF, not necessarily centred on 0
khh = ceil(size(tt_s{i},1)/2); % half height
khw = ceil(size(tt_s{i},2)/2); % half width
khd = ceil(size(tt_s{i},3)/2); % half depth

% Find size of smallest array which covers same range of angles (or translations) as full-res kernel
khh_up = ceil(size(tt_up{i},1)/2);
khw_up = ceil(size(tt_up{i},1)/2);
khd_up = ceil(size(tt_up{i},1)/2);

tty_up = tt_up{1};
ttx_up = tt_up{2};
ttz_up = tt_up{3};

ksize_s = ones(1,3);
ksize_s(1:ndims(k_s_full)) = size(k_s_full);
nsdims_s = ksize_s > 1;
ksize_up = ones(1,3);
ksize_up(1:ndims(ttx_up)) = size(ttx_up);
nsdims_up = ksize_up > 1;
% If going from 1d to 2d, or 2d to 3d, pad larger kernel to allow use of
% higher dimension interpolation function
% Find a non-singular dimension
nsdim = find(nsdims_up & nsdims_s,1);
% Get ratio of grid spacings along that dimension, between the two scales
tgs_ratio = median(diff(unique(tt_s{nsdim}))) / median(diff(unique(tt_up{nsdim})));
for sdim = find(nsdims_up & ~nsdims_s)
    % Pad kernel along singular dimension with a layer of zeros either side
    k_s_full = cat(sdim,zeros(size(k_s_full)),k_s_full,zeros(size(k_s_full)));
    % Extend theta arrays:
    tgs_up_sdim = median(diff(unique(tt_up{sdim})));
	tgs_s_sdim = tgs_up_sdim * tgs_ratio;
    % For singular dimension, extrapolate values
    tt_s{sdim} = cat(sdim,tt_s{sdim}-tgs_s_sdim,tt_s{sdim},tt_s{sdim}+tgs_s_sdim);
    % For other dimensions, replicate values
    repmatdims = [1, 1, 1];      repmatdims(sdim) = 3;
    for nsdim = find([1, 2, 3] ~= sdim)
        tt_s{nsdim} = repmat(tt_s{nsdim},repmatdims);
    end
end
tty_s = squeeze(tt_s{1});
ttx_s = squeeze(tt_s{2});
ttz_s = squeeze(tt_s{3});
tty_up = squeeze(tt_up{1});
ttx_up = squeeze(tt_up{2});
ttz_up = squeeze(tt_up{3});
k_s_full = squeeze(k_s_full);
if nnz(nsdims_up) == 3
    k_up = interp3(ttx_s,tty_s,ttz_s,k_s_full,ttx_up,tty_up,ttz_up,'linear',0);
elseif nnz(nsdims_up) == 2
    if ksize_up(1) == 1
        k_up = interp2(ttx_s,ttz_s,k_s_full,ttx_up,ttz_up,'*linear',0);
    elseif ksize_up(2) == 1
        k_up = interp2(tty_s,ttz_s,k_s_full,tty_up,ttz_up,'*linear',0);
    else % ksize_up(3) == 1
        k_up = interp2(ttx_s,tty_s,k_s_full,ttx_up,tty_up,'*linear',0);
    end
else % nnz(nsdims_up) == 1
    if ksize_up(1) > 1
        k_up = interp1(tty_s,k_s_full,tty_up,'linear',0);
    elseif ksize_up(2) > 1
        k_up = interp1(ttx_s,k_s_full,ttx_up,'linear',0);
    else % ksize_up(3) > 1
        k_up = interp1(ttz_s,k_s_full,ttz_up,'linear',0);
    end
end
kernel_up = reshape(k_up,size(tt_up{1}));
