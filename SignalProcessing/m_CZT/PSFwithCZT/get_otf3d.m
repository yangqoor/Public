function [ZSupport,OTF3D] = get_otf3d(OTFstack,ZImage,parameters)
% This function computes the 3D-OTF from a through-focus stack of the
% 2D-OTF by making an FT along the axial direction by applying a 1D-CZT
% along that direction. The expected shape is a sinc-function along the
% optical axis (finite support variant of the delta-function and a
% torus-like support region away from the optical axis. The cutoff is
% described by the circular arcs:
% (q_z \pm n*cosalpha/lambda)^2 + (q_par - n*sinalpha/lambda)^2 =
% (n/lambda)^2
% with NA = n*sinalpha and qpar = sqrt(q_x^2+q_y^2), with (q_x,q_y,q_z)
% the spatial frequency vector. The lateral cutoff is 2*n*sinalpha/lambda 
% (found for q_z=0), the axial cutoff is n*(1-cosalpha)/lambda (found
% for qpar =  n*sinalpha/lambda).
%
% copyright Sjoerd Stallinga, TU Delft, 2017

SupportSizez = parameters.supportsizez;
Nsupportz = parameters.Nsupportz;
zmin = parameters.zrange(1);
zmax = parameters.zrange(2);
ImageSizez = (zmax-zmin)/2;
[Nx,Ny,Mz] = size(OTFstack);

% OTF support and sampling (in physical units)
DzSupport = 2*SupportSizez/Nsupportz;
delqz = parameters.shiftsupport(3)*DzSupport;
ZSupport = -SupportSizez+DzSupport/2:DzSupport:SupportSizez;
ZSupport = ZSupport-delqz;

% calculate auxiliary vectors for chirpz
[A,B,D] = prechirpz(ImageSizez,SupportSizez,Mz,Nsupportz);

% make 1D-CZT along axial cuts
OTF3D = zeros(Nx,Ny,Nsupportz);
for ii = 1:Nx
  for jj = 1:Ny
    axialcut = squeeze(OTFstack(ii,jj,:))';
    axialcut = exp(-2*pi*1i*delqz*ZImage).*axialcut;
    OTF3D(ii,jj,:) = cztfunc(axialcut,A,B,D);
  end
end

norm = max(abs(OTF3D(:)));
OTF3D = OTF3D/norm;

end

