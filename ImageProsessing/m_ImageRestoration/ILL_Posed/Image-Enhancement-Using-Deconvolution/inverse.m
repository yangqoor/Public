clear all;
clc;

w = imread('eye2.jpg');
imshow(w);
%w = double(w);
wf = fftshift(fftn(w));
b = lbutter(w,15,2);
wb = wf.*b;
wba = abs(ifftn(wb));
wba = uint8(255*mat2gray(wba));
figure
imshow(wba);

%Straight Division
w0 = fftshift(fftn(wba))./b;
w0a=abs(ifftn(w0));
figure
imshow(mat2gray(w0a))

%Constrained Division
d = 0.006;
b=lbutter(w,15,2);b(find(b<d))=1;
w2=fftshift(fftn(wba))./b;
w2a=abs(ifftn(w2));
figure
imshow(mat2gray(w2a))