% function for calibration
% set data set to be tested as true, otherwise set as false
% e.g.if test 'synthetic calibration', run 'Calibration(true, false, false)'
function Calibration(synthetic, real, own)

    % for syntheric calibration image set
    if synthetic
        for sn=1:2:5
            proj_name = ['synthetic_calibration/000',num2str(sn-1),'.png'];
            cam_name = ['synthetic_calibration/000',num2str(sn),'.png'];
            proj_img = imread(proj_name);
            cam_img = imread(cam_name);
            save_path = ['synthetic_calibration/reproject_000',num2str(sn-1),'.png'];

            [proj_img_out, cam_img_out] = reprojection(proj_img, cam_img, 1024, 768, 378, 277, 270, true);
            imwrite(cam_img_out, save_path);
        end
    % for provided real image set
    elseif real
        for rn=1:9
            proj_name = ['real_calibration/IMG_932',num2str(rn),'.jpg'];
            cam_name = ['real_calibration/IMG_932',num2str(rn),'.jpg'];
            proj_img = imread(proj_name);
            cam_img = imread(cam_name);
            save_path = ['real_calibration/reproject_932',num2str(rn),'.jpg'];
            
            [proj_img_out, cam_img_out] = reprojection(proj_img, cam_img, 1024, 768, 518, 120, 299, true);
            imwrite(cam_img_out,save_path);
        end
    % for own captured image set
    elseif own
        for on=1:6
            proj_name = ['own_calibration/IMG_28',num2str(on+87),'.jpg'];
            cam_name = ['own_calibration/IMG_28',num2str(on+87),'.jpg'];
            proj_img = imread(proj_name);
            cam_img = imread(cam_name);
            save_path = ['own_calibration/reproject_28',num2str(on+87),'.jpg'];
            
            [proj_img_out, cam_img_out] = reprojection(proj_img, cam_img, 1920, 1080, 705, 285, 512, true);
            imwrite(cam_img_out,save_path);
        end
    end
      
end


% function used to reprojection
function [proj_img_out, cam_img_out] = reprojection(proj_img, cam_img, output_width, output_height, checkoff_x, checkoff_y, check_size, if_resize)
    % ask user to select 4 corners of chequerboard
    figure, imshow(proj_img), title('select 4 corners of chequeboard');
    num_correct = 0;
    while(num_correct==0)
        [tem_x, tem_y] = getline(gcf);
        if length(tem_x)~=4
            imshow(proj_img),title('select 4 corners');
        else 
            num_correct = 1;
        end
    end
    close all;
    
    % coordinates of 4 corners 
    proj_pts = [tem_x';tem_y'];
    real_pts = [checkoff_x, checkoff_x+check_size, checkoff_x+check_size, checkoff_x;
                checkoff_y, checkoff_y, checkoff_y+check_size, checkoff_y+check_size];
    
    % get homography
    H_got = get_homography(proj_pts, real_pts);
    trans_mat = maketform('projective', H_got');
    
    if(if_resize)
        proj_img_out = imtransform(proj_img, trans_mat, 'XData', [1,output_width], 'YData', [1, output_height]);
        cam_img_out = imtransform(cam_img, trans_mat, 'XData', [1,output_width], 'YData', [1, output_height]);
    else
        proj_img_out = imtransform(proj_img, trans_mat);
        cam_img_out = imtransform(cam_img, trans_mat);
    end
    
    figure, subplot(2,2,1),imshow(proj_img),title('original projected image');
    subplot(2,2,2), imshow(cam_img),title('original image for chequerboard');
    subplot(2,2,3), imshow(proj_img_out), title('rectified projected image');
    subplot(2,2,4), imshow(cam_img_out), title('reprojected chequerboard');
end


% function used to get appropriate homography matrix H
function H = get_homography(proj_pts, real_pts)
    M = size(proj_pts,2);
    proj_pts = [proj_pts; ones(1,M)];
    real_pts = [real_pts; ones(1,size(real_pts,2))];
    
    A = zeros(2*M, 9);
    count = 1;
    for i=1:M
        ui = proj_pts(1,i);
        vi = proj_pts(2,i);
        xi = real_pts(1,i);
        yi = real_pts(2,i);
        A(count,:) = [0, 0, 0, -ui, -vi, -1, yi*ui, yi*vi, yi];
        A(count+1,:) = [ui, vi, 1, 0, 0, 0, -xi*ui, -xi*vi, -xi];
        
        count = count + 2;
    end
    
    h = solveAXEqualsZero(A);
    H = reshape(h,[3,3]);
    H = H';    
end



function x = solveAXEqualsZero(A)
    [~,~,V] = svd(A);
    N = size(V,2);
    x = V(:,N);
end