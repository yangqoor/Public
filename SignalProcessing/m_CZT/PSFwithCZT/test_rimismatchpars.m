% This script is for testing the RImismatch computation
%
% copyright Sjoerd Stallinga, TU Delft, 2017

close all
clear all

% set parameters
parameters = set_parameters;
parameters.debugmode = 1; 
parameters.NA = 1.4;
parameters.refmed = 1.47;
parameters.refcov = 1.521;
parameters.refimm = 1.531;
parameters.refimmnom = parameters.refcov;
parameters.fwd = 140e3;
parameters.depth = 0e3;

% compute RI mismatch
NAall = linspace(0,1.47,100);
Wrmsall = zeros(size(NAall));
z1valsall = zeros(size(NAall));
for jn = 1:numel(NAall)
  parameters.NA = NAall(jn);
  [zvals,Wrms] = get_rimismatchpars(parameters);
  Wrmsall(jn) = Wrms;
  z1valsall(jn) = zvals(1);
end

figure
plot(NAall,z1valsall)

figure
plot(NAall,Wrmsall)