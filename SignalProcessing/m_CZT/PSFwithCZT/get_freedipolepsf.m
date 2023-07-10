function [PSF] = get_freedipolepsf(FieldMatrix,parameters)
% This function calculates the free dipole PSF given the field matrix.
%
% copyright Sjoerd Stallinga, TU Delft, 2017

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

% calculation of free dipole PSF 
PSF = zeros(Mx,My,Mz);
for jz = 1:Mz
  for jtel = 1:3
    for itel = 1:2
      PSF(:,:,jz) = PSF(:,:,jz) + (1/3)*abs(FieldMatrix{itel,jtel,jz}).^2;
    end
  end
end

% normalization by power flux through lens aperture
PSF = PSF/parameters.normint_free;

% plotting intermediate results
if parameters.debugmode
  sumPSF = squeeze(sum(sum(PSF)));
  figure
  plot(sumPSF)
  title('collection efficiency ROI')
end

end

