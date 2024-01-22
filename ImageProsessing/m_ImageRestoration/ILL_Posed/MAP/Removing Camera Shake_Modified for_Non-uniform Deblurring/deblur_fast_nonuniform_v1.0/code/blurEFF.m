% imblur = blurEFF(eff, imsharp[_fft], kernel[_fft], sense, fft_conv)
%       if eff is already set-up, imsharp is already padded
%       if imsharp or kernel are complex, they are assumed to be already in 
%           the form of stacks of Fourier-transformed patches
% imblur = blurEFF(imsharp, kernel, theta_list, Ksharp, sense, fft_conv)
%       nothing is setup or precomputed yet

%    Author:        Oliver Whyte <oliver.whyte@ens.fr>
%    Date:        November 2011
%    Copyright:    2011, Oliver Whyte
%    Reference:  O. Whyte, J. Sivic and A. Zisserman. ``Deblurring Shaken and Partially Saturated Images''. In Proc. CPCV Workshop at ICCV, 2011.
%    URL:        http://www.di.ens.fr/willow/research/saturation/

function imblur = blurEFF(varargin)
sequential = true; % sequential computation => significant reduction in memory use, but may be slower

% Did we receive a pre-computed EFF structure?
if isstruct(varargin{1})
    eff = varargin{1};
    varargin(1) = []; % delete from arguments
else
    theta_list = varargin{3};
    Ksharp = varargin{4};
    varargin(3:4) = []; % delete from arguments
end

% Get the rest of the arguments
imsharp = varargin{1};
kernel = varargin{2};
if length(varargin) < 3 || isempty(varargin{3})
    sense = 'conv';
else
    sense = varargin{3};
end
if length(varargin) < 4 || isempty(varargin{4})
    fft_conv = true;
else
    fft_conv = varargin{4};
end

% Set patch extract / combine flags depending on sense of the blur
if strcmp(sense,'conv')
    extract_flag = 'sharp';
    combine_flag = 'blurry';
else
    extract_flag = 'blurry';
    combine_flag = 'sharp';
end        

if exist('eff','var')
    depad = false;
else
    % Remove empty kernel elements
    theta_list = theta_list(:,kernel~=0);
    kernel = kernel(kernel~=0);
    grid_size = [6 8];
    % Make the EFF structure
    eff = makeEFF(size(imsharp(:,:,1)), theta_list, grid_size, Ksharp);
    imsharp = padImage(imsharp, eff.pad, 0);
    depad = true;
end

% Set up access to the sharp image and kernel, depending on options and what has been precomputed
if ndims(imsharp) <= 3
    % We received the full image, so we will need to extract the patches
    if sequential
        % Anonymous function to compute one patch from the stack
        imsharp_stack = @(p) computeImageStackEFF(eff, imsharp, extract_flag, fft_conv, p);
    else
        % Precompute the whole stack of patches
        imsharp_stack = computeImageStackEFF(eff, imsharp, extract_flag, fft_conv);
    end
else
    % We received a pre-computed stack of patches
    if sequential
        % Anonymous function to get one slice of the stack
        imsharp_stack = @(p) imsharp(:,:,:,p);
    else
        imsharp_stack = imsharp;
    end
end

if ndims(kernel) <= 3
    % We received the kernel, so we will need to compute the filters
    if sequential
        % Anonymous function to compute one local PSF
        kernel_stack = @(p) computeFilterStackEFF(eff, kernel, fft_conv, p);
    else
        % Precompute whole stack of local PSFs
        kernel_stack = computeFilterStackEFF(eff, kernel, fft_conv);
    end
else
    % We received the whole stack of precomputed filters
    if sequential
        % Anonymous function to get one PSF from the stack
        kernel_stack = @(p) kernel(:,:,:,p);
    else
        kernel_stack = kernel;
    end
end


h_padded = eff.padded_size(1);
w_padded = eff.padded_size(2);
channels = size(imsharp,3);

h_grid = eff.grid_size(1);
w_grid = eff.grid_size(2);
n_grid = h_grid * w_grid;
h_patch = eff.patch_size(1);
w_patch = eff.patch_size(2);
t_patch = eff.t_patch;
b_patch = eff.b_patch;
l_patch = eff.l_patch;
r_patch = eff.r_patch;

if sequential
    imblur = [];
    for gi=1:n_grid
        % Extract sharp patch and psf
        imsharp_patch = imsharp_stack(gi);
        kernel_patch = kernel_stack(gi);
        if fft_conv
            % Compute product of sharp image patches and filters
            if strcmp(sense,'conv')
                imblur_patch = bsxfun(@times, imsharp_patch, kernel_patch);
            else
                imblur_patch = bsxfun(@times, imsharp_patch, conj(kernel_patch));
            end
        else
            imblur_patch = imfilter(imsharp_patch,kernel_patch,sense,'same');
        end
        % Add blurry patch to output
        imblur = recombineImageStackEFF(eff, imblur_patch, combine_flag, fft_conv, imblur, gi);
    end
else
    if fft_conv
        % Compute product of sharp image patches and filters
        if strcmp(sense,'conv')
            imblur_patches = bsxfun(@times, imsharp_stack, kernel_stack);
        else
            imblur_patches = bsxfun(@times, imsharp_stack, conj(kernel_stack));
        end        
    else
        error('Cannot perform non-fft blurring of all patches in parallel');
    end
    imblur = recombineImageStackEFF(eff, imblur_patches, combine_flag, fft_conv);
end

if depad
    imblur = padImage(imblur, -eff.pad, 0);
end
