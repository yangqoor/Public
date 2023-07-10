% function used to generate depth map and point cloud
function [depth_map, point_cloud] = get_depth(uv_code)
    [height, width, ~] = size(uv_code);
    depth_map = zeros(height, width);
    result = zeros(height, width, 3);
    point_cloud = zeros(height*width, 3);
    
    % load give synthetic matrices
    % load_synthetic_matrices;
    % load_real_calibration;
    load_own_calibration;
    
    % get translation and rotation matrix
    cam_R = cam_ex(1:3,1:3);
    cam_T = cam_ex(1:3,4);
    proj_R = proj_ex(1:3,1:3);
    proj_T = proj_ex(1:3,4);
     
%     % generate a new rotation matrix to apply on camera matrix
%     z_R = [cos(pi/2),-sin(pi/2),0; sin(pi/2),cos(pi/2),0;0,0,1];
%     new_camR = z_R * cam_R;
%     new_camex(1:3,1:3) = new_camR;
%     new_camex(1:3,4) = cam_T;
        
    % solve linear equation for each pixel
    count = 0;
    for i=1:height
        for j=1:width
            if sum(uv_code(i,j,:))>2
                A = zeros(4,3);
                b = zeros(4,1);
            
                % convert points to normalized camera coodinates
                p1 = cam_in\[j;i;1];
                p2 = proj_in\[uv_code(i,j,2);uv_code(i,j,1);1];
            
                % camera
                A(1,:) = [cam_R(3,1)*p1(1)-cam_R(1,1), cam_R(3,2)*p1(1)-cam_R(1,2), cam_R(3,3)*p1(1)-cam_R(1,3)];
                A(2,:) = [cam_R(3,1)*p1(2)-cam_R(2,1), cam_R(3,2)*p1(2)-cam_R(2,2), cam_R(3,3)*p1(2)-cam_R(2,3)];
                b(1:2) = [cam_T(1)-cam_T(3)*p1(1), cam_T(2)-cam_T(3)*p1(2)];

                
                % projector (2nd camera)
                A(3,:) = [proj_R(3,1)*p2(1)-proj_R(1,1),proj_R(3,2)*p2(1)-proj_R(1,2),proj_R(3,3)*p2(1)-proj_R(1,3)];
                A(4,:) = [proj_R(3,1)*p2(2)-proj_R(2,1),proj_R(3,2)*p2(2)-proj_R(2,2),proj_R(3,3)*p2(2)-proj_R(2,3)];
                b(3:4) = [proj_T(1)-proj_T(3)*p2(1), proj_T(2)-proj_T(3)*p2(2)];
            
                
                % get the least squares solution
                x = A\b;
            
                % get the least squares solution
                count = count+1;
                point_cloud(count,:) = x;    % x: (u,v,w)
                result(i,j,:) = cam_ex(1:3, 1:4)*[x;1];
                
                
                % depth_map(i,j,:) = cam_ex(1:3, 1:4)*[x;1];
            else
                result(i,j,:) = -1;
                %depth_map(i,j,:) = -1;
            end
        end
    end
    depth_map = result(:,:,3);
end