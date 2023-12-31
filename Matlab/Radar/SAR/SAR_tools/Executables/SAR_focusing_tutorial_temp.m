clear all; close all; clc;

% Tutorial: Focusing of SAR raw data
% Programmed by Diana Weihing & Stefan Auer
% Remote Sensing Technology 
% Technische Universit�t M�nchen
% 2011

%--------------------------------------------------------------------------

% A.) Load raw data

% Dummy image ('Test_Image')
raw = load('Test_Image'); % type: field
max_power = 2.1807e+008;

% Real SAR data ('ERS')
%raw = load('ERS'); % type: field
%max_power = 10000;

% Multilooking on/off?
multilook = 0; % 0: no; 1: yes
ml_factor = 5; % multilooking factor (spatial)

% Get image size
fn = fieldnames(raw);
Raw_data = getfield(raw,fn{1});
size_azimuth = size(Raw_data,1);
size_range = size(Raw_data,2);
%--------------------------------------------------------------------------

% B.) Sensor parameters (ERS satellite)
fs=18.962468*10^6;          % Range Sampling Frequency [Hz]      
K_r=4.18989015*10^(11);     % FM Rate Range Chirp [1/s^2] --> up-chirp  
tau_p=37.12*10^(-6);        % Chirp duration [s]
V=7098.0194;                % Effective satellite velocity [m/s]
lambda=0.05656;             % Length of carrier wave [m]
R_0=852358.15;              % Range to center of antenna footprint [m]
ta=0.6;                     % Aperture time [s]  
prf=1679.902;               % Pulse Repitition Frequency [Hz]

%-------------------------------------------------------------------------- 

% C.) Display raw data
figure;
imagesc(abs(Raw_data));colormap('gray');
title('Raw data (unfocused)'); xlabel('Range pixels'); ylabel('Azimuth pixels');
axis equal; axis off;

%--------------------------------------------------------------------------

% D.) Define correlation chirp in range

% Basic definitions
range_chirp=zeros(1,size_range); % empty vector to be filled with chirp values
tau=-tau_p/2:1/fs:tau_p/2; % time axis in range
omega = -fs/2:1/tau_p:fs/2; % frequency axis in range

% Define chirp in range
%...

% Get size of chirp
%...

%--------------------------------------------------------------------------

% assume: name of chirp = ra_chirp_temp

% % Display range chirp (time + frequency domain)
% figure;
% subplot(2,1,1); plot(tau,real(ra_chirp_temp),'b'); hold on;
% plot(tau,imag(ra_chirp_temp),'r');
% title('Range chirp'); xlabel('Time axis [sec]'); ylabel('Amplitude');
% xlim([min(tau) max(tau)]);
% subplot(2,1,2); plot(omega, abs(fftshift(fft(ra_chirp_temp))));
% title('Spectrum of range chirp'); xlabel('Frequency [Hz]'); ylabel('Absolute');
% xlim([min(omega) max(omega)]);

%--------------------------------------------------------------------------

% Position chirp in range vector (centered)
% --> used for correlation procedure
%...

% Transform vector in frequency domain (fourier transform)
%...

% Define chirp for correlation 
% --> conjugate complex of signal chirp
%...

%--------------------------------------------------------------------------

% E.) Define correlation chirp in azimuth

% Basic definitions
% azimuth_chirp=zeros(1,size_azimuth); % empty vector to be filled with chirp values
% t=-ta/2:1/prf:ta/2; % time axis in azimuth
% v=-prf/2:1/ta:prf/2; % frequency axis in azimuth

% FM Rate Azimuth Chirp
%...

% Define chirp in azimuth
%...

% Get size of chirp
%...

%--------------------------------------------------------------------------

% assume: name of chirp = az_chirp_temp

% % Display azimuth chirp (time + frequency domain)
% figure;
% subplot(2,1,1); plot(t,real(az_chirp_temp),'b'); hold on;
% plot(t,imag(az_chirp_temp),'r');
% title('Azimuth chirp'); xlabel('Time axis [sec]'); ylabel('Amplitude');
% xlim([min(t) max(t)]);
% subplot(2,1,2); plot(v, abs(fftshift(fft(az_chirp_temp))));
% title('Spectrum of azimuth chirp'); xlabel('Frequency [Hz]'); ylabel('Absolute');
% xlim([min(v) max(v)]);

%--------------------------------------------------------------------------

% Position chirp in azimuth vector (centered)
% --> used for correlation procedure
%...

% Change in frequency domain (fourier transform)
%...

% Define chirp for correlation 
% --> conjugate complex of signal chirp
%...

%--------------------------------------------------------------------------

% F.) Focusing (= 2D correlation)

% Dummy matrix to be filled with processed data
% processed=zeros(size_azimuth,size_range);

%-------------------------------------------------

% F.1) Range compression 
% --> correction in azimuth time - range frequency domain
% --> result in azimuth-range domain

% Proceeding:
% A.) Take 1st range line and fourier transform it
% B.) Multiply it with correlation chirp in frequency domain
% C.) Inverse fourier transform
% D.) Take next range line and continue...

%...
%...
%...

%-------------------------------------------------

% F.2) Azimuth compression 
% conducted in azimuth frequency - range time domain 

% Proceeding: comparable to range compression but for all azimuth lines

%...
%...
%...

% %--------------------------------------------------------------------------
%
% % G.) Spatial Multilooking
% 
% ERS: resolution in range: approx. 25 m, resolution in azimuth: approx. 5 m
% Aim: pixel should have the same size in azimuth and range
% solution: average 5 azimuth pixels to one azimuth pixel
% 
% if multilook == 1
%     
%     % define size of output image
%     output_image=zeros(ceil(size_azimuth/ml_factor),size_range);
% 
%     % Dummy index
%     index=1;
%     
%     % Spatial averaging
%     for i=1:ml_factor:size_azimuth-ml_factor % jump along azimuth axis according to multilooking factor
%         vek=processed(i:i+(ml_factor-1),:); % select azimuth bins
%         m_vek=mean(abs(vek),1); % average value of azimuth bins
%         output_image(index,:)=m_vek;
%         index=index+1;
%     end
%     
%     % Final SAR image (multi-looked)
%     processed = output_image;
%     
% end
 
% %--------------------------------------------------------------------------
% 
% % H.) Display SAR image
% 
% figure;
% imagesc(abs(processed));colormap('gray')
% title('Processed SAR image')
% xlabel('Range','FontSize',12); ylabel('Azimuth','FontSize',12);
% caxis([0 max_power]);
% axis equal; axis off;

% %--------------------------------------------------------------------------