%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        fanalyzer.m
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
classdef fanalyzer < handle
%FANALYZER - class for investigation, implemetation and testing DSP algorithms and filters.
%
%Public methods list:
%
%   fanalyzer(sampleRate);
%   sr = getSampleRate();
%   setSampleRate(sr);
%   
%Signal plotting methods:
%   timePlot(data);
%   timePlotSamples(data);
%
%Impulse response plotting functions:
%   impRespCoefs(numb, denum);
%
%Frequency response plotting functions:
%   freqResp(data);
%   freqRespCoefs(num, denum);
%
%Phase response plotting functions:
%   phaseResp(data);
%   phaseRespCoefs(num, denum);
%
%Phase and group delay plotting functions:
%   phaseDelayCoefs(num, denum);
%   groupDelayCoefs(num, denum);
%
%PZ plotting function:
%   pzPlotCoefs(num, denum);
%        
%Polar compex frequency:
%   polarComplexFreqCoefs(num, denum);
%
%Spectrogram plotting functions:
%   spectrogram(data);
%   spectrogram3D(data);

    properties(Access = private)
        sampleRate = 48000;
    end
    
    methods
        function obj = fanalyzer(sampleRate)
            obj.sampleRate = sampleRate;
        end;
        
        function sr = getSampleRate(obj)
            sr = obj.sampleRate;
        end;
        
        function setSampleRate(obj, sr)
            obj.sampleRate = sr;
        end;
        
        timePlot(obj, varargin);
        timePlotSamples(obj, varargin);
        
        impRespCoefs(obj, numb, denum, varargin);
        
        freqResp(obj, data, varargin);
        freqRespCoefs(obj, num, denum, varargin);
        
        phaseResp(obj, data, varargin)
        phaseRespCoefs(obj, num, denum, varargin)
        
        phaseDelayCoefs(obj, num, denum, varargin);
        groupDelayCoefs(obj, num, denum, varargin);
        
        pzPlotCoefs(obj, num, denum, varargin);
        
        polarComplexFreqCoefs(obj, num, denum, varargin);
        
        spectrogram(obj, data, varargin);
        spectrogram3D(obj, data, varargin);
        
    end
    
end

