
newImageRGB = imread('.\img\1_banana_noise.jpg');
 

% figure(1);
% imshow(newImageRGB);
%%%%%%%%%""""""""BLUR""""""""""""""

% PSF = fspecial('gaussian',7,10);
 %V = .0001;
% BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);

WT = zeros(size(newImageRGB));
WT(5:end-4,5:end-4) = 1;
%V = .0001*;

% J1 = deconvlucy(newImageRGB,PSF);
% J1=imsharpen(J1); 
% J1=imsharpen(J1,'Radius',5,'Amount',4);
%afterWiener = wiener2(J1,[5 5]);
%  J2 = deconvlucy(I,PSF,5,uint8(0));
%  J2=imsharpen(J2); 
%J2=imsharpen(J2,'Radius',5,'Amount',4);
 m=imread('.\img\1_banana_noise.jpg');
 figure(4002);
 imshow(m);
  HSV = rgb2hsv(m);
 H = HSV(:,:,1);
 S = HSV(:,:,2);
 V = HSV(:,:,3);
  
%convert image to gray level
grayImage1 = V;
 figure(4000);
 imshow(grayImage1);
 PSF = fspecial('gaussian',2,1);
% %PSF = imgaussfilt(I, 2);
% V = .0001;
% BlurredNoisy = imnoise(imfilter(newImageRGB,PSF),'gaussian',0,V);

 %PSF = fspecial('gaussian',2,1);
 J3 = deconvlucy(newImageRGB,PSF,5,uint8(0),WT);
 %J3 = deconvlucy(newImageRGB,PSF,5,V,WT);
 J3=imsharpen(J3,'Radius',2,'Amount',1);
%J3=imsharpen(J3);
%J4=imsharpen(J3,'Radius',5,'Amount',0);

% figure(2);
% imshow(BlurredNoisy);

% figure(3);
% % imshow(J2);
% figure(4);
% imshowpair(newImageRGB,J2,'montage');

% figure(5);
% imshow(J2);
% figure(6);
% imshow(J3);
% figure(100);
% imshowpair(newImageRGB,J3,'montage');






%%%%%%%%%%%%%%%%%

newImageHSV = rgb2hsv(J3);
H = newImageHSV(:,:,1);
S = newImageHSV(:,:,2);
V = newImageHSV(:,:,3);
  
% convert image to gray level
grayImage = V;
 figure(1);
 imshow(grayImage);

% grayImage1 = H;
% grayImage2 = S;

% applying wiener filter ot image.
afterWiener = wiener2(grayImage,[5 5]);
%afterWiener1 = wiener2(grayImage1,[5 5],.11);
%afterWiener2 = wiener2(grayImage2,[5 5],.11);
grayImage = afterWiener;

%noise=imnoise(img,'salt & pepper',.15);
new=medfilt2(grayImage,[3 3]);
%new=medfilt2(grayImage);

%new = imsharpen(new);
%new = adapthisteq(new);
V=new;
% figure(3);
%  imshow(V);

%H = afterWiener1;
%S = afterWiener2;
HSVaftermed = cat(3, H, S, V);
afterhsv = hsv2rgb(HSVaftermed);

% %B=afterhsv;
% % 

% AInv = imcomplement(afterhsv);
% %BInv = imreducehaze(AInv);
% BInv = imreducehaze(AInv, 'Method','approx','ContrastEnhancement','boost');
% %[BInv, TInv] = imreducehaze(AInv, 'Method', 'approxdcp', 'ContrastEnhancement', 'none');
% B = imcomplement(BInv);
% figure(1000);
% imshow(B);
% % %B = imguidedfilter(B);


 %COLOR HISTOGRAM EQUALIZATION

%READ THE INPUT IMAGE
% I = imread('fruit_main.PNG');

%CONVERT THE RGB IMAGE INTO HSV IMAGE FORMAT
HSV = rgb2hsv(afterhsv);
%http://angeljohnsy.blogspot.com/2013/05/converting-rgb-image-to-hsi.html


%PERFORM HISTOGRAM EQUALIZATION ON INTENSITY COMPONENT
Heq = histeq(HSV(:,:,3));
%http://angeljohnsy.blogspot.com/2011/04/matlab-code-histogram-equalization.html

HSV_mod = HSV;
HSV_mod(:,:,3) = Heq;

B = hsv2rgb(HSV_mod);
%http://angeljohnsy.blogspot.com/2013/06/convert-hsi-image-to-rgb-image.html
% figure(100);
% imshow(B);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"""""""""""""""" OVER ENHANCED ***********







%%%%%%%%%%%%%%%%%%%%%%**********************************************







imghsv = rgb2hsv(B);
H = imghsv(:,:,1);
S = imghsv(:,:,2);
V = imghsv(:,:,3);
%homomorphic

imghm = homomorphic_filtering(V);
%imghm = homomorphic_filtering(B);
figure(4);
imshowpair(m,imghm,'montage');
%%%%%%%

%guided_work

original = imghm;    %reference(guidance) image for guided filter 

p = V;             %guided image 

r = 4;
eps = 0.009^2; % try eps=0.1^2, 0.2^2, 0.4^2

tic;
q = guidedfilter(original, p, r, eps);
toc;

s = 4; % sampling ratio
tic;
q_sub = improved(original, p, r, eps, s);
toc;
figure(5);
imshow(q_sub);
%q_sub = log(1+q_sub);

afterretinex = retinex_frankle_mccann(q_sub,10);
figure(800);
imshow(afterretinex);
%afterretinex=q_sub;
V = afterretinex;

%S = retinex_frankle_mccann(S,5);
%H = retinex_frankle_mccann(H,5);

%H = filter2(fspecial('average',3),H);
%S = filter2(fspecial('average',3),S);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%V = filter2(fspecial('average',3),V);
%H = medfilt2(H);
%S = medfilt2(S);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%V = medfilt2(V);
%H = imsharpen(H);
%S = imsharpen(S);
%V = imsharpen(V);
HSVafterwiener = cat(3, H, S, V);
afterhsv = hsv2rgb(HSVafterwiener);
afterhsv = afterhsv * 255;
afterhsv = uint8(afterhsv);


afterhsv=imsharpen(afterhsv,'Radius',1,'Amount',1);
%afterhsv = imsharpen(afterhsv);
figure(6);
%imshowpair(newImageRGB,afterhsv,'montage');
imshow(afterhsv);

% figure(7);
% imshowpair(newImageRGB,afterhsv,'montage');

figure(8);
imshowpair(m,afterhsv,'montage');


%%%%%%%%%%%%%%%%%"""""""""""""CHECK""""""""""

newImageHSV = rgb2hsv(afterhsv);
H = newImageHSV(:,:,1);
S = newImageHSV(:,:,2);
V = newImageHSV(:,:,3);
  
% convert image to gray level
grayImage = V;
%  figure(2);
%  imshow(grayImage);

grayImage1 = H;
grayImage2 = S;

% applying wiener filter ot image.
afterWiener = wiener2(grayImage,[5 5]);

V=afterWiener;
% figure(3);
%  imshow(V);

%H = afterWiener1;
%S = afterWiener2;
F = cat(3, H, S, V);
F = hsv2rgb(F);
F = F * 255;
F = uint8(F);
%F=imsharpen(F,'Radius',6,'Amount',1);
%F=imsharpen(F,'Radius',2,'Amount',1);
%  F = imreducehaze(F);
%  F = imreducehaze(F, 'Method','approx','ContrastEnhancement','boost');

% figure(10);
% imshow(F);

% figure(11);
% imshowpair(m,F,'montage');
%%%%%%%%%%%%%%%%%
% F = rgb2lin(F);
% illuminant = illumpca(F);
% B_lin = chromadapt(F,illuminant,'ColorSpace','linear-rgb');
% P = lin2rgb(B_lin);
% figure(20000);
%  imshow(P);

%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%
% x = 509;
% y = 380;
% gray_val = [F(y,x,1) F(y,x,2) F(y,x,3)];
% 
% P = chromadapt(F,gray_val);
% 
% figure(20000);
% imshow(P);
%%%%%%%%%%%%%




% [m n]=size(F);
% for i=1:1:m
%     for j=1:1:n
%         C(i,j)=F(i,j)-100;
%     end
% end
% 
% figure(15);
% imshow(C);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%**********medium*********
% J = saturate(F,2);
%  S=J;
%  K = cat(3, H, S, V);
%  K = hsv2rgb(K);
%  K = K * 255;
%  K = uint8(K);
% figure(11); 
% imshow(K);

% hsvImage = rgb2hsv(F);
% hChannel = hsvImage(:, :, 1);
% sChannel = hsvImage(:, :, 2);
% vChannel = hsvImage(:, :, 3);
% meanS = mean2(sChannel);
% meanV= mean2(vChannel);
% 
% 
% 
% newV = meanV + 0.5 * (vChannel - meanV); 
%  %newV = 1*vChannel; % where factor is a positive number
%  newV = min(newV,1);
% 
% newS = meanV + 0.5 * (sChannel - meanS); 
% % newS = .8*sChannel; % where factor is a positive number
%  newS = min(newS,1);
% 
% % newHSVImage = cat(3, hChannel, newS, newV);
% newHSVImage = cat(3, hChannel, newS, newV);
% newRGBImage = hsv2rgb(newHSVImage);
%   figure(15);
%  imshow(newRGBImage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*******************

% F = imadjust(F,[0.3 0.7],[])
%  figure(15);
%  imshow(F);

% F=double(F);
% a=min(min(F));
% b=max(max(F));
% t=10;
% [m1,m2]=size(F);
% I2=zeros(m1,m2);
% for i=1:m1
%  for j=1:m2
%   I2(i,j)=(t/(b-a)).*(F(i,j)-a);
%  end
% end
% I2=uint8(I2);
% figure(15);
% imshow(I2);



% %-------------------------INPUT calculate mean, std. dev, entropy--------------
imgmean = mean2(newImageRGB);
imgstddev = std2(newImageRGB);
imgentropy = entropy(newImageRGB);

fprintf('Mean : ');
disp(imgmean);
fprintf('Std. deviation: ');
disp(imgstddev)
fprintf('Entropy: ');
disp(imgentropy);

%-------------------------OUTPUT calculate mean, std. dev, entropy--------------
imgmean = mean2(afterhsv);
imgstddev = std2(afterhsv);
imgentropy = entropy(afterhsv);

fprintf('Mean : ');
disp(imgmean);
fprintf('Std. deviation: ');
disp(imgstddev)
fprintf('Entropy: ');
disp(imgentropy);


% [peaksnr, snr] = psnr(F, newImageRGB);
% fprintf('Peak-SNR: %0.4f\n', peaksnr);
% fprintf('SNR: %0.4f\n', snr);

% [ppp, ppps] = psnrs(F, newImageRGB);
% fprintf(' Peak-SNR: %0.4f\n', ppp);
% fprintf(' SNR: %0.4f\n', ppps);

