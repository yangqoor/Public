%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

%% Load pAll
%-------------------------------------------------------------------------%
load("pAll")

%% Save new pAll
%-------------------------------------------------------------------------%
save("pAll","pAll")

%% Create 2D Airplane Reflectivity Function
%-------------------------------------------------------------------------%
clear p
p.xLim = 256;
p.zLim = 256;

p.pxz = imread("airplane.png");
p.pxz = imresize(p.pxz,[p.xLim,p.zLim]);
p.pxz = double(mean(p.pxz,3));
p.pxz = p.pxz - min(p.pxz(:));

p.pxz(p.pxz>1) = 1;
p.pxz(p.pxz<1) = 0;

p.xMax = 0.15;
p.zMax = 0.5;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.zT = linspace(2*p.zMax/p.zLim,2*p.zMax,p.zLim);

% Look at the Reflectivity Function
figure
imagesc(squeeze(p.zT),squeeze(p.xT),squeeze(p.pxz))
title("Reflectivity Function")
xlabel("x")
ylabel("z")
pAll.Airplane = p

%% Create 3D Airplane Reflectivity Function
%-------------------------------------------------------------------------%
clear p

p.xLim = 256;
p.yLim = 256;
p.zLim = 256;

p.xMax = 0.15;
p.yMax = 0.25;
p.zMax = 0.5;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(2*p.zMax/p.zLim,2*p.zMax,p.zLim);

p.pxz = imread("airplane.png");
p.pxz = imresize(p.pxz,[p.xLim,p.zLim]);
p.pxz = double(mean(p.pxz,3));
p.pxz = imrotate(p.pxz,180);
p.pxz = p.pxz - min(p.pxz(:));

p.thr = 1;

p.pxz(p.pxz>p.thr) = 1;
p.pxz(p.pxz<p.thr) = 0;

% Put the Airplane different places in the scene
%-------------------------------------------------------------------------%
p.pxyz = zeros([p.xLim,p.yLim,p.zLim]);
p.pxyz(:,end/4,:) = p.pxz;

p.pxyz(:,end/2,:) = imrotate(p.pxz,90);

p.pxyz(:,3*end/4,:) = imrotate(p.pxz,-90);

pAll.Airplanes = p

%% Create 1D/2D PSF Reflectivity Function
%-------------------------------------------------------------------------%
clear p
p.xLim = 256;
p.yLim = 256;
p.zLim = 256;

p.xMax = 0.15;
p.yMax = 0.25;
p.zMax = 0.5;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(2*p.zMax/p.zLim,2*p.zMax,p.zLim);

p.pxz = zeros(p.xLim,p.yLim);
p.pxz(round(end/2),round(end/2)) = 1;

p.py = zeros(1,p.yLim);
p.py(end/2) = 1;

figure
plot(p.yT,p.py)

% Look at the PSF
figure
mesh(squeeze(p.zT),squeeze(p.xT),squeeze(p.pxz))
title("Reflectivity Function")
xlabel("x")
ylabel("z")
pAll.PSF = p

%% Create 3D PSF
%-------------------------------------------------------------------------%
clear p
p.xLim = 256;
p.yLim = 256;
p.zLim = 256;

p.xMax = 0.15;
p.yMax = 0.25;
p.zMax = 0.5;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(2*p.zMax/p.zLim,2*p.zMax,p.zLim);

p.pxz = zeros(p.xLim,p.yLim);
p.pxz(round(end/2),round(end/2)) = 1;

p.pxyz = zeros(p.xLim,p.yLim,p.zLim);
p.pxyz(end/2,end/2,end/2) = 1;

pAll.PSF = p

%% Create 3D Grid of Point Reflectors
%-------------------------------------------------------------------------%
clear p

p.xLim = 256;
p.yLim = 256;
p.zLim = 256;

p.xMax = 0.15;
p.yMax = 0.25;
p.zMax = 0.5;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(2*p.zMax/p.zLim,2*p.zMax,p.zLim);

p.pxyz = zeros([length(p.xT),length(p.yT),length(p.zT)]);
p.pxyz((end/2-16):16:(end/2+16),(end/2-16):16:(end/2+16),(end/2-32):32:(end/2+32)) = 1;

pAll.Grid3D = p
volumeViewer(permute(p.pxyz,[2 1 3]))

%% Look at the non-zero z-ranges
%-------------------------------------------------------------------------%
for izP = 1:p.zLim
    if squeeze(mean(p.pxyz(:,:,izP),[1,2])) > 0
        figure
        mesh(flip(squeeze(p.xT)),flip(squeeze(p.yT)),flipud(squeeze(p.pxyz(:,:,izP)).'))
        title("Reflectivity Function")
        view(2)
        xlabel("x")
        ylabel("y")
        title("2D Image at z = " + p.zT(izP))
    end
end

clear izP