clear all;
th1 = -20;     % theta1
th2 = 0;       % theta2
%th3=20;       % theta3

p1 = 1;        % power1
p2 = 2;        % power2
%p3=3;         % power3

K = 1024;      % sample ¼ö
d = 0.5;       % space 0.5 lamba
N = 4;         % the number of arrays
noise_var = 1; % noise power

doas = [th1 th2] * pi / 180;
P = [p1 p2];
%doas=[th1 th2 th3]*pi/180; %DOA of signals in rad.
%P=[p1 p2 p3];

%r=length(doas);

r = 2;
% define FMCW Signal

FFTpoint = K;
chirp_T = 4e-3; % 1ms~4ms
chirp_F = 100e6; %100MHz;

RF_freq = 0; %24GHz
G = 14; % 14dB
NF = 7; % 7 dB

Min_SNR = 15;
ADC_bit = 14;
F_RFs = 400e6;
FADC = 40e3; % 400kHz
alpha = chirp_F / chirp_T;

t = [0:1 / F_RFs:chirp_T];

lambda = 3e8/24e9;
v = [-150e3/3600 -75e3/3600 -200e3/3600]; % 150 km/h

%v =0;
fd = -2 * v / lambda;

Range = [150 75];
T = 2 * Range / 3e8;

%t=[0:1/F_RFs:chirp_T];

%Baseband_up = exp(1i*2*pi*RF_freq*(t-T)) .* exp(1i*2*pi*0.5*alpha * (t-T).^2).*exp(1i*2*pi*fd);
%Baseband_down= exp(1i*2*pi*(RF_freq+chirp_F)*(t-T)) .* exp(-1i*2*pi*0.5*alpha * (t-T).^2).*exp(1i*2*pi*fd);

t = [2e-6:1 / FADC:(FFTpoint - 1) * 1 / FADC + 2e-6];

target_up1 = exp(1i * 2 * pi * RF_freq * (-T(1))) * exp(1i * 2 * pi * 0.5 * alpha * (-2 * T(1) * t + T(1)^2)) .* exp(1i * 2 * pi * fd(1) * t);
target_up2 = exp(1i * 2 * pi * RF_freq * (-T(2))) * exp(1i * 2 * pi * 0.5 * alpha * (-2 * T(2) * t + T(2)^2)) .* exp(1i * 2 * pi * fd(2) * t);
%target_up3 = exp(1i*2*pi*RF_freq*(-T(3))) * exp(1i*2*pi*0.5*alpha * (-2*T(3)*t+T(3)^2)).*exp(1i*2*pi*fd(3)*t);

target_down1 = exp(1i * 2 * pi * (RF_freq + chirp_F) * (-T(1))) .* exp(-1i * 2 * pi * 0.5 * alpha * (-2 * T(1) * t + T(1)^2)) .* exp(1i * 2 * pi * fd(1) * t);
target_down2 = exp(1i * 2 * pi * (RF_freq + chirp_F) * (-T(2))) .* exp(-1i * 2 * pi * 0.5 * alpha * (-2 * T(2) * t + T(2)^2)) .* exp(1i * 2 * pi * fd(2) * t);
%target_down3= exp(1i*2*pi*(RF_freq+chirp_F)*(-T(3))) .* exp(-1i*2*pi*0.5*alpha * (-2*T(3)*t+T(3)^2)).*exp(1i*2*pi*fd(3)*t);

sig_up = [target_up1; target_up2];
%sig_up=[target_up1; target_up2; target_up3];
A = exp(-1i * 2 * pi * d * (0:N - 1)' * sin([doas(:).']));

randn('state', sum(100 * clock));
noise = sqrt(noise_var / 2) * (randn(N, K) + 1i * randn(N, K)); %Uncorrelated noise

array_up = A * diag(sqrt(P)) * sig_up + noise; %Generate data matrix (for Upchirp)

% X=A*diag(sqrt(P))*sig; %Generate data matrix

R = array_up * array_up' / K; %Spatial covariance matrix
[Q, D] = eig(R); %Compute eigendecomposition of covariance matrix
[D, I] = sort(diag(D), 1, 'descend'); %Find r largest eigenvalues
Q = Q (:, I); %Sort the eigenvectors to put signal eigenvectors first
Qs = Q (:, 1:r); %Get the signal eigenvectors
Qn = Q(:, r + 1:N); %Get the noise eigenvectors
% MUSIC algorithm
% Define angles at which MUSIC “spectrum? will be computed
angles = (-90:1:90);
%Compute steering vectors corresponding values in angles
a1 = exp(-1i * 2 * pi * d * (0:N - 1)' * sin([angles(:).'] * pi / 180));

for k = 1:length(angles)
    %Compute MUSIC “spectrum?
    % music_spectrum(k)=(a1(:,k)'*a1(:,k))/(a1(:,k)'*Qn*Qn'*a1(:,k));
    music_spectrum(k) = 1 / (a1(:, k)' * Qn * Qn' * a1(:, k));
end

figure;
plot(angles, 10 * log10(abs(music_spectrum)))
grid on
title('MUSIC Spectrum')
xlabel('Angle in degrees')

% Signal processing

fft_up = (fft(array_up', 1024));

[maxv1 b1] = max(fft_up);

beatf1 = (1024 - b1 +1) * FADC / 1024;
sig_down = [target_down1; target_down2];
%sig_down=[target_down1; target_down2; target_down3];
A = exp(-1i * 2 * pi * d * (0:N - 1)' * sin([doas(:).']));

randn('state', sum(100 * clock));
noise = sqrt(noise_var / 2) * (randn(N, K) + 1i * randn(N, K)); %Uncorrelated noise

array_down = A * diag(sqrt(P)) * sig_down + noise; %Generate data matrix (for Upchirp

fft_down = (fft(array_down', 1024));
[maxv2 b2] = max(fft_down);
beatf2 = (b2 -1) * FADC / 1024;

Mesured_Range = 3e8 / ((8 * chirp_F) * (1 / (2 * chirp_T))) * (beatf1 + beatf2);
Mesured_Velocity = 3e8 / (4 * 24e9) * (beatf1 - beatf2);

figure;
plot(abs(fft_up(:, 1)));

figure;
plot(abs(fft_down(:, 2)));
