function parameters = set_parameters
% This function sets all parameters for vectorial PSF calculations

% parameters: NA, refractive indices of medium, cover slip, immersion fluid,
% nominal value of immersion fluid refractive index matching objective lens
% design, nominal free working distance (in nm), distance image plane from
% cover slip (in nm), wavelength (in nm), emitter position (in nm) with
% z-position from image plane, spot footprint (in nm), axial range min/max
% (in nm), flag for axial range by z-position in medium or by z-stage
% position, sampling in pupil with, sampling in image plane, sampling in
% axial direction.
%
% copyright Sjoerd Stallinga, TU Delft, 2017

parameters.NA = 1.45;
parameters.refmed = 1.52;
parameters.refcov = 1.52;
parameters.refimm = 1.52;
parameters.refimmnom = parameters.refcov;
parameters.fwd = 140e3;
parameters.depth = 500;
parameters.lambda = 520.0;
parameters.xemit = 0.0;
parameters.yemit = 0.0;
parameters.zemit = 0.0;
parameters.Npupil = 128;
parameters.zrange = [-2500,2500];
% parameters.ztype = 'medium';
parameters.ztype = 'stage';
parameters.pixelsize = 30;
parameters.Mx = 257;
parameters.My = 257;
parameters.Mz = 257;

parameters.xrange = parameters.pixelsize*parameters.Mx/2;
parameters.yrange = parameters.pixelsize*parameters.My/2;

% sanity check on position emitter w.r.t. cover slip
if strcmp(parameters.ztype,'stage')
  zcheck = parameters.depth+parameters.zemit;
end
if strcmp(parameters.ztype,'medium')
  zmin = parameters.zrange(1);
  zcheck = zmin+parameters.depth+parameters.zemit;
end
if (zcheck<0)
  fprintf('Warning! Emitter must be above the cover slip:\n')
  fprintf('Adjust parameter settings for physical results.\n')  
end

% sanity check on refractive index values
if (parameters.NA>parameters.refimm)
  fprintf('Warning! Refractive index immersion medium cannot be smaller than NA.\n')
end
if (parameters.NA>parameters.refcov)
  fprintf('Warning! Refractive index cover slip cannot be smaller than NA.\n')
end

% support size for OTF in spatial frequency space
parameters.supportsize = 2.0*parameters.NA/parameters.lambda;
parameters.Nsupport = 256;
parameters.supportsizez = 3.0*(parameters.refimm-sqrt(parameters.refimm^2-parameters.NA^2))/parameters.lambda;
parameters.Nsupportz = 256;
parameters.shiftsupport = [0.5 0.5 0.5];

% aberrations (Zernike orders [n1,m1,A1,n2,m2,A2,...] with n1,n2,... the
% radial orders, m1,m2,... the azimuthal orders, and A1,A2,... the Zernike
% coefficients in lambda rms, so 0.072 means diffraction limit)
parameters.aberrations = [1,1,0.0; 1,-1,-0.0; 2,0,-0.0; 4,0,0.0; 2,-2,0.0; 2,2,0.0; 4,-2,0.0];
parameters.aberrations(:,3) =  parameters.aberrations(:,3)*parameters.lambda;

% parameters needed for fixed dipole PSF only: emitter/absorber dipole
% orientation (characterized by angles pola and azim), detection/illumination
% polarization in objective lens back aperture (characterized by angles
% alpha and beta).
parameters.dipoletype = 'free';
% parameters.dipoletype = 'fixed';
parameters.pola = 45.0*pi/180;
parameters.azim = 0.0*pi/180;
parameters.polarizationpupil = false;
parameters.alpha = 45.0*pi/180;
parameters.beta = 45.0*pi/180;

% flag for making intermediate plots
parameters.debugmode = 0;

end

