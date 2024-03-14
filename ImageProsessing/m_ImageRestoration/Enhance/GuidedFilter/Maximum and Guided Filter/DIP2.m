A=imread('cameraman.tif');
%converting gray image to HSV
HSV = cat(3, zeros(size(A)), zeros(size(A)), double(A)./255);
subplot(3,3,1);
imshow(HSV);
title("Fig(a): original");
%plotting H,S,V channels
V=HSV(:,:,3);
subplot(3,3,2);
imshow(V);
title("Fig(b): Value channel");
H=HSV(:,:,1);
subplot(3,3,3);
imshow(H);
title("Fig(c): Hue channel");
S=HSV(:,:,2);
subplot(3,3,4);
imshow(S);
title("Fig(d): Saturation channel");
%display the value channel
disp(V);
%applying max filter
F=  ordfilt2(V,15,ones(5,5));
subplot(3,3,5);
imshow(F);
title("Fig(e): Max filter");
%applying Guided filter
s=imguidedfilter(F);
subplot(3,3,6);
imshow(s);
title("Fig(f): Illumination");
%display the illumination
disp(s);
%calculation of reflectance

reflectance=V./s;
disp(reflectance);
subplot(3,3,7);
imshow(reflectance);
title("Fig(g): Reflectance");
%concatenation of processed value channel with H&S channel
C=cat(3,H,S,s);
D=hsv2rgb(C);
subplot(3,3,8);
imshow(D);
title("Fig(h): RGB from Illumination");

