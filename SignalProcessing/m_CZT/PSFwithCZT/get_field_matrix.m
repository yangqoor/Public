function [XImage,YImage,ZImage,FieldMatrix] = get_field_matrix(PupilMatrix,wavevector,wavevectorzmed,parameters)
% This function calculates the field matrix A_{jk}, which gives the j-th
% electric field component proportional to the k-th dipole vector
% component, as well as the derivatives of A_{jk} w.r.t. the xyz coordinates
% of the emitter and w.r.t. the emission wavelength lambda.
%
% copyright Sjoerd Stallinga, TU Delft, 2017

% parameters: NA, wavelength (in nm), nominal emitter position (in nm) with
% z-position from cover slip-medium interface, spot footprint (in nm),
% axial range (in nm), sampling in pupil, sampling in image plane, sampling
% in axial direction
NA = parameters.NA;
lambda = parameters.lambda;
xemit = parameters.xemit;
yemit = parameters.yemit;
zemit = parameters.zemit;
xrange = parameters.xrange;
yrange = parameters.yrange;
zmin = parameters.zrange(1);
zmax = parameters.zrange(2);
Npupil = parameters.Npupil;
Mx = parameters.Mx;
My = parameters.My;
Mz = parameters.Mz;

% pupil and image size (in physical units)
PupilSize = NA/lambda;
ImageSizex = xrange;
ImageSizey = yrange;
ImageSizez = (zmax-zmin)/2;

% calculate auxiliary vectors for chirpz
[Ax,Bx,Dx] = prechirpz(PupilSize,ImageSizex,Npupil,Mx);
[Ay,By,Dy] = prechirpz(PupilSize,ImageSizey,Npupil,My);

% image coordinate sampling (in physical length units).
DxImage = 2*ImageSizex/Mx;
DyImage = 2*ImageSizey/My;
ximagelin = -ImageSizex+DxImage/2:DxImage:ImageSizex;
yimagelin = -ImageSizey+DyImage/2:DyImage:ImageSizey;
[YImage,XImage] = meshgrid(yimagelin,ximagelin);
if Mz==1
  ZImage = (zmin+zmax)/2;
else
  DzImage = 2*ImageSizez/Mz;
  ZImage = zmin+DzImage/2:DzImage:zmax;
end

% phase contribution due to position of the emitter
Wpos = xemit*wavevector{1}+yemit*wavevector{2}+zemit*wavevectorzmed;
  
% loop over emitter z-position
FieldMatrix = cell(2,3,Mz);

for jz = 1:numel(ZImage)
  zemitrun = ZImage(jz);
  if strcmp(parameters.ztype,'stage')
    PositionPhaseMask = exp(1i*(Wpos+zemitrun*wavevector{3}));
  end
  if strcmp(parameters.ztype,'medium')
    PositionPhaseMask = exp(1i*(Wpos+zemitrun*wavevectorzmed));
  end
  
  for itel = 1:2
    for jtel = 1:3
      
      % pupil functions and FT to matrix elements
      PupilFunction = PositionPhaseMask.*PupilMatrix{itel,jtel};
      IntermediateImage = transpose(cztfunc(PupilFunction,Ay,By,Dy));
      FieldMatrix{itel,jtel,jz} = transpose(cztfunc(IntermediateImage,Ax,Bx,Dx));
    end
  end
end

% plotting intermediate results
if parameters.debugmode
  jz = ceil(Mz/2); 
  figure
  for itel = 1:2
    for jtel = 1:3
      tempim = FieldMatrix{itel,jtel,jz};
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
      tempim = FieldMatrix{itel,jtel,jz};
      subplot(2,3,3*(itel-1)+jtel)
      imagesc(angle(tempim)*180/pi)
      title(strcat('phase i=',num2str(itel),', j=',num2str(jtel)))
      axis square
      axis off
    end
  end
end

end