%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [Ry_m,Ty_m,Vy_m,Dy_m] = awr1443ArrayDimensions(plotArrays)
%
% Rx (o) Spacing - lambda/2
% Tx (x) Spacing - 2*lambda
%
%                               -> positive y direction (for scanner)
%          Rx      Tx       Tx
%       o o o o     x        x


%% Define Optional Parameters
%-------------------------------------------------------------------------%
if nargin < 1
    plotArrays = false;
end

%% Declare Spatial Features of Physical Array
%-------------------------------------------------------------------------%
lambda_m = 299792458/(79e9);

TxRxOffset = 5e-3; % m

Ry_m = [0 1/2 1 3/2] * lambda_m; % Location of physical receive elements
Ty_m = TxRxOffset + [3/2 7/2] * lambda_m; % Location of physical transmit elements

%% Declare Difference Vector
%-------------------------------------------------------------------------%
Dy_m = (Ty_m' - Ry_m).';
Dy_m = Dy_m(:).'; % Distance between each Tx/Rx pair

%% Declare Spatial Features of Virtual Array
%-------------------------------------------------------------------------%
Vy_m = (Ry_m + Ty_m.').'/2;
Vy_m = Vy_m(:).'; % Location of virtual elements

%% Plot the Arrays
%-------------------------------------------------------------------------%
if plotArrays
    figure
    scatter(Ry_m,zeros(length(Ry_m),1))
    hold on
    scatter(Ty_m,zeros(length(Ty_m),1),'x')
    
    scatter(Vy_m,ones(size(Vy_m)))
    ylim([-2 2])
    legend("Rx","Tx","Virtual Array")
end