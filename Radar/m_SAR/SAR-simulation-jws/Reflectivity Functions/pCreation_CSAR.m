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

%% Create 2D Airplane Reflectivity Function CSAR
%-------------------------------------------------------------------------%
p.pxz = imread("airplane.png");
p.pxz = imresize(p.pxz,[256,256]);
p.pxz = double(mean(p.pxz,3));
p.pxz = p.pxz - min(p.pxz(:));

p.pxz(p.pxz>1) = 1;
p.pxz(p.pxz<1) = 0;

p.xLim = 256;
p.yLim = 256;
p.zLim = 256;

p.xMax = 0.15;
p.yMax = 0.25;
p.zMax = 0.15;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(-p.zMax+2*p.zMax/p.zLim,p.zMax,p.zLim);

% Look at the Reflectivity Function
figure
imagesc(squeeze(p.zT),squeeze(p.xT),squeeze(p.pxz))
title("Reflectivity Function")
xlabel("x")
ylabel("z")

%% Create 3D Airplane Reflectivity Function CSAR
%-------------------------------------------------------------------------%
p.pxz = imread("airplane.png");
p.pxz = imresize(p.pxz,[256,256]);
p.pxz = double(mean(p.pxz,3));
p.pxz = imrotate(p.pxz,180);
p.pxz = p.pxz - min(p.pxz(:));

[p.xLim,p.zLim] = size(p.pxz);

p.thr = 1;

p.xLim = 256;
p.yLim = 256;
p.zLim = 256;

p.xMax = 0.15;
p.yMax = 0.25;
p.zMax = 0.15;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(-p.zMax+2*p.zMax/p.zLim,p.zMax,p.zLim);

%% Put the Airplane different places in the scene CSAR
%-------------------------------------------------------------------------%
p.pxyz = zeros(p.xLim,p.yLim,p.zLim);
y0 = 500;
[~,iy0] = min(abs(p.yT - y0*1e-3));
p.pxyz(:,iy0,:) = p.pxz;

y1 = 750;
[~,iy1] = min(abs(p.yT - y1*1e-3));
p.pxyz(:,iy1,:) = imrotate(p.pxz,90);

y2 = 250;
[~,iy2] = min(abs(p.yT - y2*1e-3));
p.pxyz(:,iy2,:) = imrotate(p.pxz,-90);

clear iy0 y1 iy1 y2 iy2
pAll.CSAR_Airplanes = p

%% Create 3D CSAR-PSF
%-------------------------------------------------------------------------%
clear p
p.xLim = 256;
p.yLim = 256;
p.zLim = 256;

p.xMax = 0.15;
p.yMax = 0.25;
p.zMax = 0.15;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(-p.zMax+2*p.zMax/p.zLim,p.zMax,p.zLim);

p.pxyz = zeros(p.xLim,p.yLim,p.zLim);
p.pxyz(end/2,end/2,end/2) = 1;

pAll.CSAR_PSF = p

%% Create 3D CSAR-PSF-OFF-CENTER
%-------------------------------------------------------------------------%
clear p
p.xLim = 256;
p.yLim = 256;
p.zLim = 256;

p.xMax = 0.15;
p.yMax = 0.25;
p.zMax = 0.15;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(-p.zMax+2*p.zMax/p.zLim,p.zMax,p.zLim);

p.pxyz = zeros(p.xLim,p.yLim,p.zLim);
p.pxyz(end/2 - 32,end/2,end/2) = 1;

pAll.CSAR_PSF_OC = p

%% Create 3D CSAR-Grid3D
%-------------------------------------------------------------------------%
clear p
p.xLim = 256;
p.yLim = 256;
p.zLim = 256;

p.xMax = 0.15;
p.yMax = 0.25;
p.zMax = 0.15;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(-p.zMax+2*p.zMax/p.zLim,p.zMax,p.zLim);

p.pxyz = zeros(p.xLim,p.yLim,p.zLim);
p.pxyz((end/2-32):32:(end/2+32),(end/2-16):16:(end/2+16),(end/2-32):32:(end/2+32)) = 1;

pAll.CSAR_Grid3D = p

%% Create 2D CSAR-R
%-------------------------------------------------------------------------%
clear p
p.xLim = 256;
p.zLim = 256;

p.xMax = 0.15;
p.zMax = 0.15;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.zT = linspace(-p.zMax+2*p.zMax/p.zLim,p.zMax,p.zLim);

p.pxz = imread("letterR.png");
p.pxz = imresize(p.pxz,[20,20]);
p.pxz = double(mean(p.pxz,3));
p.pxz = imrotate(p.pxz,180);
pxz = p.pxz;
p.pxz = upsample(p.pxz,10);
p.pxz = upsample(p.pxz.',10).';
p.pxz = fliplr(p.pxz);
p.pxz = p.pxz - min(p.pxz(:));
p.pxz(p.pxz>1) = 1;
p.pxz(p.pxz<1) = 0;
letterR = p.pxz;

p.pxz = zeros(p.xLim,p.zLim);

p.pxz(floor((p.xLim-size(letterR,1))/2):(floor((p.xLim-size(letterR,1))/2)+size(letterR,1)-1),floor((p.xLim-size(letterR,2))/2):(floor((p.xLim-size(letterR,2))/2)+size(letterR,2)-1)) = letterR;

figure
mesh(squeeze(p.zT),squeeze(p.xT),squeeze(p.pxz))
title("Reflectivity Function")
xlabel("x")
ylabel("z")

pAll.CSAR_R = p

%% Create 2D CSAR-J
%-------------------------------------------------------------------------%
clear p
p.xLim = 256;
p.zLim = 256;

p.xMax = 0.15;
p.zMax = 0.15;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.zT = linspace(-p.zMax+2*p.zMax/p.zLim,p.zMax,p.zLim);

p.pxz = imread("letterJ.jpg");
p.pxz = imresize(p.pxz,[20,20]);
p.pxz = -double(mean(p.pxz,3));
p.pxz = imrotate(p.pxz,180);
p.pxz = p.pxz - min(p.pxz(:));
p.pxz(p.pxz>1) = 1;
p.pxz(p.pxz<1) = 0;
p.pxz = upsample(p.pxz,10);
p.pxz = upsample(p.pxz.',10).';
p.pxz = fliplr(p.pxz);
letterJ = p.pxz;

p.pxz = zeros(p.xLim,p.zLim);

p.pxz(floor((p.xLim-size(letterJ,1))/2):(floor((p.xLim-size(letterJ,1))/2)+size(letterJ,1)-1),floor((p.xLim-size(letterJ,2))/2):(floor((p.xLim-size(letterJ,2))/2)+size(letterJ,2)-1)) = letterJ;

figure
mesh(squeeze(p.zT),squeeze(p.xT),squeeze(p.pxz))
title("Reflectivity Function")
xlabel("x")
ylabel("z")

pAll.CSAR_J = p

%% Look at the non-zero y-ranges
%-------------------------------------------------------------------------%
for iyP = 1:p.yLim
    if squeeze(mean(p.pxyz(:,:,iyP),[1,2])) > 0
        figure
        mesh(flip(squeeze(p.xT)),flip(squeeze(p.zT)),flipud(squeeze(p.pxyz(:,iyP,:)).'))
        title("Reflectivity Function")
        view(2)
        xlabel("x")
        ylabel("y")
        title("2D Image at z = " + p.zT(iyP))
    end
end

clear iyP