% This m-file is for calculating the 3D (emission or excitation) PSF for
% a single dipole emitter with fixed or free dipole axis using the
% CZT-function with arbitrary windows and discretization in real and
% spatial frequency space. 
%
% The axial coordinate is the z-stage position, increasing with distance
% from the objective to the cover slip. The nominal z-stage position is
% found for a given set of refractive index values and a given depth of
% the image plane away from the cover slip into the medium by minimizing
% the rms wavefront aberration.
%
% copyright Sjoerd Stallinga, TU Delft, 2017

close all
clear all

%%
% set parameters
parameters = set_parameters;

% calculate pupil matrix
[XPupil,YPupil,wavevector,wavevectorzmed,Waberration,PupilMatrix] = get_pupil_matrix(parameters);

% calculate field matrix for focal stack
[XImage,YImage,ZImage,FieldMatrix] = get_field_matrix(PupilMatrix,wavevector,wavevectorzmed,parameters);

% calculation of (fixed or free dipole) PSF for the focal stack
PSF = get_psf(FieldMatrix,parameters);

% calculation of through-focus OTF for the focal stack
[XSupport,YSupport,OTFthroughfocus] = get_otf(PSF,XImage,YImage,parameters);

% calculation of 3D-OTF
[ZSupport,OTF3D] = get_otf3d(OTFthroughfocus,ZImage,parameters);

%%
% make plots

diffunitxy = parameters.lambda/parameters.NA;
diffunitz = parameters.lambda/(parameters.refimm-sqrt(parameters.refimm^2-parameters.NA^2));
  
if (parameters.Mz>1) 
  
  figure;
  ximagelin = squeeze(XImage(:,1))';
  yimagelin = squeeze(YImage(1,:));
  sliceposx = parameters.xrange/parameters.Mx;
  sliceposy = parameters.yrange/parameters.My;
  sliceposz = 0;
  slice(yimagelin,ximagelin,ZImage,PSF,sliceposx,sliceposy,sliceposz);
  title('PSF');
  axis square;
  shading flat;
  ylim([-parameters.xrange,parameters.xrange]);
  xlim([-parameters.yrange,parameters.yrange]);
  colorbar;
  ylabel('x [nm]');
  xlabel('y [nm]');
  if strcmp(parameters.ztype,'stage')
    zlabel('{\Delta}z_{stage} [nm]');
  end
  if strcmp(parameters.ztype,'medium')
    zlabel('{\Delta}z_{medium} [nm]');
  end
  
  figure;
  box on
  PSF_onaxis = squeeze(PSF(round(parameters.Mx/2),round(parameters.My/2),:));
  plot(ZImage,PSF_onaxis/max(PSF_onaxis));
  title('PSF on axis');
  if strcmp(parameters.ztype,'stage')
    xlabel('{\Delta}z_{stage} [nm]');
  end
  if strcmp(parameters.ztype,'medium')
    xlabel('{\Delta}z_{medium} [nm]');
  end
  
  [~,jz] = max(PSF_onaxis);
  tempim = squeeze(PSF(:,:,jz));
%   radialmeanPSF = im2mat(radialmean(tempim));
    radialmeanPSF = mean(tempim);
  radialmeanPSF = radialmeanPSF/max(radialmeanPSF);
  jindex = sum(double(radialmeanPSF>0.5));
  y1 = radialmeanPSF(jindex);
  y2 = radialmeanPSF(jindex+1);
  alphacoef = (y1-0.5)/(y1-y2);
  FWHM = 2*(jindex-1+alphacoef)*parameters.pixelsize;
  positionvec = (0:(length(radialmeanPSF)-1))*parameters.pixelsize;
  figure
  box on
  hold on 
  plot(positionvec,radialmeanPSF)
  xlabel('position [nm]')
  xlim([0 3*parameters.lambda/parameters.NA])
  plot([0 3*parameters.lambda/parameters.NA],[0.5 0.5],'k')
  plot([FWHM/2 FWHM/2],[0 0.5],'--k')
  textboxstr = strcat('FWHM of PSF = ',num2str(FWHM,'%4.0f'),' nm');
  annotation('textbox',[0.6 0.8 0.2 0.1],'String',textboxstr,'FitBoxToText','on')
  ylabel('radial average in-focus PSF')
  
  figure;
  XYSupport = squeeze(XSupport(1,:));
  sliceposx = 0.0;
  sliceposy = 0.0;
  sliceposz = 0.0;
  slice(diffunitxy*XYSupport,diffunitxy*XYSupport,ZImage,abs(OTFthroughfocus),sliceposx,sliceposy,sliceposz);
  title('through-focus MTF');
  axis square;
  shading flat;
  xlim([-2,2]);
  ylim([-2,2]);
  colorbar;
  xlabel('q_x [NA/\lambda]');
  ylabel('q_y [NA/\lambda]');
  if strcmp(parameters.ztype,'stage')
    xlabel('{\Delta}z_{stage} [nm]');
  end
  if strcmp(parameters.ztype,'medium')
    xlabel('{\Delta}z_{medium} [nm]');
  end

  figure;
  XYSupport = squeeze(XSupport(1,:));
  sliceposx = 0.0;
  sliceposy = 0.0;
  sliceposz = 0.0;
  slice(diffunitxy*XYSupport,diffunitxy*XYSupport,diffunitz*ZSupport,abs(OTF3D),sliceposx,sliceposy,sliceposz);
  title('3D MTF');
  axis square;
  shading flat;
  xlim([-2,2]);
  ylim([-2,2]);
  zlim([-3,3]);
  colorbar;
  xlabel('q_x [NA/\lambda]');
  ylabel('q_y [NA/\lambda]');
  zlabel('q_z [n-(n^{2}-NA^{2})^{1/2})/\lambda]');
  
else
  
  figure;
  surf(XImage,YImage,PSF);
  title('PSF');
  axis square;
  shading flat;
  xlim([-parameters.xrange,parameters.xrange]);
  ylim([-parameters.yrange,parameters.yrange]);
  colorbar;
  xlabel('x [nm]');
  ylabel('y [nm]');
  
  figure;
  surf(diffunitxy*XSupport,diffunitxy*YSupport,abs(OTFthroughfocus));
  title('MTF');
  axis square;
  shading flat;
  xlim([-2,2]);
  ylim([-2,2]);
  colorbar;
  xlabel('q_x [NA/\lambda]');
  ylabel('q_y [NA/\lambda]');
end


