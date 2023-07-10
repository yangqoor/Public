function welcome
%WELCOME Displays DR Toolbox version information
%
%   welcome
%
% Displays DR Toolbox version information.

% This file is part of the Matlab Toolbox for Dimensionality Reduction v0.3b.
% The toolbox can be obtained from http://www.cs.unimaas.nl/l.vandermaaten
% You are free to use, change, or redistribute this code in any way you
% want for non-commercial purposes. However, it is appreciated if you 
% maintain the name of the original author.
%
% (C) Laurens van der Maaten
% Maastricht University, 2007

    global DR_WELCOME;
    if isempty(DR_WELCOME)
        disp(' ');
        disp('   Welcome to the Matlab Toolbox for Dimensionality Reduction, version 0.2b (17-May-2007).');
        disp('      You are free to modify or redistribute this code (for non-commercial purposes), as long as a refence');
        disp('      to the original author (Laurens van der Maaten, MICC-IKAT, Maastricht University) is retained.');
        disp('      For more information, please visit http://www.cs.unimaas.nl/l.vandermaaten/dr');
        disp(' ');
        DR_WELCOME = 1;
    end
