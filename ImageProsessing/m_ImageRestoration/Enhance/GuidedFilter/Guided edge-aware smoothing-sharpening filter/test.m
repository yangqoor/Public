close all
clear all

I = (double(imread('kodim19.png'))/255);

G= I;
radius = [11];
Epsilon = [0.01];
kappa = [0.01 0.1 1 5 7.5]; % Kappa controls the sharpening/smoothing level. 
scale = 1;
R = [];
K =[];

for i=1:length(radius)
   K= []
    for j=1:length(kappa)
        J = SSIF(I,G,radius(i),Epsilon,kappa(j),scale);
        K = [K J];
    end
    R = [R;K];
end

figure
imshow(R)
