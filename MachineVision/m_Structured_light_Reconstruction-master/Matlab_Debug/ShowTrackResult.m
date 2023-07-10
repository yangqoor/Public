warning('off');

% set color_bar
load('my_colorbar.mat');

for frameIdx = 1:49
    
    % load images & i_pro
    ipro_mat = load(['./result/ipro_mat/ipro_mat', num2str(frameIdx), '.txt']);
    Img = imread(['./dyna/dyna_mat', num2str(frameIdx), '.png']);
    
    % set show image
    rgbImg = zeros(1024, 1280, 3);
    rgbImg(:,:,1) = double(Img) / 255.0;
    rgbImg(:,:,2) = double(Img) / 255.0;
    rgbImg(:,:,3) = double(Img) / 255.0;
    
    % coloration
    for h = 1:1024
        for w = 1:1280
            if ipro_mat(h, w) > 0
                color_idx = (mod(uint32(ipro_mat(h, w)), 32));
                color_idx = color_idx * 2 + 1;
                rgbImg(h, w, 1) = my_colorbar(color_idx, 1, 1);
                rgbImg(h, w, 2) = my_colorbar(color_idx, 1, 2);
                rgbImg(h, w, 3) = my_colorbar(color_idx, 1, 3);
            end
        end
    end
    
    % Show
    imshow(rgbImg);
    imwrite(rgbImg, ['analysis/program_result/show', num2str(frameIdx), '.png']);
    
    fprintf('%d frame.\n', frameIdx);
    
end