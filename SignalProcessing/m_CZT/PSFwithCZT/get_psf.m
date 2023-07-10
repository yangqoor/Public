function [PSF] = get_psf(FieldMatrix,parameters)
% This function calculates the free or fixed dipole PSFs given the field
% matrix, the dipole orientation, and the pupil polarization.
% Point Spread Function, PSF

% parameters: emitter/absorber dipole orientation (characterized by angles
% pola and azim), detection/illumination polarization in objective lens
% back aperture (characterized by angles alpha and beta).
%
% copyright Sjoerd Stallinga, TU Delft, 2017

pola = parameters.pola;
azim = parameters.azim;
polarizationpupil = parameters.polarizationpupil;
alpha = parameters.alpha;
beta = parameters.beta;

dipor(1) = sin(pola)*cos(azim);
dipor(2) = sin(pola)*sin(azim);
dipor(3) = cos(pola);

polpupil(1) = cos(alpha)*exp(1i*beta);
polpupil(2) = sin(alpha)*exp(-1i*beta);

dims = size(FieldMatrix);
if (length(dims)>2)
  Mz = dims(3);
  imdims = size(FieldMatrix{1,1,1});
else
  Mz = 1;
  imdims = size(FieldMatrix{1,1});
end
Mx = imdims(1);
My = imdims(2);

% calculation of free and fixed dipole PSF 
PSF = zeros(Mx,My,Mz);

for jz = 1:Mz
  
% calculation of free PSF
  if strcmp(parameters.dipoletype,'free')
    for jtel = 1:3
      if (polarizationpupil)
        Ec = polpupil(1)*FieldMatrix{1,jtel,jz}+polpupil(2)*FieldMatrix{2,jtel,jz};
        PSF(:,:,jz) = PSF(:,:,jz) + (1/3)*abs(Ec).^2;
      else
        for itel = 1:2
          PSF(:,:,jz) = PSF(:,:,jz) + (1/3)*abs(FieldMatrix{itel,jtel,jz}).^2;
        end
      end
    end
  end
  
% calculation of fixed PSF 
  if strcmp(parameters.dipoletype,'fixed')
    Ex = dipor(1)*FieldMatrix{1,1,jz}+dipor(2)*FieldMatrix{1,2,jz}+dipor(3)*FieldMatrix{1,3,jz};
    Ey = dipor(1)*FieldMatrix{2,1,jz}+dipor(2)*FieldMatrix{2,2,jz}+dipor(3)*FieldMatrix{2,3,jz};
    if (polarizationpupil)
      Ec = polpupil(1)*Ex+polpupil(2)*Ey;
      PSF(:,:,jz) = abs(Ec).^2;
    else
      PSF(:,:,jz) = abs(Ex).^2+abs(Ey).^2;
    end
  end
end

% plotting intermediate results
if parameters.debugmode
  sumPSF = squeeze(sum(sum(PSF)));
  figure
  plot(sumPSF)
  title('collection efficiency ROI')
end

end

