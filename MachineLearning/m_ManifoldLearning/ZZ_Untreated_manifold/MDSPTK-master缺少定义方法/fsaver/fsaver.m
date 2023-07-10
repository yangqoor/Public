%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        fsaver.m
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
classdef fsaver
    %FSAVER Summary of this class goes here
    %   Detailed explanation goes here
       
    properties(Access = private, Constant = true)
       %Functions enumeration
       savePlaneDataID = 101;
       saveFIRID       = 102;
       saveIIRID       = 103;
       saveSOSID       = 104;
    end
    
    properties(Access = public, Constant = true)
        writePrecision = 12;
    end
    
    methods (Access = public, Static = true)
        savePlaneData(fileName, data, numberOfSets, varargin);
        saveFIR(fileName, data, order, numberOfSets, varargin);
        saveIIR(fileName, numData, denumData, order, numberOfSets, varargin);
        saveSOS(fileName, gain, sos, order, numberOfSets, varargin);
    end
    
end

