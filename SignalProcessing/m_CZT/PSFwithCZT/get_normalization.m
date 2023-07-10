function [normint_free,normint_fixed] = get_normalization(PupilMatrix,parameters)
% This function computes the PSF normalization by evaluating the energy
% flow through the lens aperture
%
% copyright Sjoerd Stallinga, TU Delft, 2017

% parameters
Npupil = parameters.Npupil;
NA = parameters.NA;
lambda = parameters.lambda;
pixelsize = parameters.pixelsize;
pola = parameters.pola;
azim = parameters.azim;

% dipole unit vector
dipor(1) = sin(pola)*cos(azim);
dipor(2) = sin(pola)*sin(azim);
dipor(3) = cos(pola);

% intensity matrix
IntensityMatrix = zeros(3,3);
for itel = 1:3
  for jtel = 1:3
    for ztel = 1:2
      pupmat1 = PupilMatrix{ztel,itel};
      pupmat2 = PupilMatrix{ztel,jtel};
      IntensityMatrix(itel,jtel) = IntensityMatrix(itel,jtel)+...
        sum(sum(real(pupmat1.*conj(pupmat2))));
    end
  end
end

% normalization to take into account discretization correctly
DxyPupil = 2*NA/lambda/Npupil;
normfac = DxyPupil^2/(pixelsize)^2;
IntensityMatrix = normfac*IntensityMatrix;

% evaluation normalization factors
normint_free = sum(diag(IntensityMatrix))/3;
normint_fixed = dipor*(IntensityMatrix*transpose(dipor));

end

