function test_LapSRN(model_name, epoch, dataset, test_scale, gpu, save_img, compute_ifc)
% -------------------------------------------------------------------------
%   Description:
%       Script to test LapSRN on benchmark datasets
%       Compute PSNR, SSIM and IFC
%
%   Input:
%       - model_name    : model filename saved in 'models' folder
%       - epoch         : model epoch to test
%       - dataset       : testing dataset (Set5, Set14, BSDS100, Urban100, Manga109)
%       - test_scale    : testing SR scale
%       - gpu           : GPU ID
%       - save_img      : Save output images or not [Default = 0]
%       - compute_ifc   : Compute IFC or not [Default = 0]
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
    
    if ~exist('save_img', 'var')
        save_img = 0;
    end
    
    if ~exist('compute_ifc', 'var')
        compute_ifc = 0;
    end
    
    %% setup paths
    addpath(genpath('utils'));
    addpath(fullfile(pwd, 'matconvnet/matlab'));
    vl_setupnn;
    
    %% Load model
    model_filename = fullfile('models', model_name, sprintf('net-epoch-%d.mat', epoch));
    fprintf('Load %s\n', model_filename);
    
    net = load(model_filename);
    net = dagnn.DagNN.loadobj(net.net);
    net.mode = 'test' ;

    output_var = 'level1_output';
    output_index = net.getVarIndex(output_var);
    net.vars(output_index).precious = 1;

    if( gpu )
        gpuDevice(gpu)
        net.move('gpu');
    end
    
    %% image path
    input_dir = fullfile('datasets', dataset);
    output_dir = fullfile('models', model_name, sprintf('epoch_%d', epoch), ...
                          dataset, sprintf('x%d', test_scale));

    if( ~exist(output_dir, 'dir') )
        mkdir(output_dir);
    end
    
    %% load image list
    list_filename = sprintf('lists/%s.txt', dataset);
    img_list = load_list(list_filename);
    num_img = length(img_list);
    

    %% testing
    PSNR = zeros(num_img, 1);
    SSIM = zeros(num_img, 1);
    IFC  = zeros(num_img, 1);
    time = zeros(num_img, 1);
    
    for i = 1:num_img
        
        img_name = img_list{i};
        fprintf('Process %s %d/%d: %s\n', dataset, i, num_img, img_name);
        
        %% Load HR image
        input_filename = fullfile(input_dir, sprintf('%s.png', img_name));
        img_GT = im2double(imread(input_filename));
        img_GT = mod_crop(img_GT, test_scale);
    
        %% generate LR image
        img_LR = imresize(img_GT, 1/test_scale, 'bicubic');
            
        %% apply SR
        [img_HR, time(i)] = SR_LapSRN(img_LR, net, test_scale, gpu);
            
        %% save result
        if( save_img )
            output_filename = fullfile(output_dir, sprintf('%s.png', img_name));
            fprintf('Save %s\n', output_filename);
            imwrite(img_HR, output_filename);
        end

        %% evaluate
        [PSNR(i), SSIM(i), IFC(i)] = evaluate_SR(img_GT, img_HR, test_scale, compute_ifc);

    end
    
    PSNR(end+1) = mean(PSNR);
    SSIM(end+1) = mean(SSIM);
    IFC(end+1)  = mean(IFC);
    time(end+1) = mean(time);
    
    
    filename = fullfile(output_dir, 'PSNR.txt');
    fprintf('Save %s\n', filename);
    save_matrix(PSNR, filename);

    filename = fullfile(output_dir, 'SSIM.txt');
    fprintf('Save %s\n', filename);
    save_matrix(SSIM, filename);
    
    filename = fullfile(output_dir, 'IFC.txt');
    fprintf('Save %s\n', filename);
    save_matrix(IFC, filename);

    
    fprintf('Average PSNR = %f\n', PSNR(end));
    fprintf('Average SSIM = %f\n', SSIM(end));
    fprintf('Average IFC = %f\n', IFC(end));
    fprintf('Average Time = %f\n', time(end));
