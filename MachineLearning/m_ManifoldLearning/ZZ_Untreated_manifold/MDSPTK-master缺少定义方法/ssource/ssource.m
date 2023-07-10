%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        ssource.m
% Dependencies:    -
% 
% MATLAB v:        8.0.0 (R2012b)
% 
% Organization:    SAL
% Design by:       
% Feedback:                 
%                  ___
%
% License:         MIT
% 
% 
%  ADDITIONAL NOTES:
%  _________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef ssource < handle
%SSOURCE - signal source class.
%
%Public methods list:
%
%   ssource(dataLength, sampleRate); dataLength - size of internal buffer.
%   getData(); - get internul buffer
%   
%Signal generation methods:
%   kronecker();
%   trigonometric(varargin); - sin/cos signal
%   square(amps, freqs, widthToPeriod) - square wave signal
%   symmetricalTooth(amps, freqs); --
%   riseTooth(obj, amps, freqs);     |> tooth waves
%   fallTooth(obj, amps, freqs);   --
%   noise(obj, amps, fmax); - noise source
%
%Work with .wav files
%   readWavFile(path); -read data from .wav file to internal buffer
%   writeWavFile(path); - write data from internal buffer to wav file
%
%Plotting:
%   plotData(); - plot data from internal buffer
%
%Notes:
%After constructor calling, the internall buffer is empty (all zeros).

    properties (Access = private)
        dataBuf = zeros(1, 1000);
        sampleRate = 48000;
    end
    
    methods (Access = private)
        data = interpolateData(obj, inData) 
    end;
    
    methods (Access = private, Static = true)
        [ y ] = filteredNoiseSource(Type , Lf , Hf , Length , Fs)
    end;
    
    methods (Access = public)
         function obj = ssource(dataLength, sampleRate)
            obj.dataBuf = zeros(1,dataLength);
            obj.sampleRate = sampleRate;
         end;
         
         function data = getData(obj)
             data = obj.dataBuf;
         end;
         
         function kronecker(obj)
             obj.dataBuf = zeros(1, length(obj.dataBuf));
             obj.dataBuf(1) = 1;
         end;
         
         trigonometric(obj, varargin)
         square(obj, amps, freqs, widthToPeriod)
         symmetricalTooth(obj, amps, freqs)
         riseTooth(obj, amps, freqs)
         fallTooth(obj, amps, freqs);
         
         function noise(obj, amps, fmax)
         %Noise wave will generated.
         %Usage:
         % ssource.noise(amps, fmax); - fmax cutoff freq of LP filter
         %Examples:
         %
         % Noise wave with fmax = 1000 Hz:
         % ssource.noise(1, 1000);
           
         %Check amps
            argSize = size(amps);
            if((argSize(1) > 1 && argSize(2) ~= 1) || (argSize(2) > 1 && argSize(1) ~= 1))
                error('The input arguments can be only 1D arrays');
            end;
        
            amps = obj.interpolateData(amps);
            % 0.5 - remove dc 
            obj.dataBuf = obj.filteredNoiseSource('bandpass', 100, fmax , length(obj.dataBuf), obj.sampleRate) - 0.5;
            
            %Apply amplitudes
            for(n = 1:length(obj.dataBuf))
                obj.dataBuf(n) = obj.dataBuf(n)*amps(n);
            end;
         
         end;
         
         function readWavFile(obj, path)
            [obj.dataBuf, obj.sampleRate] = wavread(path);
         end;
         
         function writeWavFile(obj, path)
            wavwrite(obj.dataBuf, obj.sampleRate, path);
         end;
         
         function plotData(obj)
             figure1 = figure;
             plot(obj.dataBuf);
             grid('on');
         end;
        
    end
    
end


