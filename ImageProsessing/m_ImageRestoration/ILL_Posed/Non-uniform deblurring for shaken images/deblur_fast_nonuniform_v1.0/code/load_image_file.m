% Author:     Oliver Whyte <oliver.whyte@ens.fr>
% Date:       January 2012
% Copyright:  2012, Oliver Whyte
% Reference:  O. Whyte, J. Sivic, A. Zisserman, and J. Ponce. "Non-uniform Deblurring for Shaken Images". IJCV, 2011 (accepted).
%             O. Whyte, J. Sivic and A. Zisserman. "Deblurring Shaken and Partially Saturated Images". In Proc. CPCV Workshop at ICCV, 2011.
% URL:        http://www.di.ens.fr/willow/research/deblurring/, http://www.di.ens.fr/willow/research/saturation/

function [K,a,im,respfn,invrespfn,initial_scale] = load_image_file(filename,max_dim,israw,focal_length_in_35mm)
if nargin < 2, max_dim = inf; end
mmperinch = 25.4;
inchespermm = 0.0393700787;
[pathstr,name,ext] = fileparts(filename);
% If israw is not provided, try to guess by file extension
if ~exist('israw','var') || isempty(israw)
    if strcmp(ext,'.tiff') || strcmp(ext,'.tif')
        israw = true;
    else
        israw = false;
    end
end
% Load image
im = imread(filename);
im = double(im)/(double(cast(inf,class(im)))+1);
% Discard alpha channel if present
im = im(:,:,1:min(size(im,3),3));
% Load exif from jpeg file
try
    exif_info = exifread(filename);
catch
    warning('could not get exif info from image itself, trying jpeg version of image... ')
    if ~exist('jpgname','var') || isempty(jpgname)
                                   jpgname = fullfile(pathstr,[name '.JPG']);
        if ~exist(jpgname,'file'), jpgname = fullfile(pathstr,[strrep(name,'_pt','') '.JPG']); end
        if ~exist(jpgname,'file'), jpgname = fullfile(pathstr,[name '.jpg']); end
        if ~exist(jpgname,'file'), jpgname = fullfile(pathstr,[strrep(name,'_pt','') '.jpg']); end
    end
    try
        exif_info = exifread(jpgname);
        disp('OK')
    catch
        warning('could not get exif info from image itself, trying .exif file... ')
        if exist(strrep(filename,ext,'.exif'),'file')
            exif_info = load('-MAT',strrep(filename,ext,'.exif'));
            disp('OK')
        else
            warning('could not get exif info from .exif file')
            exif_info = [];
        end
    end
end

% Defaults
f = 0;
respfn    = @(x) linear2srgb(max(min(x,1),0));
invrespfn = @(x) srgb2linear(max(min(x,1),0));
a = 1;

% Get focal length for image
% Was focal length manually specified?
if exist('focal_length_in_35mm','var') && ~isempty(focal_length_in_35mm)
    f = focal_length_in_35mm/36*max(size(im));
end
if ~isempty(exif_info)
    % Get camera make and model
    camera_name = lower([strrep(exif_info.Make,' ','') strrep(exif_info.Model,' ','')]);
    % Some cameras give a useable focal length directly in EXIF -- not all cameras give this however
    if f==0 && isfield(exif_info,'FocalLengthIn35mmFilm')
        f = exif_info.FocalLengthIn35mmFilm/36*max(size(im));
    end
    % Try to find camera in database
    if f==0 && isfield(exif_info,'FocalLength')
        fid = fopen('sensor_sizes.m');
        sensors = textscan(fid,'"%[^"]"=>%f,%*[^\n]');
        fclose(fid);
        ndx = strmatch(camera_name, sensors{1}, 'exact');
        if ~isempty(ndx) && sensors{2}(ndx)~=0
            % Found the camera
            ccdwidth = sensors{2}(ndx);
            f = exif_info.FocalLength/ccdwidth*max(size(im));
        end
    end
end
% If all attempts to get focal length failed, then f will still be equal to zero
if f==0
    warning('Could not find focal length for image. Either specify focal length manually by setting the variable ''focal_length_in_35mm_shake'', or add your camera''s CCD width to the list in sensor_sizes.txt (dpreview.com is a good place to look for CCD widths)');
    f = 2*max(size(im));
end

% Get response function and inverse if known
if ~isempty(exif_info)
    switch lower([strrep(exif_info.Make,' ','') strrep(exif_info.Model,' ','')])
        case {'canoncanondigitalixus70','canoncanonpowershota6'}
            v = -4.189383805883115;
            respfn    = @(x) (1-exp(v*max(min(x,1),0)))/(1-exp(v));
            invrespfn = @(x) log(1-max(min(x,1),0)*(1-exp(v)))/v;
    end
    % Scale factor to normalize the amount of light seen
    a = 1/(exif_info.ISOSpeedRatings*exif_info.ExposureTime) * (exif_info.FNumber^2);
else
    warning('Exif information empty');
end
% Override non-linear response if the image is raw
if israw
    respfn    = @(x) x;
    invrespfn = @(x) x;
end

% Calibration matrix assuming square pixels and principal point at image centre
x0 = (1+size(im,2))/2;      y0 = (1+size(im,1))/2;
K = [f, 0, x0;...
     0, f, y0;...
     0, 0, 1 ];
% Resize if required
initial_scale = min(max_dim/max(size(im)), 1);
if exist('imresize_old') == 2
    imresizefn = @imresize_old;
else
    imresizefn = @imresize;
end
im = max(min(imresizefn(im,initial_scale,'bilinear'),1),0);
% Adjust calibration matrix, given that imresize aligns (0.5,0.5)
%     in the large image with (0.5,0.5) in the small image
K = [1, 0, 0.5;...
     0, 1, 0.5;...
     0, 0, 1  ]...
     * ...
    [initial_scale, 0,             0;...
     0,             initial_scale, 0;...
     0,             0,             1]...
     * ...
    [1, 0, -0.5;...
     0, 1, -0.5;...
     0, 0, 1   ]...
     * ...
     K;

