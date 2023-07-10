warning('off');
i_begin = 850;
i_end = 1030;
j_begin = 410;
j_end = 580;

% set color_bar
load('my_colorbar.mat');

for frame_num = 1:49
    dyna_mat = imread(['./dyna/dyna_mat', num2str(frame_num), '.png']);
    ipro_mat = load(['./ground_truth/ipro_mat', num2str(frame_num), '.txt']);
    jpro_mat = load(['./ground_truth/jpro_mat', num2str(frame_num), '.txt']);
    
    % set show image
    rgbImg = zeros(1024, 1280, 3);
    rgbImg(:,:,1) = double(dyna_mat) / 255.0;
    rgbImg(:,:,2) = double(dyna_mat) / 255.0;
    rgbImg(:,:,3) = double(dyna_mat) / 255.0;
    
    for h = 1:1024
        for w = 1:1280
            ipro_val = ipro_mat(h, w);
            jpro_val = jpro_mat(h, w);
            if (i_begin <= ipro_val) && (ipro_val <= i_end) && (j_begin <= jpro_val) && (jpro_val <= j_end)
                color_idx = (mod(uint32(ipro_val), 32));
                color_idx = color_idx * 2 + 1;
                rgbImg(h, w, 1) = my_colorbar(color_idx, 1, 1);
                rgbImg(h, w, 2) = my_colorbar(color_idx, 1, 2);
                rgbImg(h, w, 3) = my_colorbar(color_idx, 1, 3);
            end
        end
    end
    
    % imshow(rgbImg);
    imwrite(rgbImg, ['./analysis/ground_truth/show_i', num2str(frame_num), '.png'])
    fprintf([num2str(frame_num), ' frame.\n']);
end