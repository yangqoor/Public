function [ point_set ] = FindNearestPoint(k_nearest, h_ori, w_ori, mask_mat, viewportMatrix)

    point_set = zeros(k_nearest, 2);
    found_idx = 1;
    
    for k = 1:100
        round_set = zeros(4*k*2, 2);
        round_set(1:k*2, 1) = -k;
        round_set(1:k*2, 2) = (-k:k-1)';
        round_set(k*2+1:2*k*2, 1) = (-k:k-1)';
        round_set(k*2+1:2*k*2, 2) = k;
        round_set(2*k*2+1:3*k*2, 1) = k;
        round_set(2*k*2+1:3*k*2, 2) = (k:-1:-k+1)';
        round_set(3*k*2+1:4*k*2, 1) = (k:-1:-k+1)';
        round_set(3*k*2+1:4*k*2, 2) = -k;
        exit_flag = false;
        
        for i = 1:4*k*2
            h_nbor = h_ori + round_set(i, 1);
            w_nbor = w_ori + round_set(i, 2);
            if (h_nbor >= viewportMatrix(2,1)) && ...
                    (h_nbor <= viewportMatrix(2,2)) && ...
                    (w_nbor >= viewportMatrix(1,1)) && ...
                    (w_nbor <= viewportMatrix(1,2)) && ...
                    (mask_mat(h_nbor, w_nbor) == 1)
                point_set(found_idx, :) = round_set(i, :);
                if found_idx == k_nearest
                    exit_flag = true;
                    break;
                else
                    found_idx = found_idx + 1;
                end
            end
        end
        
        if exit_flag 
            break;
        end
    end
end

