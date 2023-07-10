function [XPupil,YPupil,wavevector,wavevectorzmed,Waberration,PupilMatrix] = get_pupil_matrix(parameters)
% This function calculates the pupil matrix Q_{jk}, which gives the j-th
% electric field component proportional to the k-th dipole vector
% component.
%
% copyright Sjoerd Stallinga, TU Delft, 2017

% parameters: NA, refractive indices of medium, cover slip, immersion fluid,
% wavelength (in nm), sampling in pupil
NA = parameters.NA;
refmed = parameters.refmed;
refcov = parameters.refcov;
refimm = parameters.refimm;
refimmnom = parameters.refimmnom;
lambda = parameters.lambda;
Npupil = parameters.Npupil;

% pupil radius (in diffraction units) and pupil coordinate sampling
PupilSize = 1.0;
DxyPupil = 2*PupilSize/Npupil;
XYPupil = -PupilSize+DxyPupil/2:DxyPupil:PupilSize;
[YPupil,XPupil] = meshgrid(XYPupil,XYPupil);

% calculation of relevant Fresnel-coefficients for the interfaces
% between the medium and the cover slip and between the cover slip
% and the immersion fluid
CosThetaMed = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refmed^2);
CosThetaCov = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refcov^2);
CosThetaImm = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refimm^2);
CosThetaImmnom = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refimmnom^2);
pmed = refmed./CosThetaMed;
smed = refmed.*CosThetaMed;
pcov = refcov./CosThetaCov;
scov = refcov.*CosThetaCov;
pimm = refimm./CosThetaImm;
simm = refimm.*CosThetaImm;
FresnelPmedcov = 2*(refmed/refcov)*pcov./(pmed+pcov);
FresnelSmedcov = 2*smed./(smed+scov);
FresnelPcovimm = 2*(refcov/refimm)*pimm./(pcov+pimm);
FresnelScovimm = 2*scov./(scov+simm);
FresnelP = FresnelPmedcov.*FresnelPcovimm;
FresnelS = FresnelSmedcov.*FresnelScovimm;

% setting of vectorial functions
Phi = atan2(YPupil,XPupil);
CosPhi = cos(Phi);
SinPhi = sin(Phi);
CosTheta = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refmed^2);
SinTheta = sqrt(1-CosTheta.^2);

pvec{1} = FresnelP.*CosTheta.*CosPhi;
pvec{2} = FresnelP.*CosTheta.*SinPhi;
pvec{3} = -FresnelP.*SinTheta;
svec{1} = -FresnelS.*SinPhi;
svec{2} = FresnelS.*CosPhi;
svec{3} = 0;

PolarizationVector = cell(2,3);
for jtel = 1:3
  PolarizationVector{1,jtel} = CosPhi.*pvec{jtel}-SinPhi.*svec{jtel};
  PolarizationVector{2,jtel} = SinPhi.*pvec{jtel}+CosPhi.*svec{jtel};
end

% definition aperture
ApertureMask = double((XPupil.^2+YPupil.^2)<1.0);

% aplanatic amplitude factor
Amplitude = ApertureMask./(CosTheta.^(1/2));

% calculation aberration function
Waberration = zeros(size(XPupil));
orders = parameters.aberrations(:,1:2);
zernikecoefs = squeeze(parameters.aberrations(:,3));
normfac = sqrt(2*(orders(:,1)+1)./(1+double(orders(:,2)==0)));
zernikecoefs = normfac.*zernikecoefs;
allzernikes = get_zernikefunctions(orders,XPupil,YPupil);
for j = 1:numel(zernikecoefs)
  Waberration = Waberration+zernikecoefs(j)*squeeze(allzernikes(j,:,:));  
end

% compute effect of refractive index mismatch, in this function we set NA=refmed
% when actually NA>refmed, so it is not fully correct for TIRF-conditions
% zvals = [nominal stage position, free working distance, -image depth from cover slip]
[zvals,~] = get_rimismatchpars(parameters);
Waberration = Waberration+zvals(1)*refimm*CosThetaImm-zvals(2)*refimmnom*CosThetaImmnom-zvals(3)*refmed*CosThetaMed;

PhaseFactor = exp(2*pi*1i*Waberration/lambda);
Waberration = Waberration.*ApertureMask;

% compute pupil matrix
PupilMatrix = cell(2,3);
for itel = 1:2
  for jtel = 1:3
    PupilMatrix{itel,jtel} = Amplitude.*PhaseFactor.*PolarizationVector{itel,jtel};
  end
end

% calculate intensity normalization by flow of energy through lens aperture
[normint_free,normint_fixed] = get_normalization(PupilMatrix,parameters);
for itel = 1:2
  for jtel = 1:3
    if strcmp(parameters.dipoletype,'free')
      PupilMatrix{itel,jtel} = PupilMatrix{itel,jtel}/sqrt(normint_free);
    end
    if strcmp(parameters.dipoletype,'fixed')
      PupilMatrix{itel,jtel} = PupilMatrix{itel,jtel}/sqrt(normint_fixed);
    end
  end
end

% calculate wavevector inside immersion fluid and z-component inside medium 
wavevector = cell(1,3);
wavevector{1} = (2*pi*NA/lambda)*XPupil;
wavevector{2} = (2*pi*NA/lambda)*YPupil;
wavevector{3} = (2*pi*refimm/lambda)*CosThetaImm;
wavevectorzmed = (2*pi*refmed/lambda)*CosThetaMed; 

% plotting intermediate results
if parameters.debugmode
  figure
  for itel = 1:2
    for jtel = 1:3
      tempim = PupilMatrix{itel,jtel};
      subplot(2,3,3*(itel-1)+jtel)
      imagesc(abs(tempim))
      title(strcat('amplitude i=',num2str(itel),', j=',num2str(jtel)))
      axis square
      axis off
    end
  end
  figure
  for itel = 1:2
    for jtel = 1:3
      tempim = PupilMatrix{itel,jtel};
      subplot(2,3,3*(itel-1)+jtel)
      imagesc(angle(tempim)*180/pi)
      title(strcat('phase i=',num2str(itel),', j=',num2str(jtel)))
      axis square
      axis off
    end
  end
end

end