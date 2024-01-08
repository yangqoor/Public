%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

p.pxy = imread("airplane.png");
p.pxy = imresize(p.pxy,[32,32]);
p.pxy = double(mean(p.pxy,3));
p.pxy = p.pxy - min(p.pxy(:));

[p.xLim,p.yLim] = size(p.pxy);

p.xT = linspace(-0.1,0.1,p.xLim);

p.yT = linspace(-0.1,0.1,p.yLim);

% Mesh Reflectivity Function

imagesc(squeeze(p.yT),squeeze(p.xT),squeeze(p.pxy))
title("Reflectivity Function")
xlabel("x")
ylabel("y")