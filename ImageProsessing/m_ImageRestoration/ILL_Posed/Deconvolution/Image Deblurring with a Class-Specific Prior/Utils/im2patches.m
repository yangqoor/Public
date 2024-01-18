% function to convert an image into patches according to a possible mask
% note that for now im has to be a grayscale image
function [patches grid_xx grid_yy] = im2patches(im,patchSize,intervalSize,mask,boundarySize)

%grid xx/yy are the centers of patches.

if exist('boundarySize','var')~=1
    boundarySize = patchSize;
end
if boundarySize < patchSize
    error('The boundary size must be equal to or greater than the patch size!');
end

% the grid of a patch
[p_xx,p_yy]=meshgrid(-patchSize:patchSize,-patchSize:patchSize); %size*2+1 by size*2+1, size=radius?
nDim = numel(p_xx);

[height,width]=size(im);

[grid_xx,grid_yy]=meshgrid(boundarySize+1:intervalSize:width-boundarySize,boundarySize+1:intervalSize:height-boundarySize);

grid_xx = grid_xx(:); grid_yy = grid_yy(:); % columns

if exist('mask','var')==1
    if ~isempty(mask)
        index = mask(sub2ind([height,width],grid_yy(:),grid_xx(:)))>0.5;
        grid_xx = grid_xx(index);
        grid_yy = grid_yy(index);
    end
end

nPatches = numel(grid_xx);

xx = repmat(p_xx(:)',[nPatches,1]) + repmat(grid_xx(:),[1,nDim]);
yy = repmat(p_yy(:)',[nPatches,1]) + repmat(grid_yy(:),[1,nDim]);
index = sub2ind([height,width],yy(:),xx(:));

patches = reshape(im(index),[nPatches,nDim]);
