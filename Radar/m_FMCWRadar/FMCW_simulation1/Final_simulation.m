%This radar occupies the band around 77 GHz. 
%The radar system constantly estimates the distance between the place it is mounted on 
%and the object in front of it.

%The received signal is a time-delayed copy of the transmitted signal where the delay, del_t , 
%is related to the range. Because the signal is always sweeping through a frequency band, 
%at any moment during the sweep, the frequency difference, fb, 
%is a constant between the transmitted signal and the received signal.  
%is usually called the beat frequency. Because the sweep is linear, 
%one can derive the time delay from the beat frequency and then translate the delay to the range.

%the maximum range the radar needs to monitor is around 200 m and 
%the system needs to be able to distinguish two targets that are 1 meter apart
fc = 2e9; % 77 GHz
c = 3e8;   % Speed of Light
lambda = c/fc; % Wavelength

%The sweep time can be computed based on the time needed for the signal to travel 
%the unambiguous maximum range. 
%In general, for an FMCW radar system, 
%the sweep time should be at least 5 to 6 times the round trip time. 
%This example uses a factor of 5.5.
range_max = 30;
tm = 25000*range2time(range_max,c);

%The sweep bandwidth can be determined according to the range resolution and 
%the sweep slope is calculated using both sweep bandwidth and sweep time
range_res = 0.5;
bw = rangeres2bw(range_res,c);
sweep_slope = bw/tm;

% FMCW的发射波形具有非常大的带宽，如果单纯的根据奈奎斯特采样定理，那我们的AD器件的
% 性能要求实在是太高了，这不是扯淡嘛！开玩笑这器件要多贵？为了解决这个问题，我们
% 采集到的信号实际上是拍频信号，这样子我们就可以选择较低的采样率，那么采样率选择什么的样的参数合适呢？实际上我们需要考虑：
% 1.复杂情况下采样率可以设置的与带宽相同
% 2.FMCW的距离估计实际上是拍频信号，因此我们只需要知道最大距离下的拍频和最大多普勒频率的和的两倍（奈奎斯特采样定理）即可
%the beat frequency corresponding to the maximum range is given by
fr_max = range2beat(range_max,sweep_slope,c);

%In addition, the maximum speed of a traveling car is about 230 km/h. 
%Hence the maximum Doppler shift and the maximum beat frequency can be computed as
v_max = 10;
fd_max = speed2dop(2*v_max,lambda);
fb_max = fr_max+fd_max;

%This example adopts a sample rate of the larger of twice the maximum beat frequency 
%and the bandwidth.
fs = max(2*fb_max,bw);

%set up the FMCW waveform used in the radar system.
waveform = phased.FMCWWaveform('SweepTime',tm,'SweepBandwidth',bw,...
    'SampleRate',fs);

%This is a up-sweep linear FMCW signal, often referred to as sawtooth shape. 
%One can examine the time-frequency plot of the generated signal.

sig = waveform();
subplot(211); 
plot(0:1/fs:tm-1/fs,real(sig));
xlabel('Time (s)'); ylabel('Amplitude (v)');
title('FMCW signal'); axis tight;
subplot(212); spectrogram(sig,64,32,64,fs,'yaxis');
title('FMCW signal spectrogram');

%Target Modeling
dist = 15;
speed = 2;
rcs = 1; %radar cross section is equal to one for men
%RCS is the measure of a target's ability to reflect radar signals in the direction of the 
%radar receiver, i.e. 
%it is a measure of the ratio of backscatter power density in the direction 
%of the radar (from the target) to the power density that is intercepted by the target.
% RCS= Area*(Backscatter power density,Sb)/(Incident Power desnsity, Si)
%target RCS     dB
%bird	0.01	-20
%man	1	     0
%cruiser	10	10
%cars	100	20
%truck	200	23
%corner reflector	20379	43.1

target = phased.RadarTarget('MeanRCS',rcs,'PropagationSpeed',c,...
    'OperatingFrequency',fc);
tgtmotion = phased.Platform('InitialPosition',[dist;0;0.5],...
    'Velocity',[speed;0;0]);

%The propagation model is assumed to be free space.
channel = phased.FreeSpace('PropagationSpeed',c,...
    'OperatingFrequency',fc,'SampleRate',fs,'TwoWayPropagation',true);

%Radar System Set Up parameters

%how effective an antenna is at receiving the power of electromagnetic radiation
%square area model of antenna
ant_aperture = 6.06e-4;                         % in square meter (6cmx6cm)
ant_gain = aperture2gain(ant_aperture,lambda);  % in dB  (27 dB power req for such ant)

tx_ppower = db2pow(5)*1e-3;                     % in watts (5dB == 3.1623 Watts)
%But here we provide 3.2 mW as Peakpower
tx_gain = 9+ant_gain;                           % in dB (36dB finally)

rx_gain = 15+ant_gain;             % in dB (42dB, because ref signals are to be amplified)
rx_nf = 4.5;                       % in dB (recievers Noise In Decibels)

transmitter = phased.Transmitter('PeakPower',tx_ppower,'Gain',tx_gain);
receiver = phased.ReceiverPreamp('Gain',rx_gain,'NoiseFigure',rx_nf,...
    'SampleRate',fs);

%Radars are generally mounted. 
%This example assumes the radar is traveling at a speed of 100 km/h along x-axis. 
%So the target is approaching the radar at a relative speed of 4 km/h.

radar_speed = 0*1000/3600;
radarmotion = phased.Platform('InitialPosition',[0;0;0.5],...
    'Velocity',[radar_speed;0;0]);

%Radar Signal Simulation
%An FMCW radar measures the range by examining the beat frequency in the dechirped signal. 
%To extract this frequency, a dechirp operation is performed by mixing the received signal 
%with the transmitted signal. After the mixing, the dechirped signal contains only 
%individual frequency components that correspond to the target range.
%In addition, even though it is possible to extract the Doppler information from a single sweep, 
%the Doppler shift is often extracted among several sweeps because within one pulse, 
%the Doppler frequency is indistinguishable from the beat frequency. 
%To measure the range and Doppler, an FMCW radar typically performs the following operations:

% The waveform generator generates the FMCW signal.
% The transmitter and the antenna amplify the signal and radiate the signal into space.
% The signal propagates to the target, gets reflected by the target, and travels back to the radar.
% The receiving antenna collects the signal.
% The received signal is dechirped and saved in a buffer.
% Once a certain number of sweeps fill the buffer, 
% the Fourier transform is performed in both range and Doppler to extract 
% the beat frequency as well as the Doppler shift. 
% One can then estimate the range and speed of the target using these results. 
% Range and Doppler can also be shown as an image and give
% an intuitive indication of where the target is in the range and speed domain.

%This section simulates the process outlined above. 
%A total of 64 sweeps are simulated and a range Doppler response is generated at the end.
%During the simulation, a spectrum analyzer is used to show the spectrum of each received sweep 
%as well as its dechirped counterpart.
specanalyzer = dsp.SpectrumAnalyzer('SampleRate',fs,...
    'PlotAsTwoSidedSpectrum',true,...
    'Title','Spectrum for received and dechirped signal',...
    'ShowLegend',true);

%We Now, run the simulation loop.
% rng(2012);
rng('default') 
Nsweep = 32;
xr = complex(zeros(waveform.SampleRate*waveform.SweepTime,Nsweep));

for m = 1:Nsweep
    % Update radar and target positions
    [radar_pos,radar_vel] = radarmotion(waveform.SweepTime);
    [tgt_pos,tgt_vel] = tgtmotion(waveform.SweepTime);

    % Transmit FMCW waveform
    sig = waveform();
    txsig = transmitter(sig);

    % Propagate the signal and reflect off the target
    txsig = channel(txsig,radar_pos,tgt_pos,radar_vel,tgt_vel);
    txsig = target(txsig);

    % Dechirp the received radar return
    txsig = receiver(txsig);
    dechirpsig = dechirp(txsig,sig);

    % Visualize the spectrum
    specanalyzer([txsig dechirpsig]);

    xr(:,m) = dechirpsig;
end

%Now lets take a look at the zoomed range Doppler response of all 64 sweeps.

rngdopresp = phased.RangeDopplerResponse('PropagationSpeed',c,...
    'DopplerOutput','Speed','OperatingFrequency',fc,'SampleRate',fs,...
    'RangeMethod','FFT','SweepSlope',sweep_slope,...
    'RangeFFTLengthSource','Property','RangeFFTLength',2048,...
    'DopplerFFTLengthSource','Property','DopplerFFTLength',256);

clf;
plotResponse(rngdopresp,xr);                     % Plot range Doppler map
axis([-v_max v_max 0 range_max])
clim = caxis;

% This example uses the root MUSIC algorithm to extract 
% both the beat frequency and the Doppler shift.
% Since the received signal is sampled at 150 MHz 
% so the system can achieve the required range resolution, after the dechirp, 
% one only needs to sample it at a rate that corresponds to the maximum beat frequency. 
% Since the maximum beat frequency is in general less than the required sweeping bandwidth, 
% the signal can be decimated to alleviate the hardware cost. 
% Following is the decimation process.
Dn = fix(fs/(2*fb_max));
for m = size(xr,2):-1:1
    xr_d(:,m) = decimate(xr(:,m),Dn,'FIR');
end
fs_d = fs/Dn;

%To estimate the range, firstly, the beat frequency is estimated using 
%the coherently integrated sweeps and then converted to the range.
fb_rng = rootmusic(pulsint(xr_d,'coherent'),1,fs_d);
rng_est = beat2range(fb_rng,sweep_slope,c)
%rng_est =42.9976

%Second, the Doppler shift is estimated across the sweeps at the range 
%where the target is present.
peak_loc = val2ind(rng_est,c/(fs_d*2));
fd = -rootmusic(xr_d(peak_loc,:),1,1/tm);
v_est = dop2speed(fd,lambda)/2
%v_est =1.0830 approx 1.11m/s = 96km/hr
%Both range and Doppler estimation are quite accurate.