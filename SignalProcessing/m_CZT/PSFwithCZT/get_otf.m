function [XSupport,YSupport,OTF] = get_otf(PSF,XImage,YImage,parameters)
% This function calculates the through-focus OTF via FT of the through focus PSF

% parameters: NA, wavelength (in nm), spot footprint (in nm), axial range
% (in nm), sampling in Fourier space with (even), sampling in image plane
% (odd), sampling in axial direction.
%
% copyright Sjoerd Stallinga, TU Delft, 2017

ImageSizex = parameters.xrange;
ImageSizey = parameters.yrange;
SupportSize = parameters.supportsize;
Nsupport = parameters.Nsupport;
Mx = size(PSF,1);
My = size(PSF,2);
Mz = size(PSF,3);

% OTF support and sampling (in physical units) 
DxySupport = 2*SupportSize/Nsupport;
delqx = parameters.shiftsupport(1)*DxySupport;
delqy = parameters.shiftsupport(2)*DxySupport;
XYSupport = -SupportSize+DxySupport/2:DxySupport:SupportSize;
[XSupport,YSupport] = meshgrid(XYSupport-delqx,XYSupport-delqy);

% calculate auxiliary vectors for chirpz
[Ax,Bx,Dx] = prechirpz(ImageSizex,SupportSize,Mx,Nsupport);
[Ay,By,Dy] = prechirpz(ImageSizey,SupportSize,My,Nsupport);

% calculation of through-focus OTF
% for each focus level the OTF peak is normalized to one
OTF = zeros(Nsupport,Nsupport,Mz);
for jz = 1:Mz
  PSFslice = squeeze(PSF(:,:,jz));
  PSFslice = exp(-2*pi*1i*(delqx*XImage+delqy*YImage)).*PSFslice;
  IntermediateImage = transpose(cztfunc(PSFslice,Ay,By,Dy));
  tempim = transpose(cztfunc(IntermediateImage,Ax,Bx,Dx));
  OTF(:,:,jz) = tempim/max(max(abs(tempim)));
end

% plotting intermediate results
if parameters.debugmode
  jz = ceil(Mz/2);
  tempim = abs(squeeze(OTF(:,:,jz)));
  radialmeanMTF = im2mat(radialmean(tempim));
  radialmeanMTF = radialmeanMTF/max(radialmeanMTF);
  qvec = (0:(length(radialmeanMTF)-1))*DxySupport;
  figure
  plot(qvec*parameters.lambda/parameters.NA,radialmeanMTF)
  xlabel('spatial frequency [NA/\lambda]')
%   plot(qvec,radialmeanMTF)
%   xlabel('spatial frequency [nm^{-1}]')
  ylabel('radial average MTF')
end

end

