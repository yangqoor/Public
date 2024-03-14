%% Load images
I = im2double(imread('sourceimages\test4\Lenna.png'));
I1 = im2double(imread('sourceimages\test4\Lenna4.png'));
I2 = im2double(imread('sourceimages\test4\Lenna5.png'));
figure(1);
imshow(I1);

figure(2);
imshow(I2);


%% Choice of parameters
r1 = 45;
eps1 = 0.3;
r2 = 7;
eps2 = 10^-6;

%% step A : two-scale image decomposition
% B1 and B2: blured images
% D1 and D2: detailed images

average_filter = 1/(31*31)*ones(31,31);
B1 = convn(I1, average_filter, 'same');
B2 = convn(I2, average_filter, 'same');
D1 = I1 - B1;
D2 = I2 - B2;

%% step B weight map construction
Ig1 = rgb2gray(I1);
Ig2 = rgb2gray(I2);

% laplacian filtering
laplacian_filter = [[0 -1 0]; [-1 4 -1]; [0 -1 0]];
H1 = convn( Ig1, laplacian_filter, 'same');
H2 = convn( Ig2, laplacian_filter, 'same');

% gaussian filtering
S1 = imgaussfilt(abs(H1), 'FilterSize', 11);
S2 = imgaussfilt(abs(H2), 'FilterSize', 11);

% maybe reshape P1 and P2
P1 = (S1 == max(S1, S2));
P2 = (S2 == max(S1, S2));

% r1, eps1, r2 and eps2 are not related to the index of I1, P1, I2, P2, etc
Wb1 = guidedfilter(Ig1, P1, r1, eps1);
Wd1 = guidedfilter(Ig1, P1, r2, eps2);
Wb2 = guidedfilter(Ig2, P2, r1, eps1);
Wd2 = guidedfilter(Ig2, P2, r2, eps2);

% normalizing weights
Sumb = Wb1 + Wb2;
Sumd = Wd1 + Wd2;
Wb1 = Wb1./Sumb;
Wd1 = Wd1./Sumd;
Wb2 = Wb2./Sumb;
Wd2 = Wd2./Sumd;


%% step C: two-scale image reconstruction

Bb = repmat(Wb1, [1 1 3]) .* B1 + repmat(Wb2, [1 1 3]) .* B2;
Db = repmat(Wd1, [1 1 3]) .* D1 + repmat(Wd2, [1 1 3]) .* D2;

F = Bb + Db;
figure(3);
imshow(F);

figure(4);
imshow([S1,P1,Wb1,Wd1],[0,1]);

figure(5);
imshow([S2,P2,Wb2,Wd2],[0,1]);

figure(6);
Idiff = F-I;
imshow(Idiff-min(Idiff(:))/(max(Idiff(:))-min(Idiff(:))));