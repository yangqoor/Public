P = imread('.\dataset\img_smoothing\boy.bmp');

% Set coefficients as input
P = im2double(P);
I = P;
r = 2;
e = 0.1^2;
s = 4;

%% Image smoothing on gray level image
disp('Start Smoothing.');

t1= clock;
Q = fastGuidedF2d(P, I, r, e, 1);
disp('Normal run time:');
disp(etime(clock, t1));

t2= clock;
fastQ = fastGuidedF2d(P, I, r, e, s);
disp('Fast run time:');
disp(etime(clock, t2));

disp('Finish Smoothing.');
%%

P = im2uint8(P);
Q = im2uint8(Q);
fastQ = im2uint8(fastQ);

%%
% show result images
subplot(131) 
imshow(P); title('original image')
subplot(132)
imshow(Q); title('guided filtering')
subplot(133)
imshow(fastQ); title('fast guided filtering')
%%

