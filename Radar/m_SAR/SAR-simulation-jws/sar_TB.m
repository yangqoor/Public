%% Include Path

addpath(genpath("./"))

%% load iParams and fParams

load fParamsAll; load iParamsAll
fParams = fParamsAll.v0;                    % Frequency Parameters
iParams = iParamsAll.SISO_CSAR;             % Image and Scanning Parameters (360deg of rotation)
clear fParamsAll iParamsAll 

%% Create f, t, and k

f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
t = (0:fParams.adcSample-1)/fParams.fS;
f = f0 + t*fParams.K; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = reshape(k,1,[]);

%% Transmitted Radar Signal p(t)

pt = exp(1j*2*pi*(f0*t + 0.5*fParams.K*t.^2));

%% Fourier Transform of Transmitted Radar Signal P(w)

Pw = fftshift(fft(fftshift(pt)));

%% Test Bench
R = 2;

st1 = exp(1j*2*(2*f*pi/c)*R);
st2 = exp(1j*2*k*R);