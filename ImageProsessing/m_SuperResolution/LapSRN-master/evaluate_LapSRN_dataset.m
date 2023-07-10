% -------------------------------------------------------------------------
%   Description:
%       Script to evaluate pretrained LapSRN on benchmark datasets
%
%   Citation: 
%       Deep Laplacian Pyramid Networks for Fast and Accurate Super-Resolution
%       Wei-Sheng Lai, Jia-Bin Huang, Narendra Ahuja, and Ming-Hsuan Yang
%       IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 2017
%
%   Contact:
%       Wei-Sheng Lai
%       wlai24@ucmerced.edu
%       University of California, Merced
% -------------------------------------------------------------------------

%% testing options
model_scale = 4;            % pretrained model upsampling scale
% dataset     = 'Set5';
% dataset     = 'Set14';
% dataset     = 'BSDS100';
dataset     = 'Urban100';
% dataset     = 'Manga109';
test_scale  = model_scale;  % testing scale can be different from model scale
gpu         = 1;            % GPU ID, gpu = 0 for CPU mode
compute_ifc = 0;            % IFC calculation is slow, enable when needed

%% setup paths
input_dir = fullfile('datasets', dataset);
output_dir = fullfile('results', dataset, sprintf('x%d', test_scale), ...
    sprintf('LapSRN_x%d', model_scale));

if( ~exist(output_dir, 'dir') )
    mkdir(output_dir);
end

addpath(genpath('utils'));
addpath(fullfile(pwd, 'matconvnet/matlab'));
vl_setupnn;

%% load model
model_filename = fullfile('pretrained_models', sprintf('LapSRN_x%d.mat', model_scale));

fprintf('Load %s\n', model_filename);
net = load(model_filename);
net = dagnn.DagNN.loadobj(net.net);
net.mode = 'test' ;

if( gpu ~= 0 )
    gpuDevice(gpu)
    net.move('gpu');
end

%% load image list
list_filename = fullfile('lists', sprintf('%s.txt', dataset));
img_list = load_list(list_filename);
num_img = length(img_list);


%% testing
PSNR = zeros(num_img, 1);
SSIM = zeros(num_img, 1);
IFC  = zeros(num_img, 1);

for i = 1:num_img
    
    img_name = img_list{i};
    fprintf('Testing LapSRN on %s %dx: %d/%d: %s\n', dataset, test_scale, i, num_img, img_name);
    
    %% Load GT image
    input_filename = fullfile(input_dir, sprintf('%s.png', img_name));
    img_GT = im2double(imread(input_filename));
    img_GT = mod_crop(img_GT, test_scale);

    %% generate LR image
    img_LR = imresize(img_GT, 1/test_scale, 'bicubic');
    
    %% apply LapSRN
    img_HR = SR_LapSRN(img_LR, net, test_scale, gpu);
    
    %% save result
    output_filename = fullfile(output_dir, sprintf('%s.png', img_name));
    fprintf('Save %s\n', output_filename);
    imwrite(img_HR, output_filename);
        
    %% evaluate
    [PSNR(i), SSIM(i), IFC(i)] = evaluate_SR(img_GT, img_HR, test_scale, compute_ifc);
    
end

PSNR(end+1) = mean(PSNR);
SSIM(end+1) = mean(SSIM);
IFC(end+1)  = mean(IFC);

fprintf('Average PSNR = %f\n', PSNR(end));
fprintf('Average SSIM = %f\n', SSIM(end));
fprintf('Average IFC = %f\n', IFC(end));

filename = fullfile(output_dir, 'PSNR.txt');
save_matrix(PSNR, filename);

filename = fullfile(output_dir, 'SSIM.txt');
save_matrix(SSIM, filename);

filename = fullfile(output_dir, 'IFC.txt');
save_matrix(IFC, filename);

