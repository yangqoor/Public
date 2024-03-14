clc;clear

addpath('Code/') 

%% Parameters
ST = 1;
threshold = 0.05;

r1 =[360 640];
r0 = [720 1280];

r = 16;
rr = 1;
hei = 36;
wid = 64;

N = boxfilter(ones(hei,wid), r);
NN = boxfilter(ones(hei, wid), rr); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.

time = 0;
nFrames = 1;

%% Load video
path = 'Data/Ship_input/';
video_path = dir(fullfile(path, '*.png'));

save_path = 'Output/Ship_proposed/';

%% Read Frame
RGB0 = imread(fullfile(path, video_path(1).name));
% RGB0 = imresize(RGB0, r0, 'bilinear');

tic;
RGB0 = im2double(RGB0);
I0 = rgb2gray(RGB0);
I1 = impyramid(I0,'reduce');
I2 = impyramid(I1,'reduce');
I3 = impyramid(I2, 'reduce');

I_previous = I0;

%% Initilialized results
gamma = 1.0;

[I_initial, t0_rough, A]  = pyramid_dehazing(RGB0, I0, I1, I2, threshold, ST, gamma);

imwrite(I_initial, strcat(save_path, video_path(1).name));

time = time + toc;
nFrames=nFrames+1;
subplot(1,2,1);imshow(RGB0);title('Input');
subplot(1,2,2);imshow(I_initial);title('Output');
drawnow;

%% Process full-video

for ii = 2 : length(video_path)
    RGB0 = imread(fullfile(path, video_path(ii).name));
%     RGB0 = imresize(RGB0, r0, 'bilinear');
        
    tic;
    RGB0 = im2double(RGB0);
    I0 = rgb2gray(RGB0);
    
    I1 = impyramid(I0,'reduce');
    I2 = impyramid(I1,'reduce');
    I3 = impyramid(I2, 'reduce');
    
    
    %% Temporal coherence
    diff = (I0 * 255.0 - I_previous * 255.0).^2;

    w = exp(-1 * diff / 100);
    w = mean(w(:));
       
    t0_previous = t0_rough;
    I_previous = I0;

    if w >= 0.85
        t0 = fast_gradient_2(I0, t0_previous, N, NN);
        t0 = max(t0, 0.05);
        
        result_previous = (RGB0 - A)./ t0 + A;
        
        result = result_previous;
    else
        I_dv = get_size_image_i(I2, threshold, ST);
        [u,v]=size(I_dv);
        A0 = mean(maxk(I_dv(:),round(u * v * 0.05)));
        A0 = min(A0, 0.99);
        A = (1 - w) * A0 + w * A;
        
        if w < 0.5
            [result, t0_rough] = pyramid_dehazing_w_A(RGB0, I0, I1, I2, A, gamma);
        else
            t0 = fast_gradient_2(I0, t0_previous, N, NN);
            t0 = max(t0, 0.05);

            result_previous = (RGB0 - A)./ t0 + A;

            result = result_previous;
        end
    end
              
    nFrames=nFrames+1;
    time=time+toc;
    
    imwrite(result, strcat(save_path, video_path(ii).name));

%     min(result(:))
    
    subplot(1,2,1);imshow(RGB0);title('Input');
    subplot(1,2,2);imshow(result);title('Output');
    %imwrite
    drawnow;
    if nFrames > 100
        disp(['Fast Output Dehazing:' num2str(nFrames/time) 'fps']);
    end
    

end
