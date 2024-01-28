clear all

run matconvnet/matlab/vl_setupnn ;
gpuDevice(1)

net_path = './models/noise0.01';    %% net trained with 1% noise
% net_path = './models/noise0.03';    %% net trained with 3% noise
% net_path = './models/noise0.05';    %% net trained with 5% noise

data_path = './data/noise0.01/';   %% data path with 1% noise
% data_path = './data/noise0.03/';   %% data path with 3% noise
% data_path = './data/noise0.05/';   %% data path with 5% noise

out_path = './out/';
mkdir(out_path)

[net, lambda] = loadNetwork(net_path);    %% load network and deconvolution hyper-parameters

for i=1:8
    x = im2double(imread(fullfile(data_path, ['clean_' num2str(i) '.png'])));   % x: clean
    y = im2double(imread(fullfile(data_path, ['blur_' num2str(i) '.png'])));    % y: blur
    kernel = im2double(imread(fullfile(data_path, ['kernel_' num2str(i) '.png']))); % blur kernel
    kernel = kernel/sum(kernel(:));
    
    % padding boundaries
    ks = floor(size(kernel, 1)/2);
    [h,w] = size(y);
    if(mod(h,2)==0&&mod(w,2)==0)
        y = wrap_boundary_with_edgetaper(y, size(y)+ks*2, ks);
    end
    if(mod(h,2)==1&&mod(w,2)==0)
        y = wrap_boundary_with_edgetaper(y, size(y)+ks*2+[1,0], ks);
    end
    if(mod(h,2)==0&&mod(w,2)==1)
        y = wrap_boundary_with_edgetaper(y, size(y)+ks*2+[0,1], ks);
    end
    if(mod(h,2)==1&&mod(w,2)==1)
        y = wrap_boundary_with_edgetaper(y, size(y)+ks*2+[1,1], ks);
    end
    y = circshift(y, [ks*1,ks*1]); 
    
    y = gpuArray(single(y));
    kernel = gpuArray(single(kernel));
    
    tic
    y2 = DL_deblur(y, kernel, net, lambda);  %% non-blind deblurring
    toc 
    y2 = gather(y2);
    
    % cropping boundaries
    if(mod(h,2)==1&&mod(w,2)==0)
        y2 = y2(1:end-1,:);
    end
    if(mod(h,2)==0&&mod(w,2)==1)
        y2 = y2(:,1:end-1);
    end
    if(mod(h,2)==1&&mod(w,2)==1)
        y2 = y2(1:end-1,1:end-1);
    end
    x = x(ks+1:end-ks, ks+1:end-ks);   
    
    imwrite(y2, fullfile(out_path, ['deblur_' num2str(i) '.png']))
        
    [~, ~, psnr, ssim]=psnr_ssim_img(x,y2,20)
end
