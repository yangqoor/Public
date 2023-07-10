% function used to get uv code for image sequence (model)
function [coded_pix]=get_pix_code(folder,img_name,first,digit,format,if_rgb,if_synthetic)
    % image sequence with gray values
    if if_synthetic
        if if_rgb
            img_u_rgb = load_sequence_color(folder, img_name, first, first+19, digit, format);
            img_v_rgb = load_sequence_color(folder, img_name, first+20, first+39, digit, format);
        
            img_u_gray = seq2gray(img_u_rgb);
            img_v_gray = seq2gray(img_v_rgb);        
        else
            img_u_gray = load_sequence(folder,img_name,first, first+19, digit, format); 
            img_v_gray = load_sequence(folder,img_name, first+20, first+39, digit, format);
            img_u_gray = double(img_u_gray);
            img_v_gray = double(img_v_gray);
        end
    else % for real images
        img_u_gray = load_gray_channel(folder,img_name,first,20,format);
        img_v_gray = load_gray_channel(folder,img_name, first+20, 20, format);
    end
    % get uv code
    code_u = get_code_uv(img_u_gray);
    code_v = get_code_uv(img_v_gray);
    
    % generate mask to eliminate errors
    mask_sum = code_u(:,:,2)+code_v(:,:,2);
    mask = mask_sum > 5;
    mask_3d = repmat(mask,[1,1,2]);
    
    % u=uv_code(:,:,1) v=iv_code(:,:,2)
    uv_code = cat(3,code_u(:,:,1),code_v(:,:,1));
    
    % use mask to remove background
    [height,width,~] = size(img_u_gray);
    coded_pix = mask_3d  .* uv_code + (1-mask_3d) .* zeros(height,width,2);
    
    u = coded_pix(:,:,1);
    v = coded_pix(:,:,2);
    figure;
    subplot(1,2,1),imagesc(u),title('u');
    subplot(1,2,2),imagesc(v),title('v');
end