%
% MATLAB Code to Simulate I & Q Data for Step-Frequency Radar 
% 
% Syntax:
%   [I_freq,Q_freq]=data_sim(nscat,scat_range,scat_rcs,nf,deltaf,prf,v,r0)
% 
% Output:
%   I_freq,Q_freq -- I & Q output of the radarn receiver
%   
% Input:
%   nscat -- number of scattering centers that make up the target
%   scat_range -- vector containing range to individual scatterers (m)
%   scat_rcs -- vector containing RCS of individual scatterers (m^2)
%   nf -- number of frequency steps
%   deltaf -- frequency step (Hz)
%   prf -- PRF of the step-frequency waveform (Hz)
%   v -- target velocity (m/s), (+)=towards radar (-)=away from radar
%   r0 -- radar-target (center) distance (m)
% 
% Authored by: Xiaojian Xu
% Last Modified:  Dec.9,2004

function [I_freq,Q_freq] = data_sim(nscat,scat_range,scat_rcs,nf,deltaf,prf,v,r0)

c=3.0e8;  % speed of light (m/s)
num_pulses = nf;
freq_step = deltaf; % (Hz) 
V = v;  % radial velocity (m/s)  
PRI = 1. / prf; % pulse repeat interval (s)

I_freq = zeros(num_pulses,1);
Q_freq = zeros(num_pulses,1);

% Frequency domain data simulation
for jscat = 1:nscat  
   ii = 0;
   for i = 1:num_pulses
      ii = ii+1;
      freq_i = ((i-1)*freq_step);
      t_i=(i-1)*PRI;
      psi_i=-2*pi*freq_i/c*(2.*(scat_range(jscat)-r0) - 2*V*t_i);
      I_freq(ii) = I_freq(ii) + sqrt(scat_rcs(jscat)) * cos(psi_i);
      Q_freq(ii) = Q_freq(ii) + sqrt(scat_rcs(jscat)) * sin(psi_i);
   end
end
